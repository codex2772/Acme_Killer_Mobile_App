import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 550));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.07), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  SvgPicture.asset('assets/login/logo.svg', height: 72),
                  const SizedBox(height: 22),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(text: 'Select Your ', style: TextStyle(color: AppColors.textPrimary)),
                        TextSpan(text: 'Role', style: TextStyle(color: AppColors.goldPrimary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Choose how you'd like to access JewelERP",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                  const SizedBox(height: 36),

                  // Owner card
                  _RoleCard(
                    title: 'Owner',
                    description: 'Full access to all stores, staff management, revenue & analytics',
                    icon: Icons.storefront_rounded,
                    color: AppColors.goldPrimary,
                    features: const ['Multi-Store', 'Analytics', 'Staff Mgmt', 'Full Control'],
                    onTap: () => Get.toNamed(AppRoutes.login, arguments: 'owner'),
                  ),
                  const SizedBox(height: 16),

                  // Staff card
                  _RoleCard(
                    title: 'Staff',
                    description: 'Billing, inventory & customer management for daily operations',
                    icon: Icons.badge_rounded,
                    color: AppColors.info,
                    features: const ['Billing', 'Inventory', 'Customers'],
                    onTap: () => Get.toNamed(AppRoutes.login, arguments: 'staff'),
                  ),

                  const SizedBox(height: 44),
                  const Text('© 2026 JewelERP. Crafted with precision.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String title, description;
  final IconData icon;
  final Color color;
  final List<String> features;
  final VoidCallback onTap;
  const _RoleCard({required this.title, required this.description,
      required this.icon, required this.color,
      required this.features, required this.onTap});

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _pressed ? widget.color.withOpacity(0.6) : AppColors.border,
              width: _pressed ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_pressed ? 0.22 : 0.1),
                blurRadius: _pressed ? 28 : 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 70, width: 70,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: widget.color.withOpacity(0.3), width: 1.5),
                ),
                child: Icon(widget.icon, color: widget.color, size: 32),
              ),
              const SizedBox(height: 14),
              Text(widget.title,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(widget.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.5)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8, runSpacing: 8,
                alignment: WrapAlignment.center,
                children: widget.features.map((f) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: widget.color.withOpacity(0.25)),
                      ),
                      child: Text(f,
                          style: TextStyle(
                              fontSize: 11, color: widget.color.withOpacity(0.9),
                              fontWeight: FontWeight.w500)),
                    )).toList(),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: widget.color.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Login as ${widget.title}',
                        style: TextStyle(
                            color: widget.color, fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios_rounded, size: 13, color: widget.color),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
