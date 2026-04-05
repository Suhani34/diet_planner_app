import 'package:flutter/material.dart';

class RulerScalePicker extends StatefulWidget {
  final int min;
  final int max;
  final int initialValue;
  final int majorTickEvery;
  final Color accentColor;
  final ValueChanged<int> onChanged;

  const RulerScalePicker({
    super.key,
    required this.min,
    required this.max,
    required this.initialValue,
    required this.onChanged,
    this.majorTickEvery = 5,
    this.accentColor = const Color(0xFF7B61FF),
  });

  @override
  State<RulerScalePicker> createState() => _RulerScalePickerState();
}

class _RulerScalePickerState extends State<RulerScalePicker> {
  static const double _tickSpacing = 14;
  static const double _sidePadding = 140;

  late final ScrollController _scrollController;
  late int _currentValue;
  bool _isSnapping = false;

  int get _totalValues => widget.max - widget.min + 1;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue.clamp(widget.min, widget.max);

    final initialOffset = (_currentValue - widget.min) * _tickSpacing;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateValueFromOffset(double offset) {
    int value = widget.min + (offset / _tickSpacing).round();
    value = value.clamp(widget.min, widget.max);

    if (value != _currentValue) {
      setState(() {
        _currentValue = value;
      });
      widget.onChanged(value);
    }
  }

  Future<void> _snapToNearest() async {
    if (_isSnapping) return;
    _isSnapping = true;

    int value = widget.min + (_scrollController.offset / _tickSpacing).round();
    value = value.clamp(widget.min, widget.max);
    final targetOffset = (value - widget.min) * _tickSpacing;

    await _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
    );

    _updateValueFromOffset(targetOffset);
    _isSnapping = false;
  }

  bool _isMajor(int value) {
    return (value - widget.min) % widget.majorTickEvery == 0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 78,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                _updateValueFromOffset(notification.metrics.pixels);
              } else if (notification is ScrollEndNotification) {
                _snapToNearest();
              }
              return false;
            },
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: _sidePadding),
              itemCount: _totalValues,
              itemBuilder: (context, index) {
                final value = widget.min + index;
                final isMajor = _isMajor(value);
                final isSelected = value == _currentValue;

                return SizedBox(
                  width: _tickSpacing,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: isMajor ? 2 : 1.4,
                        height: isMajor ? 26 : 14,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? widget.accentColor
                              : (isMajor
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isMajor)
                        Text(
                          "$value",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? widget.accentColor
                                : Colors.grey.shade600,
                          ),
                        )
                      else
                        const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 8,
            child: IgnorePointer(
              child: Column(
                children: [
                  Icon(
                    Icons.arrow_drop_down,
                    size: 28,
                    color: widget.accentColor,
                  ),
                  Container(
                    width: 2,
                    height: 18,
                    color: widget.accentColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}