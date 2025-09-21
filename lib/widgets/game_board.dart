import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants.dart';
import '../models/tetromino.dart';
import '../providers/game_provider.dart';

/// ゲーム盤面ウィジェット
class GameBoard extends ConsumerWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameController = ref.read(gameProvider.notifier);

    return LayoutBuilder(builder: (context, constraints) {
      final double blockSize = min(constraints.maxWidth / boardWidth,
          constraints.maxHeight / boardHeight);

      return DragTarget<Tetromino>(
        onMove: (details) {
          final renderBox = context.findRenderObject() as RenderBox;
          final localOffset = renderBox.globalToLocal(details.offset);

          // 指の位置をグリッド座標に変換
          final int x = (localOffset.dx / blockSize).floor();
          final int y = (localOffset.dy / blockSize).floor();

          gameController.updateDragPosition(Point(x, y));
        },
        onLeave: (data) {
          //gameController.stopDragging();
        },
        onAcceptWithDetails: (details) {
          if (gameState.dragPosition != null) {
            if (gameState.autoDrop) {
              // Auto Drop モードの場合、最も下まで落とす
              var dropPosition = gameState.dragPosition!;
              while (_isValidPosition(details.data,
                  Point(dropPosition.x, dropPosition.y + 1), gameState.board)) {
                dropPosition = Point(dropPosition.x, dropPosition.y + 1);
              }
              gameController.placePiece(details.data, dropPosition);
            } else {
              // 通常モード
              gameController.placePiece(details.data, gameState.dragPosition!);
            }
          } else {
            gameController.stopDragging();
          }
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.black..withValues(alpha: 0.5),
              border: Border.all(color: Colors.grey[700]!, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomPaint(
              size: Size(blockSize * boardWidth, blockSize * boardHeight),
              painter: GameBoardPainter(
                board: gameState.board,
                blockSize: blockSize,
                draggingPiece: gameState.draggingPiece,
                dragPosition: gameState.dragPosition,
                isPreviewValid: gameState.isPreviewValid,
              ),
            ),
          );
        },
      );
    });
  }

  /// ヘルパーメソッド: ミノの配置可能判定
  static bool _isValidPosition(
      Tetromino piece, Point<int> position, List<List<Color?>> board) {
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
}

/// 盤面描画用CustomPainter
class GameBoardPainter extends CustomPainter {
  final List<List<Color?>> board;
  final double blockSize;
  final Tetromino? draggingPiece;
  final Point<int>? dragPosition;
  final bool isPreviewValid;

  GameBoardPainter({
    required this.board,
    required this.blockSize,
    this.draggingPiece,
    this.dragPosition,
    this.isPreviewValid = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // グリッド線を描画
    for (int i = 0; i <= boardWidth; i++) {
      canvas.drawLine(Offset(i * blockSize, 0),
          Offset(i * blockSize, size.height), gridPaint);
    }
    for (int i = 0; i <= boardHeight; i++) {
      canvas.drawLine(Offset(0, i * blockSize),
          Offset(size.width, i * blockSize), gridPaint);
    }

    // 確定したブロックを描画
    for (int y = 0; y < boardHeight; y++) {
      for (int x = 0; x < boardWidth; x++) {
        if (board[y][x] != null) {
          _drawBlock(canvas, Point(x, y), board[y][x]!);
        }
      }
    }

    // ドラッグ中のプレビュー（ゴースト）を描画
    if (draggingPiece != null && dragPosition != null) {
      var previewPosition = dragPosition!;

      // Auto Drop有効時は最下点を計算
      if (isPreviewValid) {
        var testPos = previewPosition;
        while (_isValidPosition(
            draggingPiece!, Point(testPos.x, testPos.y + 1), board)) {
          testPos = Point(testPos.x, testPos.y + 1);
        }
        previewPosition = testPos;
      }

      final color = isPreviewValid
          ? draggingPiece!.color.withValues(alpha: 0.5)
          : Colors.red.withValues(alpha: 0.5);
      for (final block in draggingPiece!.shape) {
        final pos =
            Point(previewPosition.x + block.x, previewPosition.y + block.y);
        _drawBlock(canvas, pos, color);
      }
    }
  }

  /// ミノの配置可能判定
  bool _isValidPosition(
      Tetromino piece, Point<int> position, List<List<Color?>> board) {
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

  void _drawBlock(Canvas canvas, Point<int> pos, Color color) {
    final rect = Rect.fromLTWH(
      pos.x * blockSize,
      pos.y * blockSize,
      blockSize,
      blockSize,
    );

    final paint = Paint()..color = color;
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(1.5), const Radius.circular(2)),
        paint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(1.5), const Radius.circular(2)),
        borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
