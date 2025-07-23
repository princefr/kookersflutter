import "package:flutter/material.dart";
import 'dart:math' as math;

class SwipeableCell extends StatefulWidget {
  final Widget child;
  final Widget backgroundIcon;
  final VoidCallback? onSwipeStart;
  final VoidCallback? onSwipeCancel;
  final VoidCallback? onSwipeEnd;
  final double threshold;
  const SwipeableCell(
      {Key? key,
      required this.child,
      required this.backgroundIcon,
      this.onSwipeStart,
      this.onSwipeCancel,
      this.onSwipeEnd,
      this.threshold = 120})
      : super(key: key);

  @override
  _SwipeableCellState createState() => _SwipeableCellState();
}

class _SwipeableCellState extends State<SwipeableCell>
    with TickerProviderStateMixin {
  double _dragExtent = 0.0;
  late AnimationController _moveController;
  late AnimationController _iconMoveController;
  late Animation<Offset> _moveAnimation;
  late Animation<Offset> _iconTransitionAnimation;
  late Animation<double> _iconFadeAnimation;
  bool _pastThreshold = false;

  final _animationDuration = const Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    _moveController =
        AnimationController(duration: _animationDuration, vsync: this);
    _iconMoveController =
        AnimationController(duration: _animationDuration, vsync: this);
    _moveAnimation = Tween<Offset>(begin: Offset.zero, end: Offset(1.0, 0.0))
        .animate(_moveController);
    _iconTransitionAnimation =
        Tween<Offset>(begin: Offset(-0.1, 0.0), end: Offset(0.4, 0.0))
            .animate(_moveController);
    _iconFadeAnimation =
        Tween<double>(begin: 0.7, end: 1.0).animate(_iconMoveController);
    final controllerValue = 0.0;
    _moveController.animateTo(controllerValue);
    _iconMoveController.animateTo(controllerValue);
  }

  @override
  void dispose() {
    _moveController.dispose();
    _iconMoveController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    if (widget.onSwipeStart != null) {
      widget.onSwipeStart!();
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0.0;
    _dragExtent += delta;
    if (_dragExtent.isNegative) return;
    var movePastThresholdPixels = widget.threshold;
    var newPos = _dragExtent.abs() / (context.size?.width ?? 1);
    if (_dragExtent.abs() > movePastThresholdPixels) {
// how many "thresholds" past the threshold we are. 1 = the threshold 2
// = two thresholds.
      var n = _dragExtent.abs() / movePastThresholdPixels;
// Take the number of thresholds past the threshold, and reduce this
// number
      var reducedThreshold = math.pow(n, 0.3);
      var adjustedPixelPos = movePastThresholdPixels * reducedThreshold;
      newPos = adjustedPixelPos / (context.size?.width ?? 1);
      if (_dragExtent > 0 && !_pastThreshold) {
        _iconMoveController.value = 1;
        _pastThreshold = true;
      }
    } else {
// Send a cancel event if the user has swiped back underneath the
// threshold
      if (_pastThreshold && widget.onSwipeCancel != null) {
        widget.onSwipeCancel!();
      }
      _pastThreshold = false;
    }
    if (!_pastThreshold || newPos < _moveController.value) {
      _iconMoveController.value = newPos;
    }
    _moveController.value = newPos;
  }

  void _handleDragEnd(DragEndDetails details) {
    _moveController.animateTo(0.0, duration: _animationDuration);
    _iconMoveController.animateTo(0.0, duration: _animationDuration);
    _dragExtent = 0.0;
    if (_pastThreshold && widget.onSwipeEnd != null) {
      widget.onSwipeEnd!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.passthrough,
        children: [
          SlideTransition(
            position: _iconTransitionAnimation,
            child: Row(
              children: [
                FadeTransition(
                  opacity: _iconFadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.only(left: 55),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: widget.backgroundIcon,
                  ),
                ),
              ],
            ),
          ),
          SlideTransition(
            position: _moveAnimation,
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
