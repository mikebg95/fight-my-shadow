import 'package:flutter/material.dart';

/// A reusable collapsible section widget (accordion) with customizable styling.
///
/// Used in Academy (levels), Library (categories), and Included Moves (categories).
class CollapsibleSection extends StatefulWidget {
  /// The title displayed in the header
  final String title;

  /// Optional subtitle (e.g., "3/4 unlocked", "2 moves included")
  final String? subtitle;

  /// Optional leading icon for the header
  final IconData? leadingIcon;

  /// Accent color for the theme (purple for Academy, orange for Library, red for Training)
  final Color accentColor;

  /// Whether the section is initially expanded
  final bool initiallyExpanded;

  /// The content to show when expanded
  final List<Widget> children;

  /// Optional callback when expansion state changes
  final ValueChanged<bool>? onExpansionChanged;

  const CollapsibleSection({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    required this.accentColor,
    this.initiallyExpanded = false,
    required this.children,
    this.onExpansionChanged,
  });

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _iconRotation = Tween<double>(
      begin: 0.0,
      end: 0.5, // 180 degrees (0.5 * pi)
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      widget.onExpansionChanged?.call(_isExpanded);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded
              ? widget.accentColor.withOpacity(0.3)
              : Colors.white.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: _isExpanded
            ? [
                BoxShadow(
                  color: widget.accentColor.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (always visible, tappable)
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Optional leading icon
                  if (widget.leadingIcon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.leadingIcon,
                        color: widget.accentColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.6),
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Animated chevron
                  RotationTransition(
                    turns: _iconRotation,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: widget.accentColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.children,
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }
}
