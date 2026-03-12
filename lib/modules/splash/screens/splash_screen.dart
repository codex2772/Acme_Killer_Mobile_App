import 'package:acme_killer_mobile_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:particles_flutter/particles_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> progressAnimation;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    progressAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () {
      Get.offAllNamed("/role-select");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          /// GOLD PARTICLES
          CircularParticle(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            particleColor: AppColors.goldPrimary,
            numberOfParticles: 40,
            speedOfParticles: 0.5,
            maxParticleSize: 6,
            awayRadius: 120,
            isRandSize: true,
            isRandomColor: false,
            connectDots: false,
          ),

          /// MAIN CONTENT
          Center(
            child: FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// LOGO
                    SvgPicture.asset(
                      "assets/login/logo.svg",
                      height: 110,
                      width: 110,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 30),

                    /// TITLE
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                        children: [
                          TextSpan(
                            text: "Jewel",
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: "ERP",
                            style: TextStyle(color: AppColors.goldPrimary),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Jewelry Enterprise Resource Planning",
                      style: TextStyle(
                        color: Colors.white70,
                        letterSpacing: 2,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 30),

                    Container(
                      width: 80,
                      height: 2,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.goldPrimary,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Manage your jewelry business with elegance — "
                        "inventory, billing, customers and more.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, height: 1.6),
                      ),
                    ),

                    const SizedBox(height: 40),

                    const SizedBox(height: 40),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: AnimatedBuilder(
                        animation: progressAnimation,
                        builder: (context, child) {
                          return Column(
                            children: [
                              LinearProgressIndicator(
                                value: progressAnimation.value,
                                minHeight: 6,
                                backgroundColor: Colors.white10,
                                valueColor: const AlwaysStoppedAnimation(
                                  AppColors.goldPrimary,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                "${(progressAnimation.value * 100).toInt()}%",
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// FOOTER
          const Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "© 2026 JewelERP. Crafted with precision.",
                style: TextStyle(color: Colors.white30, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
