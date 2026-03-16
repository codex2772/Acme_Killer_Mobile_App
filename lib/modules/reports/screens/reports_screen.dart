import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../controllers/reports_controller.dart';

class ReportsScreen extends GetView<ReportsController> {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const Text('Reports & Analytics',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined,
                color: AppColors.textSecondary),
            tooltip: 'Export Summary',
            onPressed: () => Get.snackbar(
              'Export', 'Reports summary exported!',
              backgroundColor: AppColors.bgCard,
              colorText: AppColors.textPrimary,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(children: [
              const Icon(Icons.bar_chart_outlined,
                  color: AppColors.goldPrimary, size: 15),
              const SizedBox(width: 7),
              const Text('Click any report to generate it',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            ]),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 30),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.95,
              ),
              itemCount: ReportsController.reportTypes.length,
              itemBuilder: (_, i) {
                final r = ReportsController.reportTypes[i];
                return _ReportCard(report: r);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportType report;
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final color = Color(report.colorValue);

    return GestureDetector(
      onTap: () {
        Get.find<ReportsController>().selectedReportId.value = report.id;
        Get.toNamed(AppRoutes.reportDetail, arguments: report.id);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconFor(report.iconKey), color: color, size: 22),
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              report.title,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),

            // Desc
            Expanded(
              child: Text(
                report.desc,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 11, height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Generate button
            Row(
              children: [
                Text(
                  'Generate',
                  style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios_rounded, color: color, size: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String key) {
    switch (key) {
      case 'trending':  return Icons.trending_up_rounded;
      case 'barChart':  return Icons.bar_chart_rounded;
      case 'alert':     return Icons.warning_amber_rounded;
      case 'people':    return Icons.people_outline;
      case 'store':     return Icons.store_outlined;
      case 'rupee':     return Icons.currency_rupee_rounded;
      case 'gift':      return Icons.card_giftcard_outlined;
      case 'clock':     return Icons.schedule_outlined;
      case 'calendar':  return Icons.calendar_today_outlined;
      case 'fileText':  return Icons.description_outlined;
      default:          return Icons.bar_chart_rounded;
    }
  }
}
