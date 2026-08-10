import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/mesh_item.dart';
import '../theme/app_theme.dart';

class FleetLogisticsCard extends StatelessWidget {
  final FleetLogistics logistics;
  final bool isDark;

  const FleetLogisticsCard({
    super.key,
    required this.logistics,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    Color statusBg;
    Color statusBorder;
    Color statusTextColor;

    switch (logistics.status) {
      case FleetCapacityStatus.normal:
        statusBg = const Color(0x1F38BDF8);
        statusBorder = const Color(0x4D38BDF8);
        statusTextColor = AppTheme.primary;
        break;
      case FleetCapacityStatus.reached:
        statusBg = const Color(0x1F10B981);
        statusBorder = const Color(0x4D10B981);
        statusTextColor = AppTheme.accentEmerald;
        break;
      case FleetCapacityStatus.exceeded:
        statusBg = const Color(0x26F59E0B);
        statusBorder = const Color(0x66F59E0B);
        statusTextColor = AppTheme.accentAmber;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0x66F59E0B),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Combined Transport Fleet Requirement',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.accentAmber,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x33F59E0B),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Fleet',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accentAmber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Status Alert Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusBg,
              border: Border.all(color: statusBorder),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppTheme.amberGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_shipping_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        logistics.status.title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: statusTextColor,
                        ),
                      ),
                      Text(
                        'Total: ${logistics.totalWeightTonnes.toStringAsFixed(2)} Tonnes (${logistics.totalWeightKg.toStringAsFixed(0)} kg)',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.textDarkMain : AppTheme.textLightMain,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Lorry Breakdown Grid
          Row(
            children: [
              Expanded(
                child: _buildLorryBox(
                  title: '🚚 20FT Lorry',
                  count: logistics.lorry20ftCount,
                  utilization: logistics.lorry20ftUtilization,
                  capacityLabel: 'Max 11T / lorry',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildLorryBox(
                  title: '🚛 40FT Trailer',
                  count: logistics.lorry40ftCount,
                  utilization: logistics.lorry40ftUtilization,
                  capacityLabel: 'Max 25T / lorry',
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLorryBox({
    required String title,
    required int count,
    required double utilization,
    required String capacityLabel,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.inputDark : AppTheme.inputLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '$count',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (utilization / 100.0).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                capacityLabel,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? AppTheme.textDarkMuted : AppTheme.textLightMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${utilization.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? AppTheme.textDarkMuted : AppTheme.textLightMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
