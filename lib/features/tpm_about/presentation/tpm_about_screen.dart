import 'package:flutter/cupertino.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/jogja_page_header.dart';

class TpmAboutScreen extends StatelessWidget {
  const TpmAboutScreen({super.key});

  static const _bgTop = Color(0xFF181821);
  static const _bgMid = Color(0xFF0F0F16);
  static const _bgBottom = Color(0xFF06070B);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _bgBottom,
      child: DecoratedBox(
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
          child: ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 126),
            children: const [
              JogjaPageHeader(title: 'Saran & Kesan TPM', subtitle: 'Cerita kelompok selama membangun JogjaSplorasi.'),
              SizedBox(height: 18),
              _CourseCard(),
              SizedBox(height: 18),
              _MemberReflectionCard(
                name: 'Anak Agung Ngurah Dharma Yudha',
                nim: '123230080',
                impression:
                    'Selama mengikuti mata kuliah Teknologi dan Pemrograman Mobile, saya mendapatkan banyak pengalaman dalam memahami proses pengembangan aplikasi mobile mulai dari perancangan antarmuka, pengelolaan data lokal, integrasi API, pemanfaatan sensor, hingga penerapan fitur modern seperti autentikasi biometrik dan AI. Mata kuliah ini membantu saya memahami bahwa aplikasi mobile tidak hanya harus berjalan, tetapi juga harus nyaman digunakan, stabil, dan memiliki alur fitur yang jelas.',
                suggestion:
                    'Semoga ke depannya mata kuliah Teknologi dan Pemrograman Mobile dapat terus memberikan studi kasus yang dekat dengan kebutuhan dunia nyata, serta memberikan lebih banyak sesi praktik langsung agar mahasiswa semakin terbiasa membangun aplikasi mobile yang siap digunakan.',
              ),
              SizedBox(height: 14),
              _MemberReflectionCard(
                name: 'Muhammad Bintang Alkautsar',
                nim: '123230137',
                impression:
                    'Mata kuliah Teknologi dan Pemrograman Mobile memberikan pengalaman yang sangat bermanfaat karena saya dapat mempraktikkan langsung konsep-konsep mobile development dalam sebuah projek nyata. Melalui projek JogjaSplorasi, saya belajar menggabungkan berbagai fitur seperti login lokal, database, LBS, notifikasi, sensor, konversi waktu dan mata uang, mini game, serta AI ke dalam satu aplikasi yang utuh.',
                suggestion:
                    'Saya berharap pembelajaran TPM ke depannya dapat terus dikembangkan dengan contoh implementasi fitur yang lebih variatif, terutama pada integrasi API, deployment, dan debugging aplikasi mobile agar mahasiswa lebih siap menghadapi kebutuhan pengembangan aplikasi sebenarnya.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Saran & Kesan TPM',
      style: AppTypography.displayBold34.copyWith(
        color: AppColors.textPrimary,
        fontSize: 31,
        letterSpacing: -1.05,
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 34,
      opacity: 0.078,
      borderRadius: 30,
      borderColor: CupertinoColors.white.withValues(alpha: 0.12),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Pill(label: 'Projek Akhir'),
          const SizedBox(height: 14),
          Text(
            'Teknologi dan Pemrograman Mobile',
            style: AppTypography.displaySemi22.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: -0.55,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Halaman ini berisi kesan dan saran anggota kelompok selama mengikuti mata kuliah TPM.',
            style: AppTypography.textRegular13.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CupertinoColors.white.withValues(alpha: 0.055),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: CupertinoColors.white.withValues(alpha: 0.09),
              ),
            ),
            child: Text(
              'JogjaSplorasi',
              style: AppTypography.displaySemi20.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberReflectionCard extends StatelessWidget {
  const _MemberReflectionCard({
    required this.name,
    required this.nim,
    required this.impression,
    required this.suggestion,
  });

  final String name;
  final String nim;
  final String impression;
  final String suggestion;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 32,
      opacity: 0.072,
      borderRadius: 28,
      borderColor: CupertinoColors.white.withValues(alpha: 0.11),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(name: name),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textMedium15.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      nim,
                      style: AppTypography.captionSmall11.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _TextBlock(
            title: 'Kesan',
            icon: CupertinoIcons.heart_fill,
            text: impression,
            color: AppColors.accentPrimary,
          ),
          const SizedBox(height: 14),
          _TextBlock(
            title: 'Saran',
            icon: CupertinoIcons.lightbulb_fill,
            text: suggestion,
            color: AppColors.accentTertiary,
          ),
        ],
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  const _TextBlock({
    required this.title,
    required this.icon,
    required this.text,
    required this.color,
  });

  final String title;
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
      decoration: BoxDecoration(
        color: CupertinoColors.white.withValues(alpha: 0.048),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.085),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 7),
              Text(
                title,
                style: AppTypography.labelMedium12.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            text,
            textAlign: TextAlign.left,
            style: AppTypography.textRegular13.copyWith(
              color: AppColors.textSecondary,
              height: 1.52,
              letterSpacing: -0.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : name.substring(0, 1).toUpperCase();

    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1,
          colors: [
            AppColors.accentSecondary.withValues(alpha: 0.34),
            AppColors.accentPrimary.withValues(alpha: 0.22),
            CupertinoColors.white.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.13),
        ),
      ),
      child: Text(
        initials,
        style: AppTypography.textMedium15.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.accentSecondary.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.accentSecondary.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        label,
        style: AppTypography.captionSmall11.copyWith(
          color: AppColors.textPrimary.withValues(alpha: 0.88),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}