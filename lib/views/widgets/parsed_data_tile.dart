import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ParsedDataTile extends StatefulWidget {
  final String label;
  final dynamic value;
  final bool isHeader;

  const ParsedDataTile({
    super.key,
    required this.label,
    required this.value,
    this.isHeader = false,
  });

  @override
  State<ParsedDataTile> createState() => _ParsedDataTileState();
}

class _ParsedDataTileState extends State<ParsedDataTile>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _copyToClipboard() {
    final textToCopy = '${widget.label}: ${_formatValue(widget.value)}';
    Clipboard.setData(ClipboardData(text: textToCopy));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text('Copied to clipboard'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return value;
    if (value is num) return value.toString();
    if (value is bool) return value ? 'true' : 'false';
    if (value is List) {
      return value.map((e) => _formatValue(e)).join(', ');
    }
    if (value is Map) {
      return value.entries
          .map((e) => '${e.key}: ${_formatValue(e.value)}')
          .join(', ');
    }
    return value.toString();
  }

  IconData _getValueIcon(dynamic value) {
    if (value == null) return Icons.remove_circle_outline;
    if (value is String) return Icons.text_fields;
    if (value is num) return Icons.numbers;
    if (value is bool) return value ? Icons.check_circle : Icons.cancel;
    if (value is List) return Icons.list;
    if (value is Map) return Icons.data_object;
    return Icons.info_outline;
  }

  Color _getValueColor(BuildContext context, dynamic value) {
    final colorScheme = Theme.of(context).colorScheme;
    if (value == null) return Colors.grey;
    if (value is String) return colorScheme.primary;
    if (value is num) return Colors.orange;
    if (value is bool) return value ? Colors.green : Colors.red;
    if (value is List) return Colors.purple;
    if (value is Map) return Colors.blue;
    return colorScheme.onSurface;
  }

  Widget _buildComplexValueDisplay(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Array (${value.length} items):',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: value.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '[${entry.key}] ',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _formatValue(entry.value),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    }

    if (value is Map && value.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Object (${value.length} properties):',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: value.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key}: ',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _formatValue(entry.value),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    }

    return Text(_formatValue(value), style: const TextStyle(fontSize: 14));
  }

  bool _isComplexValue(dynamic value) {
    return (value is List && value.isNotEmpty) ||
        (value is Map && value.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isHeader) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.data_object,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final isComplex = _isComplexValue(widget.value);
    final formattedValue = _formatValue(widget.value);
    final shouldTruncate = formattedValue.length > 50 && !isComplex;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isComplex
              ? () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                    if (_isExpanded) {
                      _animationController.forward();
                    } else {
                      _animationController.reverse();
                    }
                  });
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getValueIcon(widget.value),
                      size: 16,
                      color: _getValueColor(context, widget.value),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    if (isComplex)
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.expand_more,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    IconButton(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy, size: 16),
                      iconSize: 16,
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Copy to clipboard',
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (isComplex) ...[
                  if (!_isExpanded && shouldTruncate)
                    Text(
                      '${formattedValue.substring(0, 50)}...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else if (!_isExpanded)
                    Text(
                      formattedValue,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),

                  SizeTransition(
                    sizeFactor: _expandAnimation,
                    axisAlignment: -1,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _buildComplexValueDisplay(widget.value),
                    ),
                  ),
                ] else ...[
                  SelectableText(
                    shouldTruncate && !_isExpanded
                        ? '${formattedValue.substring(0, 50)}...'
                        : formattedValue,
                    style: TextStyle(
                      fontSize: 14,
                      color: _getValueColor(context, widget.value),
                      fontFamily: widget.value is num ? 'monospace' : null,
                      fontWeight: widget.value is num ? FontWeight.w500 : null,
                    ),
                  ),
                  if (shouldTruncate)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 30),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        _isExpanded ? 'Show less' : 'Show more',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
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
