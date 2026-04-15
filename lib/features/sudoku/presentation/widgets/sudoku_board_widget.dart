import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/sudoku_board.dart';

class SudokuBoardWidget extends StatelessWidget {
  final SudokuBoard currentBoard;
  final Set<(int, int)> givenCells;
  final (int, int)? selectedCell;
  final SudokuBoard solution;
  final Map<(int, int), Set<int>> notes;
  final void Function(int row, int col) onCellTap;

  const SudokuBoardWidget({
    super.key,
    required this.currentBoard,
    required this.givenCells,
    required this.selectedCell,
    required this.solution,
    required this.notes,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cellSize = constraints.maxWidth / 9;

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.boardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gridLineThick, width: 3),
                  ),
                  child: Column(
                    children: List.generate(9, (row) {
                      return Expanded(
                        child: Row(
                          children: List.generate(9, (col) {
                            return _buildCell(row, col, cellSize);
                          }),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(int row, int col, double cellSize) {
    final value = currentBoard[row][col];
    final isGiven = givenCells.contains((row, col));
    final isSelected = selectedCell == (row, col);
    final isHighlighted = _isHighlighted(row, col);
    final isConflict = !isGiven && value != null && _hasConflict(row, col);
    final cellNotes = notes[(row, col)];

    Color backgroundColor = AppColors.cellBackground;
    if (isSelected) {
      backgroundColor = AppColors.cellSelected;
    } else if (isConflict) {
      backgroundColor = AppColors.error.withOpacity(0.08);
    } else if (isHighlighted) {
      backgroundColor = AppColors.cellHighlighted;
    }

    return GestureDetector(
      onTap: () => onCellTap(row, col),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: _getCellBorder(row, col),
        ),
        child: Center(
          child: value != null
              ? AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    '$value',
                    key: ValueKey('$row-$col-$value'),
                    style: TextStyle(
                      fontSize: cellSize * 0.45,
                      fontWeight: isGiven ? FontWeight.w700 : FontWeight.w500,
                      color: isConflict
                          ? AppColors.cellConflict
                          : isGiven
                              ? AppColors.givenNumber
                              : AppColors.userNumber,
                    ),
                  ),
                )
              : cellNotes != null
                  ? _buildNotes(cellNotes)
                  : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildNotes(Set<int> cellNotes) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Column(
        children: List.generate(3, (row) {
          return Expanded(
            child: Row(
              children: List.generate(3, (col) {
                final number = row * 3 + col + 1;
                return Expanded(
                  child: Center(
                    child: Text(
                      cellNotes.contains(number) ? '$number' : '',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: AppColors.noteColor,
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  bool _hasConflict(int row, int col) {
    final value = currentBoard[row][col];
    if (value == null) return false;

    for (int index = 0; index < 9; index++) {
      if (index != col && currentBoard[row][index] == value) return true;
      if (index != row && currentBoard[index][col] == value) return true;
    }

    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if ((r != row || c != col) && currentBoard[r][c] == value) return true;
      }
    }

    return false;
  }

  bool _isHighlighted(int row, int col) {
    final activeCell = selectedCell;
    if (activeCell == null) return false;

    final (selectedRow, selectedCol) = activeCell;
    if (row == selectedRow && col == selectedCol) return true;
    if (row == selectedRow || col == selectedCol) return true;
    if ((row ~/ 3) == (selectedRow ~/ 3) && (col ~/ 3) == (selectedCol ~/ 3)) {
      return true;
    }

    final selectedValue = currentBoard[selectedRow][selectedCol];
    return selectedValue != null && currentBoard[row][col] == selectedValue;
  }

  Border _getCellBorder(int row, int col) {
    final isLeftEdge = col % 3 == 0;
    final isRightEdge = col == 8;
    final isTopEdge = row % 3 == 0;
    final isBottomEdge = row == 8;

    return Border(
      left: isLeftEdge
          ? const BorderSide(color: AppColors.gridLineThick, width: 2)
          : const BorderSide(color: AppColors.gridLine, width: 0.5),
      right: isRightEdge
          ? const BorderSide(color: AppColors.gridLineThick, width: 2)
          : const BorderSide(color: AppColors.gridLine, width: 0.5),
      top: isTopEdge
          ? const BorderSide(color: AppColors.gridLineThick, width: 2)
          : const BorderSide(color: AppColors.gridLine, width: 0.5),
      bottom: isBottomEdge
          ? const BorderSide(color: AppColors.gridLineThick, width: 2)
          : const BorderSide(color: AppColors.gridLine, width: 0.5),
    );
  }
}
