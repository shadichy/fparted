import 'package:flutter/material.dart';

class FlexRowComponent {
  final double widthPercent;
  final Widget? Function(BuildContext context, Size size) builder;

  FlexRowComponent({required this.widthPercent, required Widget child})
    : builder = ((_, _) => child);

  const FlexRowComponent.builder({
    required this.widthPercent,
    required this.builder,
  });
}

class FlexRow extends StatelessWidget {
  final double minWidth;
  final double? height;
  final List<FlexRowComponent> children;
  const FlexRow({
    super.key,
    this.minWidth = 1,
    this.height,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    Widget sizedBox(FlexRowComponent component, double width) => SizedBox(
      width: width,
      height: height,
      child: component.builder(context, Size(width, height ?? 0)),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        (int, Widget) toElement((int, FlexRowComponent) c) {
          double componentWidth = c.$2.widthPercent * width;
          if (componentWidth < minWidth) {
            width -= (minWidth - componentWidth);
            componentWidth = minWidth;
          }
          return (c.$1, sizedBox(c.$2, componentWidth));
        }

        final indexed = children.indexed.toList();
        indexed.sort((a, b) => a.$2.widthPercent.compareTo(b.$2.widthPercent));

        final components = indexed.map(toElement).toList();
        components.sort((a, b) => a.$1.compareTo(b.$1));

        return Row(children: components.map((e) => e.$2).toList());
      },
    );
  }
}
