import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/tetromino.dart';
import '../constants.dart'; // 定数ファイルをインポート

final gameProvider = NotifierProvider<GameController, GameState>(GameController.new);

class GameController extends Notifier<GameState> {
  // ( ... GameControllerクラスのコード全体をここに貼り付け ... )
  final List<GameState> _history = [];

  @override
  GameState build() {
    return GameState.initial();
  }

  Tetromino _getNextPiece() {
    final nextPiece = state.queue.first;
    var newQueue = state.queue.sublist(1);
    if (newQueue.length < 7) {
      newQueue.addAll(GameState.generate7Bag());
    }
    state = state.copyWith(queue: newQueue);
    return nextPiece;
  }
  
  void rotatePiece(Tetromino piece) {
    piece.rotateRight();
    state = state.copyWith();
  }

  void holdPiece() {
    if (!state.canHold) return;

    final currentPiece = _getNextPiece();
    final pieceToHold = state.heldPiece;

    state = state.copyWith(
      heldPiece: currentPiece,
      queue: pieceToHold != null ? [pieceToHold, ...state.queue] : state.queue,
      canHold: false,
    );
  }

  void startDragging(Tetromino piece) {
    state = state.copyWith(draggingPiece: piece);
  }

  void stopDragging() {
    state = state.copyWith(
      clearDraggingPiece: true,
      clearDragPosition: true,
    );
  }

  /// 盤面上でのドラッグ位置を更新
  void updateDragPosition(Point<int> position) {
    if (state.draggingPiece == null) return;

    // <<< --- 変更ここから --- >>>
    final piece = state.draggingPiece!;
    
    // カーソル位置(position)からミノの中心座標を引いて、
    // ミノの原点(左上)が配置されるべき座標を計算する
    final adjustedPosition = Point<int>(
      (position.x - piece.center.x).round(),
      (position.y - piece.center.y).round(),
    );

    final isValid = _isValidPosition(piece, adjustedPosition, state.board);
    
    state = state.copyWith(
      // stateには計算後の座標を保存する
      dragPosition: adjustedPosition, 
      isPreviewValid: isValid,
    );
    // <<< --- 変更ここまで --- >>>
  }
  
  void placePiece(Tetromino piece, Point<int> position) {
    if (!_isValidPosition(piece, position, state.board)) {
      stopDragging();
      return;
    }
    
    _history.add(state);
    if (_history.length > 20) {
      _history.removeAt(0);
    }
    
    final newBoard = state.board.map((row) => List<Color?>.from(row)).toList();
    for (final block in piece.shape) {
        final x = position.x + block.x;
        final y = position.y + block.y;
        if (y >= 0 && y < boardHeight && x >= 0 && x < boardWidth) {
          newBoard[y][x] = piece.color;
        }
    }
    
    _clearLines(newBoard);

    if (piece.type == state.queue.first.type) {
      _getNextPiece();
    } else if (piece.type == state.heldPiece?.type) {
      final currentPiece = _getNextPiece();
      state = state.copyWith(heldPiece: currentPiece);
    }
    
    if (_isGameOver(newBoard)) {
        resetGame();
        return;
    }

    state = state.copyWith(
      board: newBoard,
      clearDraggingPiece: true,
      clearDragPosition: true,
      canHold: true,
    );
  }
  
  void undoLastMove() {
    if (_history.isNotEmpty) {
      state = _history.removeLast();
    }
  }

  void _clearLines(List<List<Color?>> board) {
    board.removeWhere((row) => row.every((cell) => cell != null));
    while (board.length < boardHeight) {
      board.insert(0, List.generate(boardWidth, (_) => null));
    }
  }

  bool _isValidPosition(Tetromino piece, Point<int> position, List<List<Color?>> board) {
    for (final block in piece.shape) {
      final x = position.x + block.x;
      final y = position.y + block.y;
      if (x < 0 || x >= boardWidth || y < 0 || y >= boardHeight) {
        return false;
      }
      if (board[y][x] != null) {
        return false;
      }
    }
    return true;
  }

  bool _isGameOver(List<List<Color?>> board) {
    final nextPiece = state.queue.first;
    return !_isValidPosition(nextPiece, const Point(3, 0), board);
  }

  void resetGame() {
    _history.clear();
    state = GameState.initial().copyWith(queueDisplayCount: state.queueDisplayCount);
  }

  void setQueueDisplayCount(int count) {
    state = state.copyWith(queueDisplayCount: count);
  }

  void setAutoDrop(bool value) {
    state = state.copyWith(autoDrop: value);
  }
}