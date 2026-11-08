import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import '../../utilities/colors.dart';

class CarFrame {
  const CarFrame(this.asset, this.label);

  final String asset;
  final String label;
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _frames = [
    CarFrame('assets/front.png', 'Depan'),
    CarFrame('assets/side.png', 'Samping'),
    CarFrame('assets/rear.png', 'Belakang'),
    CarFrame('assets/top.png', 'Atas'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Car Viewer 360',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: const SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Car360Viewer(frames: HomePage._frames),
          ),
        ),
      ),
    );
  }
}

class Car360Viewer extends StatefulWidget {
  const Car360Viewer({
    super.key,
    required this.frames,
    this.dragSensitivity = 220,
  });

  final List<CarFrame> frames;
  final double dragSensitivity;

  @override
  State<Car360Viewer> createState() => _Car360ViewerState();
}

class _Car360ViewerState extends State<Car360Viewer>
    with SingleTickerProviderStateMixin {
  static const _spring = SpringDescription(
    mass: 1,
    stiffness: 110,
    damping: 21,
  );

  late final AnimationController _controller;
  int _lastHapticIndex = 0;

  int get _count => widget.frames.length;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this, value: 0);
    _controller.addListener(_onPositionChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final frame in widget.frames) {
      precacheImage(AssetImage(frame.asset), context);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onPositionChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onPositionChanged() {
    final index = _controller.value.round() % _count;
    if (index != _lastHapticIndex) {
      _lastHapticIndex = index;
      HapticFeedback.selectionClick();
    }
  }

  void _settleTo(double target, double velocity) {
    _controller.animateWith(
      SpringSimulation(_spring, _controller.value, target, velocity),
    );
  }

  void _onDragStart(DragStartDetails details) {
    _controller.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _controller.value -= details.delta.dx / widget.dragSensitivity;
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity =
        -details.velocity.pixelsPerSecond.dx / widget.dragSensitivity;
    final clamped = velocity.clamp(-6.0, 6.0);
    final target = (_controller.value + clamped * 0.18).roundToDouble();
    _settleTo(target, clamped);
  }

  void _step(int direction) {
    _controller.stop();
    _settleTo(_controller.value.roundToDouble() + direction, 0);
  }

  void _goTo(int index) {
    _controller.stop();
    final current = _controller.value;
    final wrapped = current % _count;
    var delta = index - wrapped;
    if (delta > _count / 2) delta -= _count;
    if (delta < -_count / 2) delta += _count;
    _settleTo(current + delta, 0);
  }

  @override
  Widget build(BuildContext context) {
    final width = math.min(MediaQuery.sizeOf(context).width - 32, 560.0);

    return SizedBox(
      width: width,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final position = _controller.value;
          final wrapped = position % _count;
          final current = wrapped.floor() % _count;
          final next = (current + 1) % _count;
          final raw = wrapped - wrapped.floor();
          final blend = raw * raw * (3 - 2 * raw);
          final active = wrapped.round() % _count;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: _onDragStart,
                onHorizontalDragUpdate: _onDragUpdate,
                onHorizontalDragEnd: _onDragEnd,
                child: _ViewerCard(
                  current: widget.frames[current].asset,
                  next: widget.frames[next].asset,
                  blend: blend,
                ),
              ),
              const SizedBox(height: 20),
              _LabelSwitcher(
                label: widget.frames[active].label,
                index: active,
                count: _count,
              ),
              const SizedBox(height: 16),
              _Controls(
                count: _count,
                active: active,
                onPrev: () => _step(-1),
                onNext: () => _step(1),
                onDot: _goTo,
              ),
              const SizedBox(height: 20),
              const _SwipeHint(),
            ],
          );
        },
      ),
    );
  }
}

class _ViewerCard extends StatelessWidget {
  const _ViewerCard({
    required this.current,
    required this.next,
    required this.blend,
  });

  final String current;
  final String next;
  final double blend;

  static const _shift = 18.0;
  static const _zoom = 1.06;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: RepaintBoundary(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Transform.translate(
                  offset: Offset(-blend * _shift, 0),
                  child: Transform.scale(
                    scale: _zoom,
                    child: Image.asset(
                      current,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      gaplessPlayback: true,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
                Opacity(
                  opacity: blend,
                  child: Transform.translate(
                    offset: Offset((1 - blend) * _shift, 0),
                    child: Transform.scale(
                      scale: _zoom,
                      child: Image.asset(
                        next,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        gaplessPlayback: true,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LabelSwitcher extends StatelessWidget {
  const _LabelSwitcher({
    required this.label,
    required this.index,
    required this.count,
  });

  final String label;
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.25),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Text(
            label,
            key: ValueKey(label),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${index + 1} / $count',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.count,
    required this.active,
    required this.onPrev,
    required this.onNext,
    required this.onDot,
  });

  final int count;
  final int active;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<int> onDot;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundButton(icon: Icons.chevron_left_rounded, onTap: onPrev),
        const SizedBox(width: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(count, (i) {
            final selected = i == active;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onDot(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  width: selected ? 26 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(width: 16),
        _RoundButton(icon: Icons.chevron_right_rounded, onTap: onNext),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: AppColors.primary, size: 26),
        ),
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.swipe_rounded, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          'Geser kiri / kanan untuk memutar',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
