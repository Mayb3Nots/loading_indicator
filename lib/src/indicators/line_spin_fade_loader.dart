import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// LineSpinFadeLoader.
class LineSpinFadeLoader extends StatefulWidget {
  @override
  _LineSpinFadeLoaderState createState() => _LineSpinFadeLoaderState();
}

class _LineSpinFadeLoaderState extends State<LineSpinFadeLoader>
    with TickerProviderStateMixin {
  static const _BEGIN_TIMES = [0, 120, 240, 360, 480, 600, 720, 840];

  List<AnimationController> _animationControllers = [];
  List<Animation<double>> _opacityAnimations = [];
  List<CancelableOperation<int>> _delayFeatures = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _animationControllers.length; i++) {
      _animationControllers.add(AnimationController(
          vsync: this, duration: const Duration(seconds: 1)));
      _opacityAnimations.add(TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 1),
      ]).animate(CurvedAnimation(
          parent: _animationControllers[i], curve: Curves.linear)));

      _delayFeatures.add(CancelableOperation.fromFuture(
          Future.delayed(Duration(milliseconds: _BEGIN_TIMES[i])).then((t) {
        _animationControllers[i].repeat();
        return 0;
      })));
    }
  }

  @override
  void dispose() {
    _delayFeatures.forEach((f) => f.cancel());
    _animationControllers.forEach((f) => f.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraint) {
      final circleSize = constraint.maxWidth / 3;

      final widgets = List<Widget>.filled(8, Container());
      final center = Offset(constraint.maxWidth / 2, constraint.maxHeight / 2);
      for (int i = 0; i < widgets.length; i++) {
        final angle = pi * i / 4;
        widgets[i] = Positioned.fromRect(
          rect: Rect.fromLTWH(
            center.dx + circleSize * (sin(angle)) - circleSize / 4,
            center.dy + circleSize * (cos(angle)) - circleSize / 2,
            circleSize / 2,
            circleSize,
          ),
          child: FadeTransition(
            opacity: _opacityAnimations[i],
            child: Transform.rotate(
              angle: -angle,
              child: IndicatorShapeWidget(shape: Shape.line),
            ),
          ),
        );
      }
      return Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: widgets,
      );
    });
  }
}
