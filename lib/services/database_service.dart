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

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE routines (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        iconCodePoint INTEGER NOT NULL,
        image_path TEXT,
        colorValue INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE routine_steps (
        id TEXT PRIMARY KEY,
        routineId TEXT NOT NULL,
        title TEXT NOT NULL,
        iconCodePoint INTEGER NOT NULL,
        image_path TEXT,
        isCompleted INTEGER NOT NULL,
        sortOrder INTEGER NOT NULL,
        audio_path TEXT,
        FOREIGN KEY (routineId) REFERENCES routines (id) ON DELETE CASCADE
      )
    ''');

    await _seedInitialData(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute(
          'ALTER TABLE routine_steps ADD COLUMN audio_path TEXT;',
        );
      } catch (_) {}
    }
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE routines ADD COLUMN image_path TEXT;');
      } catch (_) {}
      try {
        await db.execute(
          'ALTER TABLE routine_steps ADD COLUMN image_path TEXT;',
        );
      } catch (_) {}
      await db.delete('routine_steps');
      await db.delete('routines');
      await _seedInitialData(db);
    }
  }

  Future<void> _seedInitialData(Database db) async {
    for (var routine in sampleRoutines) {
      await db.insert('routines', {
        'id': routine.id,
        'title': routine.title,
        'description': routine.description,
        'iconCodePoint': routine.icon.codePoint,
        'image_path': routine.imagePath,
        'colorValue': routine.themeColor.toARGB32(),
      });

      for (int i = 0; i < routine.steps.length; i++) {
        final step = routine.steps[i];
        await db.insert('routine_steps', {
          'id': step.id,
          'routineId': routine.id,
          'title': step.title,
          'iconCodePoint': step.icon.codePoint,
          'image_path': step.imagePath,
          'isCompleted': step.isCompleted ? 1 : 0,
          'sortOrder': i,
          'audio_path': step.audioPath,
        });
      }
    }
  }

  IconData _buildIcon(int codePoint) {
    // ignore: non_const_argument_for_const_parameter
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

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
          imagePath: sMap['image_path'] as String?,
          isCompleted: (sMap['isCompleted'] as int) == 1,
          audioPath: sMap['audio_path'] as String?,
        );
      }).toList();

      final routineIconCode = (rMap['iconCodePoint'] as num).toInt();
      routines.add(
        Routine(
          id: routineId,
          title: rMap['title'] as String,
          description: rMap['description'] as String,
          icon: _buildIcon(routineIconCode),
          imagePath: rMap['image_path'] as String?,
          themeColor: Color((rMap['colorValue'] as num).toInt()),
          steps: steps,
        ),
      );
    }

    return routines;
  }

  Future<void> updateStepStatus(String stepId, bool isCompleted) async {
    final db = await database;
    await db.update(
      'routine_steps',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [stepId],
    );
  }

  Future<void> resetRoutineSteps(String routineId) async {
    final db = await database;
    await db.update(
      'routine_steps',
      {'isCompleted': 0},
      where: 'routineId = ?',
      whereArgs: [routineId],
    );
  }

  Future<void> addRoutine(Routine routine) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('routines', {
        'id': routine.id,
        'title': routine.title,
        'description': routine.description,
        'iconCodePoint': routine.icon.codePoint,
        'image_path': routine.imagePath,
        'colorValue': routine.themeColor.toARGB32(),
      });

      for (int i = 0; i < routine.steps.length; i++) {
        final step = routine.steps[i];
        await txn.insert('routine_steps', {
          'id': step.id,
          'routineId': routine.id,
          'title': step.title,
          'iconCodePoint': step.icon.codePoint,
          'image_path': step.imagePath,
          'isCompleted': 0,
          'sortOrder': i,
          'audio_path': step.audioPath,
        });
      }
    });
  }

  Future<void> deleteRoutine(String routineId) async {
    final db = await database;
    await db.delete('routines', where: 'id = ?', whereArgs: [routineId]);
    await db.delete(
      'routine_steps',
      where: 'routineId = ?',
      whereArgs: [routineId],
    );
  }

  Future<void> updateRoutine(Routine routine) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update(
        'routines',
        {
          'title': routine.title,
          'description': routine.description,
          'iconCodePoint': routine.icon.codePoint,
          'image_path': routine.imagePath,
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
          'image_path': step.imagePath,
          'isCompleted': step.isCompleted ? 1 : 0,
          'sortOrder': i,
          'audio_path': step.audioPath,
        });
      }
    });
  }
}
