import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'splash_ctrl.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashCtrl>(
      init: SplashCtrl(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              const _AmbientBackground(),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: controller.animationController,
                      builder: (context, _) => Opacity(
                        opacity: controller.fadeAnimation.value,
                        child: Transform.scale(scale: controller.scaleAnimation.value, child: const _LogoWidget()),
                      ),
                    ),
                    const SizedBox(height: 32),
                    AnimatedBuilder(
                      animation: controller.animationController,
                      builder: (context, _) => Opacity(
                        opacity: controller.fadeAnimation.value,
                        child: Transform.translate(offset: Offset(0, controller.slideAnimation.value), child: const _AppNameWidget()),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 70,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: controller.animationController,
                  builder: (context, _) => Opacity(opacity: controller.fadeAnimation.value, child: const _LoadingBar()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          left: -80,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFC60000).withOpacity(0.05)),
          ),
        ),
        Positioned(
          bottom: -100,
          right: -60,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFF4B4B).withOpacity(0.04)),
          ),
        ),
      ],
    );
  }
}

class _LogoWidget extends StatelessWidget {
  const _LogoWidget();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 128,
          height: 128,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFEF2F2)),
        ),
        Container(
          width: 104,
          height: 104,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFEE2E2)),
        ),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFC60000), Color(0xFFFF4B4B)]),
            boxShadow: [BoxShadow(color: const Color(0xFFC60000).withOpacity(0.30), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: ClipOval(child: Image.asset("assets/logo.png", height: 48, width: 48, fit: BoxFit.contain)),
        ),
      ],
    );
  }
}

class _AppNameWidget extends StatelessWidget {
  const _AppNameWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFFC60000), Color(0xFFFF4B4B)]).createShader(bounds),
          child: Text(
            'Coolie',
            style: GoogleFonts.poppins(fontSize: 44, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 2.0),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(colors: [Color(0xFFC60000), Color(0xFFFF4B4B)]),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'APPLY. TRACK. RENEW.',
          style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8), letterSpacing: 2.5, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFFFEF2F2),
            border: Border.all(color: const Color(0xFFFECACA), width: 1),
          ),
          child: Text(
            'v2.0.1',
            style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFFC60000), fontWeight: FontWeight.w600, letterSpacing: 1),
          ),
        ),
      ],
    );
  }
}

class _LoadingBar extends StatefulWidget {
  const _LoadingBar();

  @override
  State<_LoadingBar> createState() => _LoadingBarState();
}

class _LoadingBarState extends State<_LoadingBar> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..forward();
    _progress = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _progress,
          builder: (context, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: Stack(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: const Color(0xFFFEE2E2)),
                ),
                FractionallySizedBox(
                  widthFactor: _progress.value,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: const LinearGradient(colors: [Color(0xFFC60000), Color(0xFFFF4B4B)]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text('Loading...', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8), letterSpacing: 1.5)),
      ],
    );
  }
}
