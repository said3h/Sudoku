typedef SudokuBoard = List<List<int?>>;

extension BoardExtension on SudokuBoard {
  List<int?> getRow(int row) => this[row];

  List<int?> getColumn(int col) {
    return [for (int r = 0; r < 9; r++) this[r][col]];
  }

  List<int?> getBox(int boxRow, int boxCol) {
    final List<int?> box = [];
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        box.add(this[boxRow * 3 + r][boxCol * 3 + c]);
      }
    }
    return box;
  }

  bool isValidMove(int row, int col, int value) {
    // Check row
    for (int c = 0; c < 9; c++) {
      if (c != col && this[row][c] == value) return false;
    }
    // Check column
    for (int r = 0; r < 9; r++) {
      if (r != row && this[r][col] == value) return false;
    }
    // Check 3x3 box
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (r == row && c == col) continue;
        if (this[r][c] == value) return false;
      }
    }
    return true;
  }

  SudokuBoard clone() {
    return [for (int r = 0; r < 9; r++) List<int?>.from(this[r])];
  }

  bool isComplete() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (this[r][c] == null) return false;
      }
    }
    return true;
  }

  bool isValidBoard() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (this[r][c] != null) {
          if (!isValidMove(r, c, this[r][c]!)) return false;
        }
      }
    }
    return true;
  }

  int countConflicts() {
    int conflicts = 0;
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (this[r][c] != null && !isValidMove(r, c, this[r][c]!)) {
          conflicts++;
        }
      }
    }
    return conflicts;
  }
}
