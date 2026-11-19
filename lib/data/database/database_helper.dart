import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';
import '../models/daily_schedule_model.dart';
import '../models/subtask_model.dart';
import '../models/reward_model.dart';
import '../models/aac_card_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('autism_assistive.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 17,
      onCreate: (db, version) async {
        await _createDB(db, version);
        await _seedDatabase(db);
        await _seedRewards(db);
        await _createAacTable(db);
        await _seedAacCards(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 7) {
          await db.delete('subtasks');
          await db.delete('daily_schedules');
          await db.delete('tasks');
          await _seedDatabase(db);
        }
        if (oldVersion < 8) {
          await _createRewardsTable(db);
          await _seedRewards(db);
        }
        if (oldVersion < 9) {
          await db.execute(
            'ALTER TABLE rewards ADD COLUMN is_placed INTEGER NOT NULL DEFAULT 0',
          );
          await db.execute(
            'ALTER TABLE rewards ADD COLUMN room_x REAL NOT NULL DEFAULT 0.5',
          );
          await db.execute(
            'ALTER TABLE rewards ADD COLUMN room_y REAL NOT NULL DEFAULT 0.5',
          );
        }
        if (oldVersion < 10) {
          await _createAacTable(db);
          await _seedAacCards(db);
        }
        if (oldVersion < 11) {
          await db.execute('ALTER TABLE tasks ADD COLUMN audio_path TEXT;');
          await db.execute('ALTER TABLE aac_cards ADD COLUMN audio_path TEXT;');
        }
        if (oldVersion < 16) {
          try {
            await db.execute(
              'ALTER TABLE subtasks ADD COLUMN audio_path TEXT;',
            );
          } catch (_) {}
        }
        if (oldVersion < 17) {
          await db.delete('subtasks');
          await db.delete('daily_schedules');
          await db.delete('tasks');
          await _seedDatabase(db);
          await db.delete('aac_cards');
          await _seedAacCards(db);
        }
      },
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        icon_path TEXT,
        tts_text TEXT NOT NULL,
        audio_path TEXT,
        default_duration INTEGER NOT NULL DEFAULT 0,
        reward_points INTEGER NOT NULL DEFAULT 1,
        color_code TEXT NOT NULL DEFAULT '#E2E8F0',
        is_custom INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        day_of_week INTEGER NOT NULL,
        order_index INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'PENDING',
        scheduled_time TEXT,
        reminder_minutes INTEGER NOT NULL DEFAULT 5,
        is_overlay_enabled INTEGER NOT NULL DEFAULT 1,
        completed_at TEXT,
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE subtasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        step_order INTEGER NOT NULL,
        description TEXT NOT NULL,
        icon_path TEXT,
        audio_path TEXT,
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');

    await _createRewardsTable(db);
  }

  Future<void> _createRewardsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS rewards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        points_cost INTEGER NOT NULL,
        image_type TEXT NOT NULL,
        image_path TEXT NOT NULL,
        is_redeemed INTEGER NOT NULL DEFAULT 0,
        is_placed INTEGER NOT NULL DEFAULT 0,
        room_x REAL NOT NULL DEFAULT 0.5,
        room_y REAL NOT NULL DEFAULT 0.5
      )
    ''');
  }

  Future<void> _seedRewards(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM rewards'),
    );

    if (count != null && count > 0) return;

    final defaultRewards = [
      {
        'title': 'Fagylalt / Finomság',
        'points_cost': 3,
        'image_type': 'DEFAULT_ICON',
        'image_path': 'icecream',
        'is_redeemed': 0,
      },
      {
        'title': '30 perc mese',
        'points_cost': 5,
        'image_type': 'DEFAULT_ICON',
        'image_path': 'tv',
        'is_redeemed': 0,
      },
      {
        'title': 'Játszótér / Séta',
        'points_cost': 7,
        'image_type': 'DEFAULT_ICON',
        'image_path': 'park',
        'is_redeemed': 0,
      },
      {
        'title': 'Közös játék',
        'points_cost': 4,
        'image_type': 'DEFAULT_ICON',
        'image_path': 'toys',
        'is_redeemed': 0,
      },
      {
        'title': 'Extra esti mese',
        'points_cost': 2,
        'image_type': 'DEFAULT_ICON',
        'image_path': 'book',
        'is_redeemed': 0,
      },
    ];

    for (var r in defaultRewards) {
      await db.insert('rewards', r);
    }
  }

  Future<void> _seedDatabase(Database db) async {
    Future<int> addTask(
      String title,
      String icon,
      String tts,
      String? audioPath,
      int duration,
      int points,
      String color,
    ) async {
      return await db.insert('tasks', {
        'title': title,
        'icon_path': icon,
        'tts_text': tts,
        'audio_path': audioPath,
        'default_duration': duration,
        'reward_points': points,
        'color_code': color,
        'is_custom': 0,
      });
    }

    Future<void> addSubtask(
      int taskId,
      int order,
      String desc,
      String icon, [
      String? audioPath,
    ]) async {
      await db.insert('subtasks', {
        'task_id': taskId,
        'step_order': order,
        'description': desc,
        'icon_path': icon,
        'audio_path': audioPath,
      });
    }

    // 1. Ébredés
    final tEbredes = await addTask(
      'Ébredés',
      'assets/images/tasks/ebredes.png',
      'Jó reggelt! Ébredj fel!',
      'assets/audio/tasks/jo_reggelt.mp3',
      5,
      1,
      '#BFDBFE',
    );
    await addSubtask(
      tEbredes,
      1,
      'Kelj ki az ágyból!',
      'assets/images/tasks/kelj_ki.png',
      'assets/audio/tasks/kelj_ki.mp3',
    );
    await addSubtask(
      tEbredes,
      2,
      'Húzd fel a takarót!',
      'assets/images/tasks/takaro.png',
      'assets/audio/tasks/takaro.mp3',
    );

    // 2. Reggeli
    final tReggeli = await addTask(
      'Reggeli',
      'assets/images/tasks/reggeli.png',
      'Itt a reggeli!',
      'assets/audio/tasks/reggeli.mp3',
      15,
      1,
      '#FED7AA',
    );
    await addSubtask(
      tReggeli,
      1,
      'Ülj az asztalhoz!',
      'assets/images/tasks/ulj_le.png',
      'assets/audio/tasks/ulj_le.mp3',
    );
    await addSubtask(
      tReggeli,
      2,
      'Edd meg a reggelit!',
      'assets/images/tasks/edd_meg.png',
      'assets/audio/tasks/edd_meg.mp3',
    );
    await addSubtask(
      tReggeli,
      3,
      'Vidd a tányért a mosogatóba!',
      'assets/images/tasks/vidd.png',
      'assets/audio/tasks/vidd.mp3',
    );

    // 3. Fogmosás
    final tFogmosas = await addTask(
      'Fogmosás',
      'assets/images/tasks/fogmosas.png',
      'Moss fogat!',
      'assets/audio/tasks/fogmosas.mp3',
      3,
      2,
      '#BFDBFE',
    );
    await addSubtask(
      tFogmosas,
      1,
      'Tegyél fogkrémet a kefére!',
      'assets/images/tasks/fogkrem.png',
      'assets/audio/tasks/fogkrem.mp3',
    );
    await addSubtask(
      tFogmosas,
      2,
      'Mosd meg a fogaidat!',
      'assets/images/tasks/mosd_meg.png',
      'assets/audio/tasks/mosd_meg.mp3',
    );
    await addSubtask(
      tFogmosas,
      3,
      'Öblítsd ki a szád!',
      'assets/images/tasks/oblites.png',
      'assets/audio/tasks/oblites.mp3',
    );

    // 4. Öltözködés
    final tOltozes = await addTask(
      'Öltözködés',
      'assets/images/tasks/oltozkodes.png',
      'Vedd fel a ruháidat!',
      'assets/audio/tasks/vedd_fel.mp3',
      10,
      2,
      '#FED7AA',
    );
    await addSubtask(
      tOltozes,
      1,
      'Vedd fel a pólót!',
      'assets/images/tasks/polo.png',
      'assets/audio/tasks/polo.mp3',
    );
    await addSubtask(
      tOltozes,
      2,
      'Vedd fel a nadrágot és zoknit!',
      'assets/images/tasks/zokni.png',
      'assets/audio/tasks/zokni.mp3',
    );

    // 5. Cipő és kabát
    final tKabatCipo = await addTask(
      'Cipő és kabát',
      'assets/images/tasks/cipo_kabat.png',
      'Vedd fel a cipőt és kabátot!',
      'assets/audio/tasks/indulasra_keszulodes.mp3',
      5,
      1,
      '#DDD6FE',
    );
    await addSubtask(
      tKabatCipo,
      1,
      'Vedd fel a cipőd!',
      'assets/images/tasks/bujj_bele.png',
      'assets/audio/tasks/bujj_bele.mp3',
    );
    await addSubtask(
      tKabatCipo,
      2,
      'Vedd fel a kabátod!',
      'assets/images/tasks/kabat.png',
      'assets/audio/tasks/kabat.mp3',
    );

    // 6. Indulás
    final tIndulas = await addTask(
      'Indulás',
      'assets/images/tasks/indulas.png',
      'Indulunk!',
      'assets/audio/tasks/indulas.mp3',
      10,
      2,
      '#BBF7D0',
    );
    await addSubtask(
      tIndulas,
      1,
      'Vedd fel a hátizsákot!',
      'assets/images/tasks/vedd_fel_hatizsak.png',
      'assets/audio/tasks/vedd_fel_hatizsak.mp3',
    );
    await addSubtask(
      tIndulas,
      2,
      'Lépjünk ki az ajtón!',
      'assets/images/tasks/lepjunk_ki.png',
      'assets/audio/tasks/lepjunk_ki.mp3',
    );

    // 7. Ebéd
    final tEbedKezmosas = await addTask(
      'Kézmosás és ebéd',
      'assets/images/tasks/ebed.png',
      'Moss kezet és ebédelj!',
      'assets/audio/tasks/ebed.mp3',
      20,
      2,
      '#FED7AA',
    );
    await addSubtask(
      tEbedKezmosas,
      1,
      'Moss kezet!',
      'assets/images/tasks/moss_kezet.png',
      'assets/audio/tasks/moss_kezet.mp3',
    );
    await addSubtask(
      tEbedKezmosas,
      2,
      'Edd meg az ebédet!',
      'assets/images/tasks/egyel_finomat.png',
      'assets/audio/tasks/egyel_finomat.mp3',
    );

    // 8. Játék és pihenés
    final tSzabadjatek = await addTask(
      'Játék és pihenés',
      'assets/images/tasks/jatek.png',
      'Játékidő!',
      'assets/audio/tasks/itt_a_jatek_ideje.mp3',
      30,
      1,
      '#FEF08A',
    );
    await addSubtask(
      tSzabadjatek,
      1,
      'Válassz játékot!',
      'assets/images/tasks/valaszd_ki.png',
      'assets/audio/tasks/valaszd_ki.mp3',
    );
    await addSubtask(
      tSzabadjatek,
      2,
      'Játssz nyugodtan!',
      'assets/images/tasks/jatsz_nyugodtan.png',
      'assets/audio/tasks/jatsz_nyugodtan.mp3',
    );

    // 9. Lecke
    final tHazi = await addTask(
      'Lecke és gyakorlás',
      'assets/images/tasks/lecke.png',
      'Tanuljunk!',
      'assets/audio/tasks/csinaljuk_meg.mp3',
      25,
      3,
      '#BBF7D0',
    );
    await addSubtask(
      tHazi,
      1,
      'Készítsd ki a füzetet!',
      'assets/images/tasks/keszitsd_ki.png',
      'assets/audio/tasks/keszitsd_ki.mp3',
    );
    await addSubtask(
      tHazi,
      2,
      'Oldd meg a feladatot!',
      'assets/images/tasks/oldd_meg.png',
      'assets/audio/tasks/oldd_meg.mp3',
    );

    // 10. Rendrakás
    final tElpakolas = await addTask(
      'Rendrakás',
      'assets/images/tasks/rendrakas.png',
      'Pakoljunk el!',
      'assets/audio/tasks/tegyuk_el.mp3',
      10,
      2,
      '#FBCFE8',
    );
    await addSubtask(
      tElpakolas,
      1,
      'Szedd össze a játékokat!',
      'assets/images/tasks/szedd_ossze.png',
      'assets/audio/tasks/szedd_ossze.mp3',
    );
    await addSubtask(
      tElpakolas,
      2,
      'Tedd vissza a helyére!',
      'assets/images/tasks/tedd_vissza.png',
      'assets/audio/tasks/tedd_vissza.mp3',
    );

    // 11. Vacsora
    final tVacsora = await addTask(
      'Vacsora',
      'assets/images/tasks/vacsora.png',
      'Itt a vacsora! Jó étvágyat!',
      'assets/audio/tasks/itt_az_ideje_a_vacsoranak.mp3',
      20,
      1,
      '#FED7AA',
    );
    await addSubtask(
      tVacsora,
      1,
      'Moss kezet!',
      'assets/images/tasks/moss_kezet_vacsora.png',
      'assets/audio/tasks/moss_kezet_vacsora.mp3',
    );
    await addSubtask(
      tVacsora,
      2,
      'Edd meg a vacsorát!',
      'assets/images/tasks/egyel_vacsora.png',
      'assets/audio/tasks/egyel_vacsora.mp3',
    );

    // 12. Fürdés
    final tFurdes = await addTask(
      'Esti fürdés',
      'assets/images/tasks/furdes.png',
      'Irány fürdeni!',
      'assets/audio/tasks/furdes.mp3',
      15,
      2,
      '#BFDBFE',
    );
    await addSubtask(
      tFurdes,
      1,
      'Mosakodj meg!',
      'assets/images/tasks/mosakodj.png',
      'assets/audio/tasks/mosakodj.mp3',
    );
    await addSubtask(
      tFurdes,
      2,
      'Törölközz meg és öltözz fel!',
      'assets/images/tasks/torolkozz.png',
      'assets/audio/tasks/torolkozz.mp3',
    );
    await addSubtask(
      tFurdes,
      3,
      'Moss fogat!',
      'assets/images/tasks/mosd_meg_a_fogad_esti.png',
      'assets/audio/tasks/mosd_meg_a_fogad_esti.mp3',
    );

    // 13. Mese és alvás
    final tLefekves = await addTask(
      'Mese és alvás',
      'assets/images/tasks/alvas.png',
      'Bújj ágyba! Jó éjt!',
      'assets/audio/tasks/joejt.mp3',
      20,
      2,
      '#DDD6FE',
    );
    await addSubtask(
      tLefekves,
      1,
      'Takarózz be!',
      'assets/images/tasks/takaro_esti.png',
      'assets/audio/tasks/takaro_esti.mp3',
    );
    await addSubtask(
      tLefekves,
      2,
      'Hallgasd a mesét és aludj!',
      'assets/images/tasks/hallgasd.png',
      'assets/audio/tasks/hallgasd.mp3',
    );

    // --- HÉTKÖZNAPI LISTA (1..5) ---
    final weekdaySchedule = [
      {'id': tEbredes, 'time': '06:45'},
      {'id': tReggeli, 'time': '07:00'},
      {'id': tFogmosas, 'time': '07:15'},
      {'id': tOltozes, 'time': '07:25'},
      {'id': tKabatCipo, 'time': '07:30'},
      {'id': tIndulas, 'time': '07:45'},
      {'id': tEbedKezmosas, 'time': '11:30'},
      {'id': tSzabadjatek, 'time': '14:30'},
      {'id': tHazi, 'time': '16:00'},
      {'id': tElpakolas, 'time': '18:00'},
      {'id': tVacsora, 'time': '18:30'},
      {'id': tFurdes, 'time': '19:30'},
      {'id': tLefekves, 'time': '20:30'},
    ];

    // --- HÉTVÉGI LISTA (6..7) ---
    final weekendSchedule = [
      {'id': tEbredes, 'time': '08:00'},
      {'id': tReggeli, 'time': '08:30'},
      {'id': tFogmosas, 'time': '08:50'},
      {'id': tOltozes, 'time': '09:00'},
      {'id': tSzabadjatek, 'time': '09:30'},
      {'id': tEbedKezmosas, 'time': '12:30'},
      {'id': tSzabadjatek, 'time': '14:00'},
      {'id': tElpakolas, 'time': '18:00'},
      {'id': tVacsora, 'time': '18:30'},
      {'id': tFurdes, 'time': '19:30'},
      {'id': tLefekves, 'time': '20:30'},
    ];

    for (int day = 1; day <= 7; day++) {
      final scheduleToUse = (day <= 5) ? weekdaySchedule : weekendSchedule;

      for (int i = 0; i < scheduleToUse.length; i++) {
        await db.insert('daily_schedules', {
          'task_id': scheduleToUse[i]['id'] as int,
          'day_of_week': day,
          'order_index': i,
          'status': 'PENDING',
          'scheduled_time': scheduleToUse[i]['time'] as String,
          'reminder_minutes': 5,
          'is_overlay_enabled': 1,
        });
      }
    }
  }

  // ================= LEKÉRDEZÉSEK ÉS MŰVELETEK =================

  Future<List<DailyScheduleModel>> getSchedulesForDay(int dayOfWeek) async {
    final db = await instance.database;
    final result = await db.query(
      'daily_schedules',
      where: 'day_of_week = ?',
      whereArgs: [dayOfWeek],
      orderBy: 'scheduled_time ASC, order_index ASC',
    );
    return result.map((json) => DailyScheduleModel.fromMap(json)).toList();
  }

  Future<List<TaskModel>> getAllTasks() async {
    final db = await instance.database;
    final result = await db.query('tasks');
    return result.map((json) => TaskModel.fromMap(json)).toList();
  }

  Future<List<SubtaskModel>> getSubtasksForTask(int taskId) async {
    final db = await instance.database;
    final result = await db.query(
      'subtasks',
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'step_order ASC',
    );
    return result.map((json) => SubtaskModel.fromMap(json)).toList();
  }

  Future<int> insertTask(TaskModel task) async {
    final db = await instance.database;
    return await db.insert('tasks', task.toMap());
  }

  Future<int> insertSubtask(SubtaskModel subtask) async {
    final db = await instance.database;
    return await db.insert('subtasks', subtask.toMap());
  }

  Future<int> insertSchedule(DailyScheduleModel schedule) async {
    final db = await instance.database;
    return await db.insert('daily_schedules', schedule.toMap());
  }

  Future<int> updateScheduleCompletion(int scheduleId, bool isCompleted) async {
    final db = await instance.database;
    return await db.update(
      'daily_schedules',
      {
        'status': isCompleted ? 'COMPLETED' : 'PENDING',
        'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
      },
      where: 'id = ?',
      whereArgs: [scheduleId],
    );
  }

  Future<int> deleteSchedule(int scheduleId) async {
    final db = await instance.database;
    return await db.delete(
      'daily_schedules',
      where: 'id = ?',
      whereArgs: [scheduleId],
    );
  }

  Future<int> updateScheduleTime(int scheduleId, String newTime) async {
    final db = await instance.database;
    return await db.update(
      'daily_schedules',
      {'scheduled_time': newTime},
      where: 'id = ?',
      whereArgs: [scheduleId],
    );
  }

  // ================= JUTALOM MŰVELETEK =================

  Future<List<RewardModel>> getAllRewards() async {
    final db = await instance.database;
    final maps = await db.query('rewards', orderBy: 'points_cost ASC');
    return maps.map((map) => RewardModel.fromMap(map)).toList();
  }

  Future<int> insertReward(RewardModel reward) async {
    final db = await instance.database;
    return await db.insert('rewards', reward.toMap());
  }

  Future<int> deleteReward(int id) async {
    final db = await instance.database;
    return await db.delete('rewards', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateRewardRedeemed(int id, bool isRedeemed) async {
    final db = await instance.database;
    return await db.update(
      'rewards',
      {'is_redeemed': isRedeemed ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateRewardRoomPlacement(
    int id,
    bool isPlaced,
    double x,
    double y,
  ) async {
    final db = await instance.database;
    return await db.update(
      'rewards',
      {'is_placed': isPlaced ? 1 : 0, 'room_x': x, 'room_y': y},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= AAC KOMMUNIKÁCIÓS KÁRTYÁK ("BESZÉLŐ KÁRTYÁK") =================

  Future<void> _createAacTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS aac_cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        speech_text TEXT NOT NULL,
        category TEXT NOT NULL,
        image_type TEXT NOT NULL,
        image_path TEXT NOT NULL,
        audio_path TEXT
      )
    ''');
  }

  Future<void> _seedAacCards(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM aac_cards'),
    );

    if (count != null && count > 0) return;

    final defaultCards = [
      // 1. Szükségletek (NEEDS) – rövid, baráti szövegekkel
      {
        'title': 'Vizet kérek',
        'speech_text': 'Vizet kérek!',
        'category': 'NEEDS',
        'image_type': 'DEFAULT_ICON',
        'image_path': 'water_drop',
        'audio_path': 'assets/audio/aac/szomjas_vagyok.mp3',
      },
      {
        'title': 'Enni szeretnék',
        'speech_text': 'Enni szeretnék!',
        'category': 'NEEDS',
        'image_type': 'DEFAULT_ICON',
        'image_path': 'restaurant',
        'audio_path': 'assets/audio/aac/ehes_vagyok.mp3',
      },
      {
        'title': 'Mosdóba megyek',
        'speech_text': 'Mosdóba kell mennem!',
        'category': 'NEEDS',
        'image_type': 'DEFAULT_ICON',
        'image_path': 'wc',
        'audio_path': 'assets/audio/aac/mosdoba_kell_mennem.mp3',
      },
      {
        'title': 'Segíts nekem!',
        'speech_text': 'Segíts kérlek!',
        'category': 'NEEDS',
        'image_type': 'DEFAULT_ICON',
        'image_path': 'front_hand',
        'audio_path': 'assets/audio/aac/nem_tudom_egyedul_megcsinalni.mp3',
      },
      {
        'title': 'Pihenni szeretnék',
        'speech_text': 'Elfáradtam, pihenek.',
        'category': 'NEEDS',
        'image_type': 'DEFAULT_ICON',
        'image_path': 'bed',
        'audio_path': 'assets/audio/aac/elfaradtam.mp3',
      },
      {
        'title': 'Nem kérem / Állj!',
        'speech_text': 'Nem kérem, állj!',
        'category': 'NEEDS',
        'image_type': 'DEFAULT_ICON',
        'image_path': 'pan_tool_rounded',
        'audio_path': 'assets/audio/aac/ezt_most_nem_szeretnem.mp3',
      },

      // 2. Érzések (FEELINGS)
      {
        'title': 'Vidám vagyok',
        'speech_text': 'Vidám vagyok!',
        'category': 'FEELINGS',
        'image_type': 'DEFAULT_ICON',
        'image_path': 'sentiment_satisfied',
        'audio_path': 'assets/audio/aac/jol_erzem_magam.mp3',
      },
      {
        'title': 'Fáj valamim',
        'speech_text': 'Fáj valahol!',
        'category': 'FEELINGS',
        'image_type': 'DEFAULT_ICON',
        'image_path': 'healing',
        'audio_path': 'assets/audio/aac/faj_valahol.mp3',
      },
      {
        'title': 'Túl hangos',
        'speech_text': 'Túl nagy a zaj!',
        'category': 'FEELINGS',
        'image_type': 'DEFAULT_ICON',
        'image_path': 'volume_off',
        'audio_path': 'assets/audio/aac/tul_hangos_a_zaj.mp3',
      },
      {
        'title': 'Szomorú vagyok',
        'speech_text': 'Szomorú vagyok.',
        'category': 'FEELINGS',
        'image_type': 'DEFAULT_ICON',
        'image_path': 'sentiment_dissatisfied',
        'audio_path': 'assets/audio/aac/szomoru_vagyok.mp3',
      },
      {
        'title': 'Ölelj meg!',
        'speech_text': 'Kérek egy ölelést!',
        'category': 'FEELINGS',
        'image_type': 'DEFAULT_ICON',
        'image_path': 'favorite_rounded',
        'audio_path': 'assets/audio/aac/szeretnek_egy_olelest.mp3',
      },

      // 3. Tevékenységek (ACTIVITIES)
      {
        'title': 'Játsszunk!',
        'speech_text': 'Játsszunk együtt!',
        'category': 'ACTIVITIES',
        'image_type': 'DEFAULT_ICON',
        'image_path': 'sports_esports',
        'audio_path': 'assets/audio/aac/jatszani_szeretnek.mp3',
      },
      {
        'title': 'Mesét kérek',
        'speech_text': 'Nézzünk mesét!',
        'category': 'ACTIVITIES',
        'image_type': 'DEFAULT_ICON',
        'image_path': 'tv',
        'audio_path': 'assets/audio/aac/meset_szeretnek_nezni.mp3',
      },
      {
        'title': 'Sétáljunk!',
        'speech_text': 'Menjünk sétálni!',
        'category': 'ACTIVITIES',
        'image_type': 'DEFAULT_ICON',
        'image_path': 'directions_walk',
        'audio_path': 'assets/audio/aac/menjunk_ki_a_szabadba.mp3',
      },
    ];

    for (var card in defaultCards) {
      await db.insert('aac_cards', card);
    }
  }

  Future<List<AacCardModel>> getAllAacCards() async {
    final db = await instance.database;
    final maps = await db.query('aac_cards', orderBy: 'id ASC');
    return maps.map((map) => AacCardModel.fromMap(map)).toList();
  }

  Future<int> insertAacCard(AacCardModel card) async {
    final db = await instance.database;
    return await db.insert('aac_cards', card.toMap());
  }

  Future<int> deleteAacCard(int id) async {
    final db = await instance.database;
    return await db.delete('aac_cards', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> resetToDefaults() async {
    final db = await instance.database;

    await db.delete('subtasks');
    await db.delete('daily_schedules');
    await db.delete('tasks');
    await db.delete('aac_cards');

    await _seedDatabase(db);
    await _seedAacCards(db);
  }
}
