import 'dart:math';
import 'package:flutter/material.dart';

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
