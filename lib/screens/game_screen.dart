import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../widgets/game_board.dart';
import '../widgets/side_panel.dart';
import '../models/game_mode.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ( ... GameScreenのbuildメソッドのコードをここに貼り付け ... )
    final size = MediaQuery.of(context).size;
    final isPortrait = size.height > size.width;
    final gameState = ref.watch(gameProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: isPortrait
                      ? gameState.isLeftHanded
                          ? Row(children: [
                              Expanded(flex: 1, child: SidePanel()),
                              const SizedBox(width: 8),
                              const Expanded(
                                flex: 3,
                                child: GameBoard(),
                              )
                            ])
                          : Row(
                              children: [
                                const Expanded(
                                  flex: 3,
                                  child: GameBoard(),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 1,
                                  child: SidePanel(),
                                ),
                              ],
                            )
                      : Center(
                          child: AspectRatio(
                          aspectRatio: 9 / 16,
                          child: Row(
                            children: [
                              const Expanded(
                                flex: 3,
                                child: GameBoard(),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: SidePanel(),
                              ),
                            ],
                          ),
                        )),
                ),
                const SizedBox(height: 8),
                Consumer(
                  builder: (context, ref, _) {
                    final gameController = ref.read(gameProvider.notifier);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.undo, color: Colors.grey),
                          onPressed: () => gameController.undoLastMove(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.grey),
                          onPressed: () => gameController.resetGame(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.grey),
                          onPressed: () => _showSettingsDialog(context, ref),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, WidgetRef ref) {
    final gameController = ref.read(gameProvider.notifier);
    final gameState = ref.read(gameProvider);

    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;

        return AlertDialog(
          backgroundColor: const Color(0xFF2a2a2a),
          title: const Text('Settings'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 280, // スマホでも最低限見やすい幅
              maxWidth: screenWidth * 1.0, // 画面幅の 90% を上限に
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Mode"),
                    DropdownButton<GameMode>(
                      value: gameState.mode,
                      items: GameModes.all.map((mode) {
                        return DropdownMenuItem(
                          value: mode,
                          child: Text(mode.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          gameController.changeMode(value);
                          Navigator.of(context).pop();
                          _showSettingsDialog(context, ref);
                        }
                      },
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Queue Count"),
                    DropdownButton<int>(
                      value: gameState.queueDisplayCount,
                      items: List.generate(7, (i) => i + 1)
                          .map((e) => DropdownMenuItem(
                              value: e, child: Text(e.toString())))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          gameController.setQueueDisplayCount(value);
                          Navigator.of(context).pop();
                          _showSettingsDialog(context, ref);
                        }
                      },
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Auto Drop"),
                    Consumer(
                      builder: (context, ref, _) {
                        final isAutoDrop = ref.watch(gameProvider).autoDrop;
                        return ToggleButtons(
                          isSelected: [isAutoDrop],
                          onPressed: (index) {
                            gameController.setAutoDrop(!isAutoDrop);
                          },
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: isAutoDrop
                                  ? const Text("ON")
                                  : const Text("OFF"),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Left Handed Mode"),
                    Consumer(
                      builder: (context, ref, _) {
                        final isLeftHanded =
                            ref.watch(gameProvider).isLeftHanded;
                        return ToggleButtons(
                          isSelected: [isLeftHanded],
                          onPressed: (index) {
                            gameController.setIsLeftHanded(!isLeftHanded);
                          },
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: isLeftHanded
                                  ? const Text("ON")
                                  : const Text("OFF"),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            )
          ],
        );
      },
    );
  }
}
