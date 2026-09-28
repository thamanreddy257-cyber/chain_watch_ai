import 'package:flutter/material.dart';

/// Lays out cards in fixed-width columns, chunked into rows, where each
/// row's height matches its tallest card instead of a fixed aspect ratio.
/// This avoids the RenderFlex overflow that a GridView's childAspectRatio
/// causes whenever card content is taller than the guessed ratio allows.
class CardGrid extends StatelessWidget {
  final List<Widget> cards;
  final int columns;
  final double spacing;
  final double runSpacing;

  const CardGrid({
    super.key,
    required this.cards,
    required this.columns,
    this.spacing = 20,
    this.runSpacing = 20,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < cards.length; i += columns) {
      final chunk = cards.skip(i).take(columns).toList();
      if (rows.isNotEmpty) rows.add(SizedBox(height: runSpacing));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < chunk.length; j++) ...[
                if (j != 0) SizedBox(width: spacing),
                Expanded(child: chunk[j]),
              ],
              if (chunk.length < columns) ...[
                for (var k = chunk.length; k < columns; k++) ...[
                  SizedBox(width: spacing),
                  const Expanded(child: SizedBox()),
                ],
              ],
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}
