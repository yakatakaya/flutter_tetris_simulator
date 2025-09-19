import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- 定数定義 (Constants) ---
// ゲームボードのサイズ
const int boardWidth = 10;
const int boardHeight = 20;

// --- モデル定義 (Data Models) ---

/// テトリミノの種類を定義するenum
enum TetrominoType { I, O, T, S, Z, J, L }

/// テトリミノのデータクラス
class Tetromino {
  final TetrominoType type;
  final Color color;
  // 回転ごとのブロック形状を保持するリスト
  final List<List<Point<int>>> rotations;
  int _rotationIndex = 0;

  Tetromino({
    required this.type,
    required this.color,
    required this.rotations,
  });

  // 現在の回転状態でのブロック形状を取得
  List<Point<int>> get shape => rotations[_rotationIndex];

  // テトリミノをコピーして新しいインスタンスを作成
  Tetromino get clone => Tetromino(
        type: type,
        color: color,
        rotations: rotations,
      ).._rotationIndex = _rotationIndex;

  /// 右に90度回転させる
  void rotateRight() {
    _rotationIndex = (_rotationIndex + 1) % rotations.length;
  }
}

/// 各テトリミノの形状と色を定義
final Map<TetrominoType, Tetromino> tetrominoes = {
  TetrominoType.I: Tetromino(
    type: TetrominoType.I,
    color: Colors.cyan,
    rotations: [
      [const Point(0, 1), const Point(1, 1), const Point(2, 1), const Point(3, 1)],
      [const Point(2, 0), const Point(2, 1), const Point(2, 2), const Point(2, 3)],
      [const Point(0, 2), const Point(1, 2), const Point(2, 2), const Point(3, 2)],
      [const Point(1, 0), const Point(1, 1), const Point(1, 2), const Point(1, 3)],
    ],
  ),
  TetrominoType.O: Tetromino(
    type: TetrominoType.O,
    color: Colors.yellow,
    rotations: [
      [const Point(1, 0), const Point(2, 0), const Point(1, 1), const Point(2, 1)],
    ],
  ),
  TetrominoType.T: Tetromino(
    type: TetrominoType.T,
    color: Colors.purple,
    rotations: [
      [const Point(1, 0), const Point(0, 1), const Point(1, 1), const Point(2, 1)],
      [const Point(1, 0), const Point(1, 1), const Point(2, 1), const Point(1, 2)],
      [const Point(0, 1), const Point(1, 1), const Point(2, 1), const Point(1, 2)],
      [const Point(1, 0), const Point(0, 1), const Point(1, 1), const Point(1, 2)],
    ],
  ),
  TetrominoType.S: Tetromino(
    type: TetrominoType.S,
    color: Colors.green,
    rotations: [
      [const Point(1, 0), const Point(2, 0), const Point(0, 1), const Point(1, 1)],
      [const Point(1, 0), const Point(1, 1), const Point(2, 1), const Point(2, 2)],
    ],
  ),
  TetrominoType.Z: Tetromino(
    type: TetrominoType.Z,
    color: Colors.red,
    rotations: [
      [const Point(0, 0), const Point(1, 0), const Point(1, 1), const Point(2, 1)],
      [const Point(2, 0), const Point(1, 1), const Point(2, 1), const Point(1, 2)],
    ],
  ),
  TetrominoType.J: Tetromino(
    type: TetrominoType.J,
    color: Colors.blue,
    rotations: [
      [const Point(0, 0), const Point(0, 1), const Point(1, 1), const Point(2, 1)],
      [const Point(1, 0), const Point(2, 0), const Point(1, 1), const Point(1, 2)],
      [const Point(0, 1), const Point(1, 1), const Point(2, 1), const Point(2, 2)],
      [const Point(1, 0), const Point(1, 1), const Point(0, 2), const Point(1, 2)],
    ],
  ),
  TetrominoType.L: Tetromino(
    type: TetrominoType.L,
    color: Colors.orange,
    rotations: [
      [const Point(2, 0), const Point(0, 1), const Point(1, 1), const Point(2, 1)],
      [const Point(1, 0), const Point(1, 1), const Point(1, 2), const Point(2, 2)],
      [const Point(0, 1), const Point(1, 1), const Point(2, 1), const Point(0, 2)],
      [const Point(0, 0), const Point(1, 0), const Point(1, 1), const Point(1, 2)],
    ],
  ),
};

/// ゲームの状態を管理するクラス
class GameState {
  // 盤面の状態（各セルの色情報）
  final List<List<Color?>> board;
  // テトリミノのキュー
  final List<Tetromino> queue;
  // ホールド中のテトリミノ
  final Tetromino? heldPiece;
  // キューの表示数
  final int queueDisplayCount;
  // ドラッグ中のミノの情報
  final Tetromino? draggingPiece;
  // ドラッグ中のミノの位置
  final Point<int>? dragPosition;
  // プレビューが配置可能か
  final bool isPreviewValid;
  // ホールドが可能か
  final bool canHold;
  // 自動ドロップ設定
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

  // 初期状態を生成するファクトリコンストラクタ
  factory GameState.initial() {
    return GameState(
      board: List.generate(
          boardHeight, (_) => List.generate(boardWidth, (_) => null)),
      queue: _generate7Bag(),
    );
  }

  // 7-Bagアルゴリズムでミノのリストを生成
  static List<Tetromino> _generate7Bag() {
    final types = TetrominoType.values.toList()..shuffle();
    return types.map((type) => tetrominoes[type]!.clone).toList();
  }

  // 状態をコピーして新しいインスタンスを作成
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

// --- 状態管理 (State Management with Riverpod) ---

final gameProvider = NotifierProvider<GameController, GameState>(GameController.new);

class GameController extends Notifier<GameState> {
  final List<GameState> _history = [];

  @override
  GameState build() {
    return GameState.initial();
  }

  /// キューから新しいミノを取得し、キューを補充
  Tetromino _getNextPiece() {
    final nextPiece = state.queue.first;
    var newQueue = state.queue.sublist(1);
    if (newQueue.length < 7) {
      newQueue.addAll(GameState._generate7Bag());
    }
    state = state.copyWith(queue: newQueue);
    return nextPiece;
  }
  
  /// ミノを回転させる
  void rotatePiece(Tetromino piece) {
    piece.rotateRight();
    state = state.copyWith(); // UIを更新
  }

  /// 現在のミノをホールドする
  void holdPiece() {
    if (!state.canHold) return;

    final currentPiece = _getNextPiece();
    final pieceToHold = state.heldPiece;

    state = state.copyWith(
      heldPiece: currentPiece,
      // ホールドが空だった場合は、キューから新しいミノを取得
      queue: pieceToHold != null ? [pieceToHold, ...state.queue] : state.queue,
      canHold: false,
    );
  }

  /// ドラッグ操作を開始
  void startDragging(Tetromino piece) {
    state = state.copyWith(draggingPiece: piece);
  }

  /// ドラッグ操作を終了（盤面外でドロップ）
  void stopDragging() {
    state = state.copyWith(
      clearDraggingPiece: true,
      clearDragPosition: true,
    );
  }

  /// 盤面上でのドラッグ位置を更新
  void updateDragPosition(Point<int> position) {
    if (state.draggingPiece == null) return;
    final isValid = _isValidPosition(state.draggingPiece!, position, state.board);
    state = state.copyWith(
      dragPosition: position,
      isPreviewValid: isValid,
    );
  }
  
  /// ミノを指定した位置に配置する
  void placePiece(Tetromino piece, Point<int> position) {
    if (!_isValidPosition(piece, position, state.board)) {
      stopDragging();
      return;
    }
    
    // 現在の状態を履歴に保存
    _history.add(state);
    if (_history.length > 20) { // 履歴が長くなりすぎないように制限
      _history.removeAt(0);
    }
    
    // 盤面を更新
    final newBoard = state.board.map((row) => List<Color?>.from(row)).toList();
    for (final block in piece.shape) {
        final x = position.x + block.x;
        final y = position.y + block.y;
        if (y >= 0 && y < boardHeight && x >= 0 && x < boardWidth) {
          newBoard[y][x] = piece.color;
        }
    }
    
    _clearLines(newBoard);

    // ドラッグしていたミノがキューのものかホールドのものか判定
    if (piece.type == state.queue.first.type) {
      _getNextPiece(); // キューを進める
    } else if (piece.type == state.heldPiece?.type) {
      // ホールドから配置した場合、キューの先頭をホールドに移動
      final currentPiece = _getNextPiece();
      state = state.copyWith(heldPiece: currentPiece);
    }
    
    // ゲームオーバーチェック
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
  
  /// 一手前に戻す
  void undoLastMove() {
    if (_history.isNotEmpty) {
      state = _history.removeLast();
    }
  }

  /// 揃ったラインを消去する
  void _clearLines(List<List<Color?>> board) {
    board.removeWhere((row) => row.every((cell) => cell != null));
    while (board.length < boardHeight) {
      board.insert(0, List.generate(boardWidth, (_) => null));
    }
  }

  /// 指定した位置にミノが配置可能かチェック
  bool _isValidPosition(Tetromino piece, Point<int> position, List<List<Color?>> board) {
    for (final block in piece.shape) {
      final x = position.x + block.x;
      final y = position.y + block.y;
      if (x < 0 || x >= boardWidth || y < 0 || y >= boardHeight) {
        return false; // 盤面外
      }
      if (board[y][x] != null) {
        return false; // 他のブロックと衝突
      }
    }
    return true;
  }

  /// ゲームオーバーをチェック
  bool _isGameOver(List<List<Color?>> board) {
    final nextPiece = state.queue.first;
    // 次のミノが出現位置(中央上部)に配置できない場合はゲームオーバー
    return !_isValidPosition(nextPiece, const Point(3, 0), board);
  }

  /// ゲームをリセットする
  void resetGame() {
    _history.clear();
    state = GameState.initial().copyWith(queueDisplayCount: state.queueDisplayCount);
  }

  /// キューの表示数を変更
  void setQueueDisplayCount(int count) {
    state = state.copyWith(queueDisplayCount: count);
  }

  /// 自動ドロップ設定を切り替え
  void setAutoDrop(bool value) {
    state = state.copyWith(autoDrop: value);
  }
}

// --- UI部分 (Widgets) ---

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tetris Simulator',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF121212),
        fontFamily: 'Roboto',
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isPortrait = size.height > size.width;

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
                    ? Row(
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
                        )
                      ),
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
              return AlertDialog(
                  backgroundColor: const Color(0xFF2a2a2a),
                  title: const Text('Settings'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Queue Count"),
                          DropdownButton<int>(
                            value: gameState.queueDisplayCount,
                            items: List.generate(7, (i) => i + 1)
                                .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                gameController.setQueueDisplayCount(value);
                                Navigator.of(context).pop(); // ダイアログを閉じて再表示
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
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Text("ON"),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                      )
                  ],
              );
          });
  }
}
/// ゲーム盤面ウィジェット
class GameBoard extends ConsumerWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameController = ref.read(gameProvider.notifier);

    return LayoutBuilder(builder: (context, constraints) {
      final double blockSize = min(constraints.maxWidth / boardWidth, constraints.maxHeight / boardHeight);

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
              while (_isValidPosition(details.data, Point(dropPosition.x, dropPosition.y + 1), gameState.board)) {
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
  static bool _isValidPosition(Tetromino piece, Point<int> position, List<List<Color?>> board) {
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
      canvas.drawLine(Offset(i * blockSize, 0), Offset(i * blockSize, size.height), gridPaint);
    }
    for (int i = 0; i <= boardHeight; i++) {
      canvas.drawLine(Offset(0, i * blockSize), Offset(size.width, i * blockSize), gridPaint);
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
        while (_isValidPosition(draggingPiece!, Point(testPos.x, testPos.y + 1), board)) {
          testPos = Point(testPos.x, testPos.y + 1);
        }
        previewPosition = testPos;
      }
      
      final color = isPreviewValid ? draggingPiece!.color.withValues(alpha: 0.5) : Colors.red.withValues(alpha: 0.5);
      for (final block in draggingPiece!.shape) {
        final pos = Point(previewPosition.x + block.x, previewPosition.y + block.y);
        _drawBlock(canvas, pos, color);
      }
    }
  }

  /// ミノの配置可能判定
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

    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(1.5), const Radius.circular(2)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(1.5), const Radius.circular(2)), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

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
          border: Border.all(color: Colors.grey.withValues(alpha: 0.5))
        ),
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
          border: isCurrent ? Border.all(color: Colors.white, width: 2) : Border.all(color: Colors.grey.withValues(alpha: 0.5)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: CustomPaint(
            painter: PiecePainter(piece: piece!),
          ),
        ),
      ),
    );

    // isDraggableプロパティのみでドラッグ可否を判定する
    if (isDraggable && piece != null) {
       return Draggable<Tetromino>(
         data: piece!,
         feedback: SizedBox(
           width: 100, // ドラッグ中の見た目のサイズ
           height: 100,
           child: CustomPaint(painter: PiecePainter(piece: piece!, isFeedback: true)),
         ),
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
    double offsetX = (piece.type == TetrominoType.O) ? 0.5 : (piece.type == TetrominoType.I ? 0 : 0.5);
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
       final rrect = RRect.fromRectAndRadius(rect.deflate(1.0), const Radius.circular(2));
       canvas.drawRRect(rrect, paint);
       if (isFeedback) { // ドラッグ中は半透明にする
          canvas.drawRRect(rrect, Paint()..color = Colors.black.withValues(alpha: 0.3));
       }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

