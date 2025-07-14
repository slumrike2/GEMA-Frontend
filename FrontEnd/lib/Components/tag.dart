import 'package:flutter/material.dart';

class Tag extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final IconData? iconData;

  const Tag({
    super.key,
    required this.label,
    this.color = const Color(0xFF43A047),
    this.onRemove,
    this.onTap,
    this.iconData,
  });

  @override
  State<Tag> createState() => _TagState();
}

class _TagState extends State<Tag> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool clickable = widget.onTap != null;
    final Color bgColor =
        _hovered && clickable ? widget.color.withOpacity(0.75) : widget.color;
    return MouseRegion(
      cursor: clickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.iconData != null) ...[
                  Icon(widget.iconData, color: Colors.white, size: 18),
                  if (widget.label.isNotEmpty) const SizedBox(width: 6),
                ],
                if (widget.label.isNotEmpty)
                  Flexible(
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      softWrap: true,
                      maxLines: 2,
                    ),
                  ),
                if (widget.onRemove != null) ...[
                  const SizedBox(width: 8),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: widget.onRemove,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
