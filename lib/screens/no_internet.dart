import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NoInternet extends StatefulWidget {
  const NoInternet({super.key});

  @override
  State<NoInternet> createState() => _NoInternetState();
}

class _NoInternetState extends State<NoInternet> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<Color?> _animationColor;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final colorScheme = Theme.of(context).colorScheme;
    _animationColor = ColorTween(begin: colorScheme.primary.withOpacity(0.6), end: colorScheme.primary).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Icon(FontAwesomeIcons.wifi.data, color: _animationColor.value, size: 100),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              'No Connection',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: colorScheme.primary),
            ),
            const SizedBox(height: 10),
            Text(
              'Please check your internet connection\nand try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: colorScheme.primary.withOpacity(.6)),
            ),
          ],
        ),
      ),
    );
  }
}
