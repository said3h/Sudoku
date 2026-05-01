import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/sudoku_board.dart';

class SudokuBoardWidget extends StatefulWidget {
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
  State<SudokuBoardWidget> createState() => _SudokuBoardWidgetState();
}

class _SudokuBoardWidgetState extends State<SudokuBoardWidget> {
  Timer? _completionTimer;
  Set<(int, int)> _changedCells = {};
  Set<_CompletedUnit> _completedUnits = {};

  @override
  void didUpdateWidget(covariant SudokuBoardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final changedCells = <(int, int)>{};
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        if (oldWidget.currentBoard[row][col] != widget.currentBoard[row][col]) {
          changedCells.add((row, col));
        }
      }
    }

    if (changedCells.isEmpty) return;

    final completedUnits = _newlyCompletedUnits(
      oldBoard: oldWidget.currentBoard,
      currentBoard: widget.currentBoard,
      solution: widget.solution,
      changedCells: changedCells,
    );

    setState(() {
      _changedCells = changedCells;
      _completedUnits = completedUnits;
    });

    _completionTimer?.cancel();
    _completionTimer = Timer(const Duration(milliseconds: 720), () {
      if (!mounted) return;
      setState(() {
        _changedCells = {};
        _completedUnits = {};
      });
    });
  }

  @override
  void dispose() {
    _completionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _BoardPalette.fromScheme(context.appColors.colors);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: palette.boardBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: palette.primary.withOpacity(0.24),
                  width: 1.05,
                ),
                boxShadow: [
                  BoxShadow(
                    color: palette.shadow,
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.primary.withOpacity(0.32),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      children: List.generate(3, (blockRow) {
                        return Expanded(
                          child: Padding(
                            padding:
                                EdgeInsets.only(bottom: blockRow == 2 ? 0 : 8),
                            child: Row(
                              children: List.generate(3, (blockCol) {
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: blockCol == 2 ? 0 : 8,
                                    ),
                                    child: _Block(
                                      palette: palette,
                                      blockRow: blockRow,
                                      blockCol: blockCol,
                                      currentBoard: widget.currentBoard,
                                      givenCells: widget.givenCells,
                                      selectedCell: widget.selectedCell,
                                      solution: widget.solution,
                                      notes: widget.notes,
                                      isZenMode: widget.isZenMode,
                                      changedCells: _changedCells,
                                      completedUnits: _completedUnits,
                                      onCellTap: widget.onCellTap,
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

  Set<_CompletedUnit> _newlyCompletedUnits({
    required SudokuBoard oldBoard,
    required SudokuBoard currentBoard,
    required SudokuBoard solution,
    required Set<(int, int)> changedCells,
  }) {
    final units = <_CompletedUnit>{};

    for (final cell in changedCells) {
      final row = cell.$1;
      final col = cell.$2;
      final block = (row ~/ 3) * 3 + (col ~/ 3);

      if (!_isRowComplete(oldBoard, solution, row) &&
          _isRowComplete(currentBoard, solution, row)) {
        units.add(_CompletedUnit.row(row));
      }
      if (!_isColumnComplete(oldBoard, solution, col) &&
          _isColumnComplete(currentBoard, solution, col)) {
        units.add(_CompletedUnit.column(col));
      }
      if (!_isBlockComplete(oldBoard, solution, block) &&
          _isBlockComplete(currentBoard, solution, block)) {
        units.add(_CompletedUnit.block(block));
      }
    }

    return units;
  }

  bool _isRowComplete(SudokuBoard board, SudokuBoard solution, int row) {
    for (var col = 0; col < 9; col++) {
      if (board[row][col] == null || board[row][col] != solution[row][col]) {
        return false;
      }
    }
    return true;
  }

  bool _isColumnComplete(SudokuBoard board, SudokuBoard solution, int col) {
    for (var row = 0; row < 9; row++) {
      if (board[row][col] == null || board[row][col] != solution[row][col]) {
        return false;
      }
    }
    return true;
  }

  bool _isBlockComplete(SudokuBoard board, SudokuBoard solution, int block) {
    final blockRow = (block ~/ 3) * 3;
    final blockCol = (block % 3) * 3;
    for (var row = blockRow; row < blockRow + 3; row++) {
      for (var col = blockCol; col < blockCol + 3; col++) {
        if (board[row][col] == null || board[row][col] != solution[row][col]) {
          return false;
        }
      }
    }
    return true;
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.palette,
    required this.blockRow,
    required this.blockCol,
    required this.currentBoard,
    required this.givenCells,
    required this.selectedCell,
    required this.solution,
    required this.notes,
    required this.isZenMode,
    required this.changedCells,
    required this.completedUnits,
    required this.onCellTap,
  });

  final _BoardPalette palette;
  final int blockRow;
  final int blockCol;
  final SudokuBoard currentBoard;
  final Set<(int, int)> givenCells;
  final (int, int)? selectedCell;
  final SudokuBoard solution;
  final Map<(int, int), Set<int>> notes;
  final bool isZenMode;
  final Set<(int, int)> changedCells;
  final Set<_CompletedUnit> completedUnits;
  final void Function(int row, int col) onCellTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.blockBackground,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: palette.primaryLight,
          width: 1.05,
        ),
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
                        palette: palette,
                        row: row,
                        col: col,
                        currentBoard: currentBoard,
                        givenCells: givenCells,
                        selectedCell: selectedCell,
                        solution: solution,
                        notes: notes,
                        isZenMode: isZenMode,
                        wasJustChanged: changedCells.contains((row, col)),
                        hasCompletionGlow: _hasCompletionGlow(row, col),
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

  bool _hasCompletionGlow(int row, int col) {
    final block = (row ~/ 3) * 3 + (col ~/ 3);
    return completedUnits.contains(_CompletedUnit.row(row)) ||
        completedUnits.contains(_CompletedUnit.column(col)) ||
        completedUnits.contains(_CompletedUnit.block(block));
  }
}

class _BoardCell extends StatelessWidget {
  const _BoardCell({
    required this.palette,
    required this.row,
    required this.col,
    required this.currentBoard,
    required this.givenCells,
    required this.selectedCell,
    required this.solution,
    required this.notes,
    required this.isZenMode,
    required this.wasJustChanged,
    required this.hasCompletionGlow,
    required this.onTap,
  });

  final _BoardPalette palette;
  final int row;
  final int col;
  final SudokuBoard currentBoard;
  final Set<(int, int)> givenCells;
  final (int, int)? selectedCell;
  final SudokuBoard solution;
  final Map<(int, int), Set<int>> notes;
  final bool isZenMode;
  final bool wasJustChanged;
  final bool hasCompletionGlow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final value = currentBoard[row][col];
    final isGiven = givenCells.contains((row, col));
    final isSelected = selectedCell == (row, col);
    final isPeer = _isPeer();
    final isMatched = _isMatchedValue();
    final hasConflict =
        !isGiven && !isZenMode && value != null && _hasConflict(value);
    final cellNotes = notes[(row, col)];

    Color background = palette.cellBackground;
    Color foreground = isGiven ? palette.onSurface : palette.primary;
    Color borderColor = palette.onSurfaceVariant.withOpacity(0.92);
    double borderWidth = 0.65;
    List<BoxShadow>? boxShadow;

    if (isPeer) {
      background = palette.cellPeer;
    }
    if (isMatched) {
      background = palette.primary.withOpacity(0.18);
      if (Theme.of(context).brightness == Brightness.dark) {
        foreground = palette.secondary;
      }
    }
    if (hasConflict) {
      background = palette.errorSoft;
      foreground = palette.error;
      borderColor = palette.error.withOpacity(0.42);
      borderWidth = 1.05;
      boxShadow = [
        BoxShadow(
          color: palette.error.withOpacity(0.12),
          blurRadius: 12,
          spreadRadius: -2,
        ),
      ];
    }
    if (hasCompletionGlow && !hasConflict) {
      background = palette.successSoft;
      foreground = isGiven ? palette.onSurface : palette.success;
      borderColor = palette.success.withOpacity(0.42);
      boxShadow = [
        BoxShadow(
          color: palette.success.withOpacity(0.16),
          blurRadius: 18,
          spreadRadius: -3,
        ),
      ];
    }
    if (isSelected) {
      background = palette.cellSelected;
      foreground = hasConflict ? palette.error : palette.primary;
      borderColor = palette.primary;
      borderWidth = 2.25;
      boxShadow = [
        BoxShadow(
          color: palette.primary.withOpacity(0.46),
          blurRadius: 24,
          spreadRadius: 1,
        ),
        BoxShadow(
          color: palette.primary.withOpacity(0.18),
          blurRadius: 8,
          spreadRadius: -1,
        ),
      ];
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: wasJustChanged ? 1.08 : 0.98,
        end: isSelected ? 1 : 0.99,
      ),
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
                color: borderColor,
                width: borderWidth,
              ),
              boxShadow: boxShadow,
            ),
            child: Center(
              child: value != null
                  ? AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.88, end: 1)
                                .animate(animation),
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
                          fontWeight: isGiven
                              ? FontWeight.w600
                              : wasJustChanged
                                  ? FontWeight.w500
                                  : FontWeight.w300,
                          color: foreground,
                        ),
                      ),
                    )
                  : cellNotes != null && cellNotes.isNotEmpty
                      ? _NotesGrid(notes: cellNotes, palette: palette)
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
  const _NotesGrid({
    required this.notes,
    required this.palette,
  });

  final Set<int> notes;
  final _BoardPalette palette;

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
                    color: palette.onSurfaceVariant,
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

class _BoardPalette {
  const _BoardPalette({
    required this.boardBackground,
    required this.blockBackground,
    required this.cellBackground,
    required this.cellSelected,
    required this.cellPeer,
    required this.primary,
    required this.primaryLight,
    required this.secondary,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.errorSoft,
    required this.error,
    required this.successSoft,
    required this.success,
    required this.shadow,
  });

  final Color boardBackground;
  final Color blockBackground;
  final Color cellBackground;
  final Color cellSelected;
  final Color cellPeer;
  final Color primary;
  final Color primaryLight;
  final Color secondary;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color errorSoft;
  final Color error;
  final Color successSoft;
  final Color success;
  final Color shadow;

  factory _BoardPalette.fromScheme(AppColorScheme scheme) {
    return _BoardPalette(
      boardBackground: scheme.boardBackground,
      blockBackground:
          scheme.surfaceLight, // Used for block container decoration
      cellBackground: scheme.cellBackground,
      cellSelected: scheme.cellSelected,
      cellPeer: scheme.cellPeer,
      primary: scheme.accent,
      primaryLight: scheme.primaryLight,
      secondary: scheme.accentLight,
      onSurface: scheme.givenNumber,
      onSurfaceVariant: scheme.noteColor,
      errorSoft: scheme.cellConflictSoft.withOpacity(0.72),
      error: scheme.error,
      successSoft: scheme.cellSuccess.withOpacity(0.16),
      success: scheme.success,
      shadow: scheme.accent.withOpacity(0.20),
    );
  }
}

enum _CompletedUnitType { row, column, block }

class _CompletedUnit {
  const _CompletedUnit(this.type, this.index);

  const _CompletedUnit.row(int index) : this(_CompletedUnitType.row, index);
  const _CompletedUnit.column(int index)
      : this(_CompletedUnitType.column, index);
  const _CompletedUnit.block(int index) : this(_CompletedUnitType.block, index);

  final _CompletedUnitType type;
  final int index;

  @override
  bool operator ==(Object other) {
    return other is _CompletedUnit &&
        other.type == type &&
        other.index == index;
  }

  @override
  int get hashCode => Object.hash(type, index);
}
