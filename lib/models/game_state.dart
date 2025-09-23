import 'dart:math';
import 'package:flutter/material.dart';
import 'tetromino.dart';
import 'game_mode.dart';

/// ゲームの状態を管理するクラス
class GameState {
  // ( ... GameStateクラスのコード全体をここに貼り付け ... )
  final List<List<Color?>> board;
  final List<Tetromino> queue;
  final Tetromino? heldPiece;
  final int queueDisplayCount;
  final Tetromino? draggingPiece;
  final Point<int>? dragPosition;
  final bool isPreviewValid;
  final bool canHold;
  final bool autoDrop;
  final bool isLeftHanded;
  final GameMode mode; // 追加: ゲームモードを表すフィールド

  GameState({
    required this.board,
    required this.queue,
    this.heldPiece,
    this.queueDisplayCount = 5,
    this.draggingPiece,
    this.dragPosition,
    this.isPreviewValid = false,
    this.canHold = true,
    this.autoDrop = true,
    this.isLeftHanded = false,
    required this.mode, 
  });
  static List<Tetromino> generate7Bag() {
    final types = TetrominoType.values.toList()..shuffle();
    return types.map((type) => tetrominoes[type]!.clone).toList();
  }


  factory GameState.initial({GameMode? mode}) {
    // 1. 使用するモードを決定する (これはローカル変数)
    final selectedMode = mode ?? GameModes.defaultMode;

    // 2. 決定したモードを使って、インスタンス生成に必要なデータをすべて事前に準備する
    final initialBoard = selectedMode.createInitialBoard();
    final initialQueue = selectedMode.generateInitialQueue();
    return GameState(
      // モードクラスのメソッドを呼び出すだけで盤面が作れる
      board: initialBoard, 
      queue: initialQueue,
      mode: selectedMode,
    );
  }

  

  GameState copyWith({
    List<List<Color?>>? board,
    List<Tetromino>? queue,
    Tetromino? heldPiece,
    bool clearHeldPiece = false,
    int? queueDisplayCount,
    Tetromino? draggingPiece,
    bool clearDraggingPiece = false,
    Point<int>? dragPosition,
    bool clearDragPosition = false,
    bool? isPreviewValid,
    bool? canHold,
    bool? autoDrop,
    bool? isLeftHanded,
    GameMode? mode,
  }) {
    return GameState(
      board: board ?? this.board,
      queue: queue ?? this.queue,
      heldPiece: clearHeldPiece ? null : heldPiece ?? this.heldPiece,
      queueDisplayCount: queueDisplayCount ?? this.queueDisplayCount,
      draggingPiece: clearDraggingPiece ? null : draggingPiece ?? this.draggingPiece,
      dragPosition: clearDragPosition ? null : dragPosition ?? this.dragPosition,
      isPreviewValid: isPreviewValid ?? this.isPreviewValid,
      canHold: canHold ?? this.canHold,
      autoDrop: autoDrop ?? this.autoDrop,
      isLeftHanded: isLeftHanded ?? this.isLeftHanded,
      mode: mode ?? this.mode,
    );
  }
}