import 'package:flutter/material.dart';
import '../l10n/l10n_ext.dart';
import '../theme.dart';
import '../widgets.dart';

/// Soft-ask: sistem bildirim diyaloğundan önce değer anlatır (v4).
/// Gerçek OS izni henüz yok — tercihi kaydeder.
class ReminderPermissionSheet extends StatelessWidget {
  final int hour;
  const ReminderPermissionSheet({super.key, required this.hour});

  static Future<bool> show(BuildContext context, {required int hour}) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => ReminderPermissionSheet(hour: hour),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = '${hour.toString().padLeft(2, '0')}:00';
    return Padding(
      padding: EdgeInsets.fromLTRB(
          22, 12, 22, 28 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(height: 22),
          const MediaImage('assets/img/reminder_bell.svg',
              height: 96, width: 96),
          const SizedBox(height: 18),
          Text(
            l10n.reminderSoftTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 25, fontWeight: FontWeight.w800, height: 1.25),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.reminderSoftSub,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14.5,
                height: 1.55,
                color: AppColors.navy.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: cardDecoration(),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.reminderTime,
                          style: const TextStyle(
                              fontSize: 14.5, fontWeight: FontWeight.w800)),
                      Text(l10n.reminderSoftHint,
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.navy.withValues(alpha: 0.55))),
                    ],
                  ),
                ),
                Text(label,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.teal)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.reminderAllow),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.reminderNotNow,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy.withValues(alpha: 0.5))),
          ),
        ],
      ),
    );
  }
}
