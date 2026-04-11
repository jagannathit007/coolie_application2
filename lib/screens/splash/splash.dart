import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_constants.dart';
import 'splash_ctrl.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashCtrl>(
      init: SplashCtrl(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Constants.instance.lightPrimary.withOpacity(0.06), Constants.instance.lightSecondary.withOpacity(0.05)],
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: controller.animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: controller.scaleAnimation.value,
                          child: Transform.translate(
                            offset: Offset(0, -20 * (1 - controller.fadeAnimation.value)),
                            child: Opacity(
                              opacity: controller.fadeAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 24, spreadRadius: 2, offset: const Offset(0, 10))],
                                ),
                                child: Image.asset("assets/logo.png", height: 100, width: 100),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    AnimatedBuilder(
                      animation: controller.animationController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: controller.fadeAnimation.value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - controller.fadeAnimation.value)),
                            child: Text(
                              'Coolie',
                              style: GoogleFonts.poppins(fontSize: 34, fontWeight: FontWeight.w700, color: Constants.instance.primary, letterSpacing: 1.2),
                            ),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: controller.animationController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: controller.fadeAnimation.value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - controller.fadeAnimation.value)),
                            child: Text(
                              'Track Your Video Creator',
                              style: GoogleFonts.poppins(fontSize: 15, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), letterSpacing: 0.8),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedBuilder(
                    animation: controller.animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: controller.fadeAnimation.value,
                        child: SizedBox(
                          width: 180,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              backgroundColor: Constants.instance.lightPrimary.withOpacity(0.15),
                              valueColor: AlwaysStoppedAnimation<Color>(Constants.instance.lightPrimary),
                              minHeight: 6,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
