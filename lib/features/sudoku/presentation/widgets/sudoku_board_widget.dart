import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 470),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  c.surface.withOpacity(0.94),
                  c.boardBackground,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: c.surfaceBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.24),
                  blurRadius: 30,
                  spreadRadius: -12,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cellSize = constraints.maxWidth / 9;

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: c.boardBackground,
                        ),
                        child: Stack(
                          children: [
                            Column(
                              children: List.generate(9, (row) {
                                return Expanded(
                                  child: Row(
                                    children: List.generate(9, (col) {
                                      return Expanded(
                                        child: _BoardCell(
                                          row: row,
                                          col: col,
                                          size: cellSize,
                                          currentBoard: currentBoard,
                                          givenCells: givenCells,
                                          selectedCell: selectedCell,
                                          solution: solution,
                                          notes: notes,
                                          isZenMode: isZenMode,
                                          onTap: () => onCellTap(row, col),
                                        ),
                                      );
                                    }),
                                  ),
                                );
                              }),
                            ),
                            IgnorePointer(
                                child: _GridOverlay(cellSize: cellSize)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BoardCell extends StatelessWidget {
  const _BoardCell({
    required this.row,
    required this.col,
    required this.size,
    required this.currentBoard,
    required this.givenCells,
    required this.selectedCell,
    required this.solution,
    required this.notes,
    required this.isZenMode,
    required this.onTap,
  });

  final int row;
  final int col;
  final double size;
  final SudokuBoard currentBoard;
  final Set<(int, int)> givenCells;
  final (int, int)? selectedCell;
  final SudokuBoard solution;
  final Map<(int, int), Set<int>> notes;
  final bool isZenMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;
    final value = currentBoard[row][col];
    final isGiven = givenCells.contains((row, col));
    final isSelected = selectedCell == (row, col);
    final isPeer = _isPeer();
    final isMatched = _isMatchedValue();
    final hasConflict =
        !isGiven && !isZenMode && value != null && _hasConflict(value);
    final cellNotes = notes[(row, col)];

    var background = c.cellBackground;
    if (isPeer) background = c.cellPeer;
    if (isMatched) background = c.cellMatched;
    if (isSelected) background = c.cellSelected;
    if (hasConflict) background = c.cellConflictSoft;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.96, end: isSelected ? 1 : 0.985),
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
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: background,
              border: Border.all(
                color: isSelected
                    ? c.accentBlue.withOpacity(0.7)
                    : hasConflict
                        ? c.cellConflict.withOpacity(0.45)
                        : c.gridLine.withOpacity(0.68),
                width: isSelected ? 1.0 : 0.35,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: c.accentBlue.withOpacity(0.15),
                        blurRadius: 6,
                        spreadRadius: 0.5,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: value != null
                  ? AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: Tween<double>(begin: 0.82, end: 1)
                              .animate(animation),
                          child:
                              FadeTransition(opacity: animation, child: child),
                        );
                      },
                      child: Text(
                        '$value',
                        key: ValueKey('cell-$row-$col-$value'),
                        style: TextStyle(
                          fontSize: size * 0.44,
                          fontWeight:
                              isGiven ? FontWeight.w800 : FontWeight.w700,
                          letterSpacing: -0.4,
                          color: hasConflict
                              ? c.cellConflict
                              : isGiven
                                  ? c.givenNumber
                                  : c.userNumber,
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
    final c = context.appColors.colors;
    return Padding(
      padding: const EdgeInsets.all(4),
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
                    color: c.noteColor,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          );
        },
      ),
    );
  }
}

class _GridOverlay extends StatelessWidget {
  const _GridOverlay({required this.cellSize});

  final double cellSize;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors.colors;
    return CustomPaint(
      size: Size(cellSize * 9, cellSize * 9),
      painter: _SudokuGridPainter(
          gridLine: c.gridLine, gridLineThick: c.gridLineThick),
    );
  }
}

class _SudokuGridPainter extends CustomPainter {
  _SudokuGridPainter({required this.gridLine, required this.gridLineThick});

  final Color gridLine;
  final Color gridLineThick;

  @override
  void paint(Canvas canvas, Size size) {
    final thinPaint = Paint()
      ..color = gridLine.withOpacity(0.82)
      ..strokeWidth = 0.5;
    final thickPaint = Paint()
      ..color = gridLineThick
      ..strokeWidth = 1.4;

    final cellSize = size.width / 9;
    for (var index = 0; index <= 9; index++) {
      final offset = cellSize * index;
      final paint = index % 3 == 0 ? thickPaint : thinPaint;
      canvas.drawLine(Offset(offset, 0), Offset(offset, size.height), paint);
      canvas.drawLine(Offset(0, offset), Offset(size.width, offset), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SudokuGridPainter oldDelegate) =>
      oldDelegate.gridLine != gridLine ||
      oldDelegate.gridLineThick != gridLineThick;
}
