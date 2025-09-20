import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../widgets/piece_container.dart';

/// 右側のサイドパネル (キュー、ホールド、設定)
class SidePanel extends ConsumerWidget {
  const SidePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return Column(
      children: [
        // Hold
        Expanded(
          flex: 1,
          child: Column(
            children: [
              const Text("HOLD", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 4),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: GestureDetector(
                     onTap: () => ref.read(gameProvider.notifier).holdPiece(),
                     child: PieceContainer(
                       piece: gameState.heldPiece,
                       isDraggable: gameState.heldPiece != null,
                     ),
                  )
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Queue
        Expanded(
          flex: 4,
          child: Column(
            children: [
              const Text("NEXT", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 4),
              ...List.generate(
                gameState.queueDisplayCount,
                (index) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: PieceContainer(
                        piece: gameState.queue[index],
                        isCurrent: index == 0,
                        isDraggable: index == 0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
