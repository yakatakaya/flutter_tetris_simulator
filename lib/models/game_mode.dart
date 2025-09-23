import 'package:flutter/material.dart';
import 'dart:math';
import './tetromino.dart';
import '../constants.dart';

// --- 1. モードを管理するFactory/Registryクラス ---
class GameModes {
  // アプリケーション内で利用可能な全モードのインスタンスを保持
  static final List<GameMode> all = [
    NormalMode(),
    DpcPerfectClearPracticeModeForSZ(),
    DpcPerfectClearPracticeModeForO(),
    MountainousStacking2Ideal(),
    MountainousStacking2SemiIdeal(),
    MountainousStacking2Compromise(),
    TsdOpener(),
    NakaakeRen(),
  ];

  // デフォルトのモード
  static GameMode get defaultMode => all.first;
}

// --- 2. 各モードの共通インターフェースを定義する抽象クラス ---
abstract class GameMode {
  /// UIに表示されるモード名
  String get displayName;

  /// このモードの初期盤面を生成する
  List<List<Color?>> createInitialBoard();

  List<Tetromino> generateInitialQueue();

  /// ミノキューを生成する
  List<Tetromino> generateQueue() {
    // 7-Bagアルゴリズム
    final types = TetrominoType.values.toList()..shuffle();
    return types.map((type) => tetrominoes[type]!.clone).toList();
  }

  // DropdownButtonなどでオブジェクトを比較するために、`==`と`hashCode`をオーバーライド
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameMode && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}

// --- 3. 具体的なモードクラスの実装 ---

/// 通常モード
class NormalMode extends GameMode {
  @override
  String get displayName => 'Normal';

  @override
  List<List<Color?>> createInitialBoard() {
    return List.generate(
        boardHeight, (_) => List.generate(boardWidth, (_) => null));
  }

  @override
  List<Tetromino> generateInitialQueue() {
    return generateQueue();
  }
}

/// TSDパフェ S or Z余り練習モード
class DpcPerfectClearPracticeModeForSZ extends GameMode {
  @override
  String get displayName => 'DPC(S/Z余り)';

  @override
  List<List<Color?>> createInitialBoard() {
    return List.generate(
        boardHeight, (_) => List.generate(boardWidth, (_) => null));
  }

  @override
  List<Tetromino> generateInitialQueue() {
    // 空のListを用意
    List<Tetromino> queue = [];
    // SとZどちらかをランダムで一つ追加
    final random = Random();
    int choice = random.nextInt(2);

    if (choice == 0) {
      queue.add(tetrominoes[TetrominoType.S]!.clone);
    } else {
      queue.add(tetrominoes[TetrominoType.Z]!.clone);
    }
    queue.addAll(generateQueue());
    return queue;
  }
}

/// TSDパフェ O余り練習モード
class DpcPerfectClearPracticeModeForO extends GameMode {
  @override
  String get displayName => 'DPC(O余り)';

  @override
  List<List<Color?>> createInitialBoard() {
    return List.generate(
        boardHeight, (_) => List.generate(boardWidth, (_) => null));
  }

  @override
  List<Tetromino> generateInitialQueue() {
    // 空のListを用意
    List<Tetromino> queue = [];
    queue.add(tetrominoes[TetrominoType.O]!.clone);
    queue.addAll(generateQueue());
    return queue;
  }
}

/// 山岳積み2号理想形練習モード
class MountainousStacking2Ideal extends GameMode {
  @override
  String get displayName => '山岳積み2号-理想形';

  @override
  List<List<Color?>> createInitialBoard() {
    List<List<Color?>> board = [
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [Colors.grey, Colors.grey, Colors.grey, Colors.grey, null, null, null, null, null, null],
      [Colors.grey, Colors.grey, Colors.grey, Colors.grey, null, null, Colors.grey, null, null, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, null, Colors.grey, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, Colors.grey,Colors.grey, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, Colors.grey, null, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey],
    ];
    final random = Random();
    bool isReverse = random.nextBool();
    if (isReverse) {
      board = board.map((row) => row.reversed.toList()).toList();
    }
    return board;
  }

  @override
  List<Tetromino> generateInitialQueue() {
    // 空のListを用意
    List<Tetromino> queue = [];
    queue.add(tetrominoes[TetrominoType.T]!.clone);
    queue.addAll(generateQueue());
    return queue;
  }
}

/// 山岳積み2号準理想形練習モード
class MountainousStacking2SemiIdeal extends GameMode {
  @override
  String get displayName => '山岳積み2号-準理想形';

  @override
  List<List<Color?>> createInitialBoard() {
    List<List<Color?>> board = [
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, Colors.grey, null, null, Colors.grey, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, null, Colors.grey, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, Colors.grey, null, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey],
    ];
    final random = Random();
    bool isReverse = random.nextBool();
    if (isReverse) {
      board = board.map((row) => row.reversed.toList()).toList();
    }
    return board;
  }

  @override
  List<Tetromino> generateInitialQueue() {
    // 空のListを用意
    List<Tetromino> queue = [];
    queue.add(tetrominoes[TetrominoType.T]!.clone);
    queue.addAll(generateQueue());
    return queue;
  }
}

/// 山岳積み2号妥協形練習モード
class MountainousStacking2Compromise extends GameMode {
  @override
  String get displayName => '山岳積み2号-妥協形';

  @override
  List<List<Color?>> createInitialBoard() {
    List<List<Color?>> board = [
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, Colors.grey, Colors.grey, null, null, null, null, null, null, null],
      [Colors.grey, Colors.grey, null, null, null, null, null, null, null, null],
      [Colors.grey, Colors.grey, Colors.grey, Colors.grey, null, null, Colors.grey, null, null, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, null, Colors.grey, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, Colors.grey, null, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey],
    ];
    final random = Random();
    bool isReverse = random.nextBool();
    if (isReverse) {
      board = board.map((row) => row.reversed.toList()).toList();
    }
    return board;
  }

  @override
  List<Tetromino> generateInitialQueue() {
    // 空のListを用意
    List<Tetromino> queue = [];
    queue.add(tetrominoes[TetrominoType.T]!.clone);
    queue.addAll(generateQueue());
    return queue;
  }
}

/// 開幕TSD練習モード
class TsdOpener extends GameMode {
  @override
  String get displayName => '開幕TSD';

  @override
  List<List<Color?>> createInitialBoard() {
    List<List<Color?>> board = [
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, null, null, null, null, null, null, null],
      [null, null, null, Colors.grey, Colors.grey, Colors.grey, null, null, null, null],
      [Colors.grey, null, null, Colors.grey, Colors.grey, Colors.grey, Colors.grey, null, null, null],
      [Colors.grey, null, null, null, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, null, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey],
    ];
    final random = Random();
    bool isReverse = random.nextBool();
    if (isReverse) {
      board = board.map((row) => row.reversed.toList()).toList();
    }
    return board;
  }

  @override
  List<Tetromino> generateInitialQueue() {
    // 空のListを用意
    List<Tetromino> queue = [];
    queue.add(tetrominoes[TetrominoType.T]!.clone);
    queue.addAll(generateQueue());
    return queue;
  }
}


/// 中空けREN練習モード
class NakaakeRen extends GameMode {
  @override
  String get displayName => '中空けREN';

  @override
  List<List<Color?>> createInitialBoard() {
    List<List<Color?>> board = [
      [Colors.grey, Colors.grey, Colors.grey, null, null, null, null, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, null, null, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, null, null, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, null, null, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, null, null, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, null, null, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, null, null, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, null, null, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, null, null, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, null, null, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, null, null, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, null, null, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, null, null, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, null, null, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, null, null, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, null, null, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, null, null, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, null, null, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, Colors.grey, Colors.grey, Colors.grey, Colors.grey, Colors.grey],
      [Colors.grey, Colors.grey, Colors.grey, null, null, null, Colors.grey, Colors.grey, Colors.grey, Colors.grey],
    ];
    return board;
  }

  @override
  List<Tetromino> generateInitialQueue() {
    // 空のListを用意
    List<Tetromino> queue = [];
    queue.addAll(generateQueue());
    // SとZどちらかをランダムで一つ追加
    final random = Random();
    int popCount = random.nextInt(7);

    // choiceの数だけキューからミノを取り除く
    for (int i = 0; i < popCount; i++) {
      queue.removeAt(0);
    }

    if (queue.length < 7) {
      queue.addAll(generateQueue());
    }
    return queue;
  }
}
