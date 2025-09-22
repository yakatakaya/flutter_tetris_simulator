import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tetromino.dart';
import '../providers/game_provider.dart';

/// テトリミノ表示用のコンテナ
class PieceContainer extends ConsumerWidget {
  final Tetromino? piece;
  final bool isCurrent;
  final bool isDraggable;

  const PieceContainer({
    super.key,
    this.piece,
    this.isCurrent = false,
    this.isDraggable = false, // デフォルトをfalseに変更し、意図しないドラッグを防ぐ
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameController = ref.read(gameProvider.notifier);
    if (piece == null) {
      return Container(
        decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.5))),
      );
    }

    final pieceWidget = GestureDetector(
      onTap: () {
        // ドラッグできないミノ（キューの2番目以降）は回転もできないようにする
        if (isDraggable || (piece == ref.read(gameProvider).heldPiece)) {
          gameController.rotatePiece(piece!);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: isCurrent
              ? Border.all(color: Colors.white, width: 2)
              : Border.all(color: Colors.grey.withValues(alpha: 0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: CustomPaint(
            painter: PiecePainter(piece: piece!),
          ),
        ),
      ),
    );

    if (isDraggable && piece != null) {
      return Draggable<Tetromino>(
        dragAnchorStrategy: pointerDragAnchorStrategy,
        data: piece!,
        feedback: Transform.translate( // <<< 変更点: Transform.translateでラップ
          // SizedBoxの半分のサイズだけ左上（マイナス方向）にずらす
          offset: const Offset(-50, -50), 
          child: SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(painter: PiecePainter(piece: piece!, isFeedback: true)),
          ),
        ), // <<< 変更点ここまで
        onDragStarted: () => gameController.startDragging(piece!),
        onDraggableCanceled: (velocity, offset) => gameController.stopDragging(),
        onDragEnd: (details) => gameController.stopDragging(),
        child: pieceWidget,
      );
    } else {
      return pieceWidget;
    }
  }
}

/// テトリミノ単体を描画するCustomPainter
class PiecePainter extends CustomPainter {
  final Tetromino piece;
  final bool isFeedback;

  PiecePainter({required this.piece, this.isFeedback = false});

  @override
  void paint(Canvas canvas, Size size) {
    final shape = piece.shape;
    final paint = Paint()..color = piece.color;

    // Oミノは中央に、Iミノは少しオフセット、他は標準で描画
    double offsetX = (piece.type == TetrominoType.O)
        ? 0.5
        : (piece.type == TetrominoType.I ? 0 : 0.5);
    double offsetY = (piece.type == TetrominoType.I) ? -0.5 : 0.5;

    // 4x4のグリッドに描画
    final blockSize = size.width / 4;

    for (final point in shape) {
      final rect = Rect.fromLTWH(
        (point.x + offsetX) * blockSize,
        (point.y + offsetY) * blockSize,
        blockSize,
        blockSize,
      );
      final rrect =
          RRect.fromRectAndRadius(rect.deflate(1.0), const Radius.circular(2));
      canvas.drawRRect(rrect, paint);
      if (isFeedback) {
        // ドラッグ中は半透明にする
        canvas.drawRRect(
            rrect, Paint()..color = Colors.black.withValues(alpha: 0.3));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
