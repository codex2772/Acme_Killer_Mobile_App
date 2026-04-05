import 'package:acme_killer_mobile_app/core/constants/app_colors.dart';
import 'package:acme_killer_mobile_app/core/controllers/auth_controller.dart';
import 'package:acme_killer_mobile_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:particles_flutter/particles_flutter.dart';

// ════════════════════════════════════════════════════════════════════
// SplashScreen — FUNCTIONALITY CHANGED
//
// Before: always navigated to roleSelect after 4 seconds.
//
// Now (mirrors Electron renderer.js DOMContentLoaded):
//   1. Show splash animation
//   2. Try Auth.tryRestoreSession()
//      → success → go directly to dashboard (user stays logged in)
//      → failure → go to roleSelect (user logs in fresh)
//
// This is the core session-persistence feature from Electron:
//   if (window.jewelERP.auth) {
//     const restored = await Auth.tryRestoreSession();
//     if (restored) { state.currentPage = 'dashboard'; render(); return; }
//   }
// ════════════════════════════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double>   _fade;
  late Animation<double>   _scale;
  late Animation<double>   _progress;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _fade     = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _scale    = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _progress = Tween<double>(begin: 0, end: 1).animate(_animCtrl);
    _animCtrl.forward();
    _boot();
  }

  // ── Core boot sequence ────────────────────────────────────────────
  Future<void> _boot() async {
    // Allow splash to show for at least 1.5 seconds
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    try {
      final auth = Get.find<AuthController>();

      // ── Try to restore session from persisted refresh token ──
      // mirrors Electron: Auth.tryRestoreSession()
      final restored = await auth.tryRestoreSession();
      if (!mounted) return;

      if (restored) {
        // Session valid → skip login, go straight to dashboard
        // Also kick off background data pre-fetch (mirrors Auth.preloadData())
        auth.preloadData();
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        // No valid session → show role select → login
        Get.offAllNamed(AppRoutes.roleSelect);
      }
    } catch (_) {
      if (mounted) Get.offAllNamed(AppRoutes.roleSelect);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(children: [

        // Gold particle background
        CircularParticle(
          width:  MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          particleColor: AppColors.goldPrimary,
          numberOfParticles: 40, speedOfParticles: 0.5, maxParticleSize: 6,
          awayRadius: 120, isRandSize: true, isRandomColor: false, connectDots: false,
        ),

        // Main content
        Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                SvgPicture.asset('assets/login/logo.svg', height: 110, width: 110, fit: BoxFit.contain),
                const SizedBox(height: 30),

                RichText(text: const TextSpan(
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 2),
                  children: [
                    TextSpan(text: 'Jewel', style: TextStyle(color: Colors.white)),
                    TextSpan(text: 'ERP',   style: TextStyle(color: AppColors.goldPrimary)),
                  ],
                )),
                const SizedBox(height: 10),

                const Text('Jewelry Enterprise Resource Planning',
                    style: TextStyle(color: Colors.white70, letterSpacing: 2, fontSize: 14)),
                const SizedBox(height: 30),

                Container(width: 80, height: 2,
                    decoration: const BoxDecoration(gradient: LinearGradient(
                        colors: [Colors.transparent, AppColors.goldPrimary, Colors.transparent]))),
                const SizedBox(height: 20),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Manage your jewelry business with elegance — inventory, billing, customers and more.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, height: 1.6),
                  ),
                ),
                const SizedBox(height: 50),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: AnimatedBuilder(
                    animation: _progress,
                    builder: (_, __) => Column(children: [
                      LinearProgressIndicator(
                        value: _progress.value, minHeight: 6,
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation(AppColors.goldPrimary),
                      ),
                      const SizedBox(height: 10),
                      Text('${(_progress.value * 100).toInt()}%',
                          style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ),

        const Positioned(
          bottom: 20, left: 0, right: 0,
          child: Center(child: Text('© 2026 JewelERP. Crafted with precision.',
              style: TextStyle(color: Colors.white30, fontSize: 12))),
        ),
      ]),
    );
  }

  @override
  void dispose() { _animCtrl.dispose(); super.dispose(); }
}
