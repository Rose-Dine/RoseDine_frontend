import 'package:flutter/material.dart';

/// A full-screen overlay that shows an error message in a centered container.
/// The error message is expandable—by default, only a truncated version is shown,
/// but the user can tap the expand icon to see the full error details. A dismiss
/// button is also provided to remove the overlay.
class CenteredErrorOverlay extends StatefulWidget {
  final String title;
  final String errorMessage;
  final VoidCallback onDismiss;
  final int maxCollapsedLength;
  final Duration animationDuration;

  const CenteredErrorOverlay({
    Key? key,
    required this.title,
    required this.errorMessage,
    required this.onDismiss,
    this.maxCollapsedLength = 100,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  _CenteredErrorOverlayState createState() => _CenteredErrorOverlayState();
}

class _CenteredErrorOverlayState extends State<CenteredErrorOverlay> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // If the error message is longer than maxCollapsedLength, create a truncated version.
    final truncatedMessage = widget.errorMessage.length > widget.maxCollapsedLength
        ? widget.errorMessage.substring(0, widget.maxCollapsedLength) + '...'
        : widget.errorMessage;

    return Material(
      // A semi-transparent dark background to overlay the screen.
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blueGrey[800],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFAB8532), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row with title and expand/collapse icon.
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Animated cross-fade between truncated and full error message.
              AnimatedCrossFade(
                firstChild: Text(
                  truncatedMessage,
                  style: const TextStyle(color: Colors.white),
                ),
                secondChild: Text(
                  widget.errorMessage,
                  style: const TextStyle(color: Colors.white),
                ),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: widget.animationDuration,
              ),
              const SizedBox(height: 10),
              // Dismiss button
              TextButton(
                onPressed: widget.onDismiss,
                child: const Text(
                  'Dismiss',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
