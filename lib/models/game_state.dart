import 'dart:math';
import 'package:flutter/material.dart';
import 'tetromino.dart';
import '../constants.dart'; // 定数ファイルをインポート

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

  GameState({
    required this.board,
    required this.queue,
    this.heldPiece,
    this.queueDisplayCount = 4,
    this.draggingPiece,
    this.dragPosition,
    this.isPreviewValid = false,
    this.canHold = true,
    this.autoDrop = true,
  });
  static List<Tetromino> generate7Bag() {
    final types = TetrominoType.values.toList()..shuffle();
    return types.map((type) => tetrominoes[type]!.clone).toList();
  }


  factory GameState.initial() {
    return GameState(
      board: List.generate(
          boardHeight, (_) => List.generate(boardWidth, (_) => null)),
      queue: generate7Bag(),
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
    );
  }
}