import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/di/injection.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/auth/data/auth_local_datasource.dart';
import '../../../features/notifications/notification_service.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/jogja_page_header.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  static const _storageKey = 'tpm_feedback_entries';
  static const _bgTop = Color(0xFF181821);
  static const _bgMid = Color(0xFF0F0F16);
  static const _bgBottom = Color(0xFF06070B);

  final _suggestionController = TextEditingController();
  final _impressionController = TextEditingController();

  var _rating = 5;
  var _entries = <_FeedbackEntry>[];
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    _suggestionController.dispose();
    _impressionController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    final prefs = getIt<SharedPreferences>();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;

      setState(() {
        _entries = decoded
            .whereType<Map<String, dynamic>>()
            .map(_FeedbackEntry.fromJson)
            .toList();
      });
    } catch (_) {
      await prefs.remove(_storageKey);
    }
  }

  Future<void> _save() async {
    final suggestion = _suggestionController.text.trim();
    final impression = _impressionController.text.trim();

    if (suggestion.length < 5 || impression.length < 5) {
      _showMessage(
        title: 'Belum lengkap',
        message: 'Isi saran dan kesan minimal 5 karakter.',
      );
      return;
    }

    setState(() => _saving = true);
    HapticFeedback.lightImpact();

    final user = await getIt<AuthLocalDataSource>().currentUser();
    final entry = _FeedbackEntry(
      name: user?.name.trim().isEmpty ?? true ? 'Pelancong' : user!.name.trim(),
      rating: _rating,
      suggestion: suggestion,
      impression: impression,
      createdAt: DateTime.now(),
    );

    var savedOnline = false;
    try {
      await getIt<ApiClient>().dio.post<Map<String, dynamic>>(
        '/feedback',
        data: {
          'category': 'GENERAL',
          'rating': _rating,
          'message': 'Saran: $suggestion\n\nKesan: $impression',
        },
      );
      savedOnline = true;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status == 401 || status == 403) {
        if (mounted) {
          setState(() => _saving = false);
          _showMessage(
            title: 'Sesi berakhir',
            message: 'Silakan masuk kembali agar masukanmu bisa disimpan.',
          );
        }
        return;
      }
    } catch (_) {
      // Jika jaringan/server gagal, data tetap disimpan lokal sebagai fallback offline.
    }

    final updated = [entry.copyWith(synced: savedOnline), ..._entries].take(8).toList();
    final prefs = getIt<SharedPreferences>();
    await prefs.setString(
      _storageKey,
      jsonEncode(updated.map((item) => item.toJson()).toList()),
    );

    try {
      await getIt<NotificationService>().showImmediate(
        savedOnline ? 'Masukan terkirim' : 'Masukan tersimpan offline',
        savedOnline
            ? 'Terima kasih, masukan kamu sudah tersimpan.'
            : 'Backend belum dapat dihubungi. Masukan tersimpan lokal.',
      );
    } catch (_) {
      // Izin notifikasi boleh ditolak; feedback tetap diproses.
    }

    if (!mounted) return;

    setState(() {
      _entries = updated;
      _saving = false;
      _suggestionController.clear();
      _impressionController.clear();
    });

    _showMessage(
      title: 'Tersimpan',
      message: 'Saran dan kesan berhasil disimpan. Matur nuwun.',
    );
  }

  void _showMessage({
    required String title,
    required String message,
  }) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(title),
        message: Text(message),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.18,
          colors: [
            Color(0xFF282836),
            _bgTop,
            _bgMid,
            _bgBottom,
          ],
          stops: [0, 0.32, 0.68, 1],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 126),
          children: [
            const JogjaPageHeader(title: 'Saran & Kesan TPM', subtitle: 'Tulis pengalamanmu setelah mencoba aplikasi ini.'),
            const SizedBox(height: 18),
            _FeedbackForm(
              rating: _rating,
              saving: _saving,
              suggestionController: _suggestionController,
              impressionController: _impressionController,
              onRatingChanged: (value) {
                if (value == null) return;
                HapticFeedback.selectionClick();
                setState(() => _rating = value);
              },
              onSave: _saving ? null : _save,
            ),
            const SizedBox(height: 22),
            _PreviousFeedback(entries: _entries),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _FeedbackHeader extends StatelessWidget {
  const _FeedbackHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentSecondary.withOpacity(0.14),
            border: Border.all(
              color: CupertinoColors.white.withOpacity(0.10),
            ),
          ),
          child: const Icon(
            CupertinoIcons.chat_bubble_text_fill,
            size: 21,
            color: AppColors.accentSecondary,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saran & Kesan TPM',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.displayBold34.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Catatan evaluasi final yang tersimpan lokal.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.textRegular13.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeedbackForm extends StatelessWidget {
  const _FeedbackForm({
    required this.rating,
    required this.saving,
    required this.suggestionController,
    required this.impressionController,
    required this.onRatingChanged,
    required this.onSave,
  });

  final int rating;
  final bool saving;
  final TextEditingController suggestionController;
  final TextEditingController impressionController;
  final ValueChanged<int?> onRatingChanged;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 34,
      opacity: 0.078,
      borderRadius: 30,
      borderColor: CupertinoColors.white.withOpacity(0.12),
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.fromLTRB(17, 17, 17, 17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.2,
            colors: [
              AppColors.accentSecondary.withOpacity(0.13),
              CupertinoColors.white.withOpacity(0.038),
              CupertinoColors.black.withOpacity(0.02),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Form Evaluasi',
              style: AppTypography.displaySemi22.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: -0.55,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Berikan rating, saran, dan kesan untuk demo TPM.',
              style: AppTypography.textRegular13.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),
            CupertinoSlidingSegmentedControl<int>(
              groupValue: rating,
              thumbColor: CupertinoColors.white.withOpacity(0.16),
              backgroundColor: CupertinoColors.white.withOpacity(0.07),
              children: const {
                1: Text('1'),
                2: Text('2'),
                3: Text('3'),
                4: Text('4'),
                5: Text('5'),
              },
              onValueChanged: onRatingChanged,
            ),
            const SizedBox(height: 14),
            _FeedbackField(
              controller: suggestionController,
              placeholder: 'Saran untuk pengembangan aplikasi',
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            _FeedbackField(
              controller: impressionController,
              placeholder: 'Kesan setelah mencoba JogjaSplorasi',
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            _SaveButton(
              saving: saving,
              onTap: onSave,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackField extends StatelessWidget {
  const _FeedbackField({
    required this.controller,
    required this.placeholder,
    required this.maxLines,
  });

  final TextEditingController controller;
  final String placeholder;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: CupertinoColors.white.withOpacity(0.055),
        border: Border.all(
          color: CupertinoColors.white.withOpacity(0.08),
          width: 0.8,
        ),
      ),
      child: CupertinoTextField.borderless(
        controller: controller,
        minLines: maxLines,
        maxLines: maxLines,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        placeholder: placeholder,
        placeholderStyle: AppTypography.textRegular13.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w400,
        ),
        style: AppTypography.textRegular13.copyWith(
          color: AppColors.textPrimary,
          height: 1.4,
          fontWeight: FontWeight.w400,
        ),
        cursorColor: AppColors.textPrimary,
      ),
    );
  }
}

class _SaveButton extends StatefulWidget {
  const _SaveButton({
    required this.saving,
    required this.onTap,
  });

  final bool saving;
  final VoidCallback? onTap;

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) {
        _setPressed(false);
        widget.onTap?.call();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accentPrimary.withOpacity(0.92),
                AppColors.accentPrimary.withOpacity(0.68),
                AppColors.accentSecondary.withOpacity(0.28),
              ],
            ),
            border: Border.all(
              color: CupertinoColors.white.withOpacity(0.18),
              width: 0.8,
            ),
          ),
          child: widget.saving
              ? const CupertinoActivityIndicator(
                  color: AppColors.textPrimary,
                )
              : Text(
                  'Simpan Feedback',
                  style: AppTypography.textMedium15.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}

class _PreviousFeedback extends StatelessWidget {
  const _PreviousFeedback({required this.entries});

  final List<_FeedbackEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Text(
        'Belum ada feedback tersimpan.',
        style: AppTypography.textRegular13.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w400,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riwayat Lokal',
          style: AppTypography.displaySemi20.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 11),
        ...entries.take(3).map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  blur: 26,
                  opacity: 0.068,
                  borderRadius: 22,
                  borderColor: CupertinoColors.white.withOpacity(0.10),
                  padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${entry.name} - ${entry.rating}/5',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.textMedium15.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Text(
                            _shortDate(entry.createdAt),
                            style: AppTypography.captionSmall11.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.suggestion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.textRegular13.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.35,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }

  static String _shortDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _FeedbackEntry {
  const _FeedbackEntry({
    required this.name,
    required this.rating,
    required this.suggestion,
    required this.impression,
    required this.createdAt,
    this.synced = false,
  });

  final String name;
  final int rating;
  final String suggestion;
  final String impression;
  final DateTime createdAt;
  final bool synced;

  _FeedbackEntry copyWith({bool? synced}) {
    return _FeedbackEntry(
      name: name,
      rating: rating,
      suggestion: suggestion,
      impression: impression,
      createdAt: createdAt,
      synced: synced ?? this.synced,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'rating': rating,
        'suggestion': suggestion,
        'impression': impression,
        'createdAt': createdAt.toIso8601String(),
        'synced': synced,
      };

  factory _FeedbackEntry.fromJson(Map<String, dynamic> json) {
    return _FeedbackEntry(
      name: json['name'] as String? ?? 'Pelancong',
      rating: json['rating'] as int? ?? 5,
      suggestion: json['suggestion'] as String? ?? '',
      impression: json['impression'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      synced: json['synced'] as bool? ?? false,
    );
  }
}
