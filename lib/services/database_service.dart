import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../data/models/routine_step_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('iranytu.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Verziót 2-re emeljük, hogy ha létezik a régi db, hozzáadja az audio_path oszlopot
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Rutinok táblája
    await db.execute('''
      CREATE TABLE routines (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        iconCodePoint INTEGER NOT NULL,
        colorValue INTEGER NOT NULL
      )
    ''');

    // 2. Lépések táblája
    await db.execute('''
      CREATE TABLE routine_steps (
        id TEXT PRIMARY KEY,
        routineId TEXT NOT NULL,
        title TEXT NOT NULL,
        iconCodePoint INTEGER NOT NULL,
        isCompleted INTEGER NOT NULL,
        sortOrder INTEGER NOT NULL,
        audio_path TEXT,
        FOREIGN KEY (routineId) REFERENCES routines (id) ON DELETE CASCADE
      )
    ''');

    // Alapértelmezett mintaadatok betöltése az adatbázis első indulásakor
    await _seedInitialData(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Ha már létezett az adatbázis v1-gyel, hozzáadjuk az oszlopot hiba nélkül
      await db.execute('ALTER TABLE routine_steps ADD COLUMN audio_path TEXT;');
    }
  }

  Future<void> _seedInitialData(Database db) async {
    for (var routine in sampleRoutines) {
      await db.insert('routines', {
        'id': routine.id,
        'title': routine.title,
        'description': routine.description,
        'iconCodePoint': routine.icon.codePoint,
        'colorValue': routine.themeColor.toARGB32(),
      });

      for (int i = 0; i < routine.steps.length; i++) {
        final step = routine.steps[i];
        await db.insert('routine_steps', {
          'id': step.id,
          'routineId': routine.id,
          'title': step.title,
          'iconCodePoint': step.icon.codePoint,
          'isCompleted': step.isCompleted ? 1 : 0,
          'sortOrder': i,
          'audio_path': step.audioPath,
        });
      }
    }
  }

  // Segédfüggvény a dinamikus ikonok betöltéséhez
  IconData _buildIcon(int codePoint) {
    // ignore: non_const_argument_for_const_parameter
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  // --- LEKÉRDEZÉSEK ÉS MÓDOSÍTÁSOK ---

  // Összes rutin betöltése a hozzájuk tartozó lépésekkel
  Future<List<Routine>> getRoutines() async {
    final db = await database;
    final routineMaps = await db.query('routines');

    List<Routine> routines = [];

    for (var rMap in routineMaps) {
      final routineId = rMap['id'] as String;
      final stepMaps = await db.query(
        'routine_steps',
        where: 'routineId = ?',
        whereArgs: [routineId],
        orderBy: 'sortOrder ASC',
      );

      final steps = stepMaps.map((sMap) {
        final iconCode = (sMap['iconCodePoint'] as num).toInt();
        return RoutineStep(
          id: sMap['id'] as String,
          title: sMap['title'] as String,
          icon: _buildIcon(iconCode),
          isCompleted: (sMap['isCompleted'] as int) == 1,
          audioPath: sMap['audio_path'] as String?, // <-- KIOLVASÁS
        );
      }).toList();

      final routineIconCode = (rMap['iconCodePoint'] as num).toInt();
      routines.add(
        Routine(
          id: routineId,
          title: rMap['title'] as String,
          description: rMap['description'] as String,
          icon: _buildIcon(routineIconCode),
          themeColor: Color((rMap['colorValue'] as num).toInt()),
          steps: steps,
        ),
      );
    }

    return routines;
  }

  // Lépés állapotának frissítése (pipálás)
  Future<void> updateStepStatus(String stepId, bool isCompleted) async {
    final db = await database;
    await db.update(
      'routine_steps',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [stepId],
    );
  }

  // Rutin lépéseinek visszaállítása alaphelyzetbe (újrakezdés gombhoz)
  Future<void> resetRoutineSteps(String routineId) async {
    final db = await database;
    await db.update(
      'routine_steps',
      {'isCompleted': 0},
      where: 'routineId = ?',
      whereArgs: [routineId],
    );
  }

  // Új rutin hozzáadása lépésekkel együtt (Szülői funkció)
  Future<void> addRoutine(Routine routine) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('routines', {
        'id': routine.id,
        'title': routine.title,
        'description': routine.description,
        'iconCodePoint': routine.icon.codePoint,
        'colorValue': routine.themeColor.toARGB32(),
      });

      for (int i = 0; i < routine.steps.length; i++) {
        final step = routine.steps[i];
        await txn.insert('routine_steps', {
          'id': step.id,
          'routineId': routine.id,
          'title': step.title,
          'iconCodePoint': step.icon.codePoint,
          'isCompleted': 0,
          'sortOrder': i,
          'audio_path': step.audioPath, // <-- MENTÉS AZ ÚJ RUTINOKHOZ!
        });
      }
    });
  }

  // Rutin törlése (CASCADE miatt a lépései is törlődnek)
  Future<void> deleteRoutine(String routineId) async {
    final db = await database;
    await db.delete('routines', where: 'id = ?', whereArgs: [routineId]);
    await db.delete(
      'routine_steps',
      where: 'routineId = ?',
      whereArgs: [routineId],
    );
  }

  // Rutin és lépéseinek frissítése (Szülői szerkesztés)
  Future<void> updateRoutine(Routine routine) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'routines',
        {
          'title': routine.title,
          'description': routine.description,
          'iconCodePoint': routine.icon.codePoint,
          'colorValue': routine.themeColor.toARGB32(),
        },
        where: 'id = ?',
        whereArgs: [routine.id],
      );

      await txn.delete(
        'routine_steps',
        where: 'routineId = ?',
        whereArgs: [routine.id],
      );

      for (int i = 0; i < routine.steps.length; i++) {
        final step = routine.steps[i];
        await txn.insert('routine_steps', {
          'id': step.id,
          'routineId': routine.id,
          'title': step.title,
          'iconCodePoint': step.icon.codePoint,
          'isCompleted': step.isCompleted ? 1 : 0,
          'sortOrder': i,
          'audio_path': step.audioPath, // <-- MENTÉS SZERKESZTÉSKOR
        });
      }
    });
  }
}
