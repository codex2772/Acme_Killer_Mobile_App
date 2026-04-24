import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/rates_schemes_controller.dart';

// ════════════════════════════════════════════════════════════════════
// RateBoardScreen — Fullscreen display board
//
// mirrors Electron renderRateBoard():
//   • Full-screen layout, no sidebar/topbar — pure rate display
//   • Gold 24K, 22K, 18K, Silver 925, Platinum 950 big cards
//   • ₹/gram + ₹/tola for each metal
//   • Store name + current time in header
//   • Auto-refreshes rates every 60 seconds
//   • Exit button → pops back to todayRates
// ════════════════════════════════════════════════════════════════════
class RateBoardScreen extends StatefulWidget {
  const RateBoardScreen({super.key});

  @override
  State<RateBoardScreen> createState() => _RateBoardScreenState();
}

class _RateBoardScreenState extends State<RateBoardScreen>
    with TickerProviderStateMixin {
  late final RatesSchemesController _ctrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  String _timeStr = '';
  String _dateStr = '';

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<RatesSchemesController>();

    // Force landscape for the board
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    // Hide status bar for immersive board feel
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _updateTime();

    // Tick every second to keep time fresh
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted) _updateTime();
    });

    // Auto-refresh rates every 60 seconds
    Stream.periodic(const Duration(seconds: 60)).listen((_) {
      if (mounted) _ctrl.refreshRates();
    });

    // Subtle pulse animation on rate values
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  void _updateTime() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final min = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    setState(() {
      _timeStr = '$h:$min $ampm';
      _dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';
    });
  }

  @override
  void dispose() {
    // Restore normal orientations on exit
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080812),
      body: Obx(() {
        final metals = _ctrl.metals;
        // Board shows: Gold 24K, 22K, 18K, Silver, Platinum (mirrors Electron)
        final boardMetals = metals.take(6).toList();

        return Stack(
          children: [
            // ── Decorative background shimmer ──────────────────────
            Positioned.fill(child: _BackgroundShimmer()),

            Column(
              children: [
                // ── Header ──────────────────────────────────────────
                _BoardHeader(
                  timeStr: _timeStr,
                  dateStr: _dateStr,
                  isLoading: _ctrl.isLoadingRates.value,
                  onExit: () => Get.back(),
                  onRefresh: () => _ctrl.refreshRates(),
                ),

                // ── Rate Cards Grid ──────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: LayoutBuilder(
                      builder: (ctx, constraints) {
                        // Responsive: 3 cols in landscape, 2 in portrait
                        final isLandscape =
                            constraints.maxWidth > constraints.maxHeight;
                        final cols = isLandscape ? 3 : 2;
                        return GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: isLandscape ? 1.8 : 1.4,
                              ),
                          itemCount: boardMetals.length,
                          itemBuilder: (_, i) => _BoardRateCard(
                            metal: boardMetals[i],
                            pulseAnim: _pulseAnim,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // ── Footer ticker ────────────────────────────────────
                _TickerBar(metals: metals),
              ],
            ),
          ],
        );
      }),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// _BoardHeader
// mirrors Electron: rate-board-header with store name + time + exit
// ════════════════════════════════════════════════════════════════════
class _BoardHeader extends StatelessWidget {
  final String timeStr, dateStr;
  final bool isLoading;
  final VoidCallback onExit, onRefresh;

  const _BoardHeader({
    required this.timeStr,
    required this.dateStr,
    required this.isLoading,
    required this.onExit,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1A),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF2A2A3A), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldPrimary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Brand logo placeholder (diamond icon as logo stand-in)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.goldLight.withOpacity(0.3),
                  AppColors.goldDark.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: AppColors.goldPrimary.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.diamond_outlined,
              color: AppColors.goldPrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Store name + subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Jewel',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextSpan(
                      text: 'ERP',
                      style: TextStyle(
                        color: AppColors.goldPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                "Today's Live Rates",
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Date + time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeStr,
                style: const TextStyle(
                  color: AppColors.goldPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                dateStr,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Refresh button
          GestureDetector(
            onTap: onRefresh,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: AppColors.goldPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
            ),
          ),

          const SizedBox(width: 8),

          // Exit button — mirrors Electron "Exit" button
          GestureDetector(
            onTap: onExit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                    size: 14,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Exit',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// _BoardRateCard — Large display card, mirrors Electron rate-board-card
// Shows metal name, ₹/gram (large), ₹/tola
// ════════════════════════════════════════════════════════════════════
class _BoardRateCard extends StatelessWidget {
  final MetalRate metal;
  final Animation<double> pulseAnim;

  const _BoardRateCard({required this.metal, required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    final color = Color(metal.colorValue);
    final isGold = metal.metal.contains('Gold');

    return Obx(() {
      final rate = metal.rate.value;
      final tola = metal.tolaRate;
      final trendUp = metal.trendUp.value;
      final change = metal.change.value;

      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF12121F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.10),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.06), const Color(0xFF12121F)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top row: metal name + trend badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Metal icon + name
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isGold
                            ? Icons.circle
                            : metal.metal.contains('Silver')
                            ? Icons.circle_outlined
                            : Icons.hexagon_outlined,
                        color: color,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      metal.metal,
                      style: TextStyle(
                        color: color.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),

                // Trend badge
                if (change.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: trendUp
                          ? AppColors.success.withOpacity(0.12)
                          : AppColors.error.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trendUp
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          color: trendUp ? AppColors.success : AppColors.error,
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          change,
                          style: TextStyle(
                            color: trendUp
                                ? AppColors.success
                                : AppColors.error,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // Main rate value — large, bold
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: AnimatedBuilder(
                    animation: pulseAnim,
                    builder: (_, child) => Opacity(
                      opacity: 0.85 + (pulseAnim.value * 0.15),
                      child: child,
                    ),
                    child: Text(
                      '₹${_fmt(rate)}',
                      style: TextStyle(
                        color: color,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
                Text(
                  '/gram',
                  style: TextStyle(
                    color: color.withOpacity(0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // Tola rate
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '₹${_fmt(tola)} / tola',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  String _fmt(int v) {
    // Indian number format: 6,285 or 73,500
    if (v >= 10000) {
      final s = v.toString();
      final last3 = s.substring(s.length - 3);
      final rest = s.substring(0, s.length - 3);
      final withCommas = rest.replaceAllMapped(
        RegExp(r'(\d{1,2})(?=(\d{2})+$)'),
        (m) => '${m[1]},',
      );
      return '$withCommas,$last3';
    }
    if (v >= 1000) {
      final s = v.toString();
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return v.toString();
  }
}

// ════════════════════════════════════════════════════════════════════
// _TickerBar — bottom scrolling ticker with all rates
// ════════════════════════════════════════════════════════════════════
class _TickerBar extends StatefulWidget {
  final List<MetalRate> metals;
  const _TickerBar({required this.metals});

  @override
  State<_TickerBar> createState() => _TickerBarState();
}

class _TickerBarState extends State<_TickerBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scrollCtrl;
  late final Animation<double> _scrollAnim;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    _scrollAnim = Tween<double>(begin: 0, end: 1).animate(_scrollCtrl);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.goldPrimary.withOpacity(0.08),
        border: const Border(
          top: BorderSide(color: Color(0xFF2A2A3A), width: 1),
        ),
      ),
      child: Obx(() {
        final tickerText = widget.metals
            .map((m) => '${m.metal}  ₹${m.rate.value}/g  •  ')
            .join('');

        return ClipRect(
          child: AnimatedBuilder(
            animation: _scrollAnim,
            builder: (_, __) {
              return FractionalTranslation(
                translation: Offset(-_scrollAnim.value, 0),
                child: Row(
                  children: [
                    _TickerText(text: tickerText),
                    _TickerText(text: tickerText),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

class _TickerText extends StatelessWidget {
  final String text;
  const _TickerText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.fiber_manual_record,
            color: AppColors.goldPrimary,
            size: 6,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.goldPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// _BackgroundShimmer — decorative animated background
// ════════════════════════════════════════════════════════════════════
class _BackgroundShimmer extends StatefulWidget {
  @override
  State<_BackgroundShimmer> createState() => _BackgroundShimmerState();
}

class _BackgroundShimmerState extends State<_BackgroundShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(painter: _ShimmerPainter(_ctrl.value)),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double t;
  _ShimmerPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Subtle gold glow top-left
    paint.shader = RadialGradient(
      center: Alignment(-0.8 + t * 0.3, -0.8 + t * 0.2),
      radius: 0.7,
      colors: [const Color(0xFFD4AF37).withOpacity(0.04), Colors.transparent],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Subtle blue glow bottom-right
    paint.shader = RadialGradient(
      center: Alignment(0.9 - t * 0.2, 0.9 - t * 0.2),
      radius: 0.6,
      colors: [const Color(0xFF1A1A2E).withOpacity(0.6), Colors.transparent],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) => old.t != t;
}
