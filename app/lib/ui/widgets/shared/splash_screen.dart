import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  final Widget child;
  final Duration initialDelay;
  final Duration animationDuration;

  const SplashScreen({
    super.key,
    required this.child,
    this.initialDelay = const Duration(milliseconds: 500),
    this.animationDuration = const Duration(milliseconds: 1200),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _initialScaleAnimation;
  late Animation<double> _finalScaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _contentScaleAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Initial bounce animation (logo gets bigger then smaller)
    _initialScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 2.0,
          end: 1.5,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5)),
    );

    // Final scale up animation (covers the whole screen)
    _finalScaleAnimation = Tween<double>(begin: 1.5, end: 100.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    // Fade animation for the white container
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
      ),
    );

    // Content scale animation
    _contentScaleAnimation = Tween<double>(begin: 1.1, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 0.9, curve: Curves.easeOutExpo),
      ),
    );
  }

  void _startAnimations() {
    Future.delayed(widget.initialDelay, () {
      if (mounted) {
        _controller.forward().whenComplete(() {
          if (mounted) {
            setState(() {
              _isVisible = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The main screen underneath with scale animation
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _contentScaleAnimation.value,
              child: widget.child,
            );
          },
        ),
        // The splash screen with SVG logo
        if (_isVisible)
          Stack(
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    ),
                  );
                },
              ),
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale:
                          _controller.value >= 0.5
                              ? _finalScaleAnimation.value
                              : _initialScaleAnimation.value,
                      child: SvgPicture.asset('assets/icons/logo_mask.svg'),
                    );
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }
}
