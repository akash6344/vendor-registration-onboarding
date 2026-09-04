import 'package:flutter/material.dart';

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width > 900 ? 3 : width > 620 ? 2 : 1;
        const spacing = 14.0;
        final itemWidth = columns == 1 ? width : (width - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map(
                (child) => SizedBox(
                  width: itemWidth,
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class FieldGrid extends StatelessWidget {
  const FieldGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth > 760 ? (constraints.maxWidth - 14) / 2 : constraints.maxWidth;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: children.map((child) => SizedBox(width: itemWidth, child: child)).toList(),
        );
      },
    );
  }
}
