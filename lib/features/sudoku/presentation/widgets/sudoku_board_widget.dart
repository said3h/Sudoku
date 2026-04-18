import 'package:flutter/material.dart';

import '../../domain/models/sudoku_board.dart';

class SudokuBoardWidget extends StatelessWidget {
  const SudokuBoardWidget({
    super.key,
    required this.currentBoard,
    required this.givenCells,
    required this.selectedCell,
    required this.solution,
    required this.notes,
    required this.isZenMode,
    required this.onCellTap,
  });

  final SudokuBoard currentBoard;
  final Set<(int, int)> givenCells;
  final (int, int)? selectedCell;
  final SudokuBoard solution;
  final Map<(int, int), Set<int>> notes;
  final bool isZenMode;
  final void Function(int row, int col) onCellTap;

  static const _boardBackground = Color(0xFF020617);
  static const _blockBackground = Color(0xFF0F172A);
  static const _cellBackground = Color(0xFF020617);
  static const _primary = Color(0xFF38BDF8);
  static const _secondary = Color(0xFF7DD3FC);
  static const _onSurface = Color(0xFFF8FAFC);
  static const _onSurfaceVariant = Color(0xFFCBD5E1);
  static const _errorSoft = Color(0x33FFB4AB);
  static const _error = Color(0xFFFFB4AB);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _boardBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _primary.withOpacity(0.20), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.40),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.27),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      children: List.generate(3, (blockRow) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: blockRow == 2 ? 0 : 8),
                            child: Row(
                              children: List.generate(3, (blockCol) {
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: blockCol == 2 ? 0 : 8,
                                    ),
                                    child: _Block(
                                      blockRow: blockRow,
                                      blockCol: blockCol,
                                      currentBoard: currentBoard,
                                      givenCells: givenCells,
                                      selectedCell: selectedCell,
                                      notes: notes,
                                      isZenMode: isZenMode,
                                      onCellTap: onCellTap,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.blockRow,
    required this.blockCol,
    required this.currentBoard,
    required this.givenCells,
    required this.selectedCell,
    required this.notes,
    required this.isZenMode,
    required this.onCellTap,
  });

  final int blockRow;
  final int blockCol;
  final SudokuBoard currentBoard;
  final Set<(int, int)> givenCells;
  final (int, int)? selectedCell;
  final Map<(int, int), Set<int>> notes;
  final bool isZenMode;
  final void Function(int row, int col) onCellTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: SudokuBoardWidget._blockBackground,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        children: List.generate(3, (innerRow) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: innerRow == 2 ? 0 : 1),
              child: Row(
                children: List.generate(3, (innerCol) {
                  final row = blockRow * 3 + innerRow;
                  final col = blockCol * 3 + innerCol;

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: innerCol == 2 ? 0 : 1),
                      child: _BoardCell(
                        row: row,
                        col: col,
                        currentBoard: currentBoard,
                        givenCells: givenCells,
                        selectedCell: selectedCell,
                        notes: notes,
                        isZenMode: isZenMode,
                        onTap: () => onCellTap(row, col),
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BoardCell extends StatelessWidget {
  const _BoardCell({
    required this.row,
    required this.col,
    required this.currentBoard,
    required this.givenCells,
    required this.selectedCell,
    required this.notes,
    required this.isZenMode,
    required this.onTap,
  });

  final int row;
  final int col;
  final SudokuBoard currentBoard;
  final Set<(int, int)> givenCells;
  final (int, int)? selectedCell;
  final Map<(int, int), Set<int>> notes;
  final bool isZenMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final value = currentBoard[row][col];
    final isGiven = givenCells.contains((row, col));
    final isSelected = selectedCell == (row, col);
    final isPeer = _isPeer();
    final isMatched = _isMatchedValue();
    final hasConflict = !isGiven && !isZenMode && value != null && _hasConflict(value);
    final cellNotes = notes[(row, col)];

    Color background = SudokuBoardWidget._cellBackground;
    Color foreground = isGiven
        ? SudokuBoardWidget._onSurface
        : SudokuBoardWidget._primary;

    if (isPeer) {
      background = SudokuBoardWidget._blockBackground;
    }
    if (isMatched) {
      background = SudokuBoardWidget._primary.withOpacity(0.14);
      foreground = SudokuBoardWidget._secondary;
    }
    if (hasConflict) {
      background = SudokuBoardWidget._errorSoft;
      foreground = SudokuBoardWidget._error;
    }
    if (isSelected) {
      background = SudokuBoardWidget._blockBackground;
      foreground = hasConflict ? SudokuBoardWidget._error : SudokuBoardWidget._primary;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.98, end: isSelected ? 1 : 0.99),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: background,
              border: Border.all(
                color: isSelected
                    ? SudokuBoardWidget._primary
                    : Colors.white.withOpacity(0.00),
                width: isSelected ? 2 : 0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: SudokuBoardWidget._primary.withOpacity(0.30),
                        blurRadius: 15,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: value != null
                  ? AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.88, end: 1).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        '$value',
                        key: ValueKey('cell-$row-$col-$value'),
                        style: TextStyle(
                          fontSize: 28,
                          height: 1,
                          fontWeight: isGiven ? FontWeight.w600 : FontWeight.w300,
                          color: foreground,
                        ),
                      ),
                    )
                  : cellNotes != null && cellNotes.isNotEmpty
                      ? _NotesGrid(notes: cellNotes)
                      : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }

  bool _isPeer() {
    final active = selectedCell;
    if (active == null) return false;
    final (selectedRow, selectedCol) = active;
    if (row == selectedRow && col == selectedCol) return false;
    if (row == selectedRow || col == selectedCol) return true;
    return (row ~/ 3) == (selectedRow ~/ 3) && (col ~/ 3) == (selectedCol ~/ 3);
  }

  bool _isMatchedValue() {
    final active = selectedCell;
    if (active == null) return false;
    final activeValue = currentBoard[active.$1][active.$2];
    final value = currentBoard[row][col];
    return activeValue != null && value != null && activeValue == value;
  }

  bool _hasConflict(int value) {
    for (var index = 0; index < 9; index++) {
      if (index != col && currentBoard[row][index] == value) return true;
      if (index != row && currentBoard[index][col] == value) return true;
    }

    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (var r = boxRow; r < boxRow + 3; r++) {
      for (var c = boxCol; c < boxCol + 3; c++) {
        if ((r != row || c != col) && currentBoard[r][c] == value) return true;
      }
    }
    return false;
  }
}

class _NotesGrid extends StatelessWidget {
  const _NotesGrid({required this.notes});

  final Set<int> notes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final number = index + 1;
          return Center(
            child: Text(
              notes.contains(number) ? '$number' : '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SudokuBoardWidget._onSurfaceVariant,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          );
        },
      ),
    );
  }
}
