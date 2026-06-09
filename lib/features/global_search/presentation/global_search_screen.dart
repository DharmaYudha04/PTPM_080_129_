import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/destination_display_util.dart';
import '../../../shared/models/destination.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/jogja_page_header.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  String _query = '';

  static const _bgTop = Color(0xFF2A1A0B);
  static const _bgMid = Color(0xFF17100B);
  static const _bgBottom = Color(0xFF080604);

  List<_SearchAction> get _actions => [
        _SearchAction('Kanca Jogja', 'Tanya pemandu Jogja untuk rekomendasi tempat.', CupertinoIcons.sparkles, RouteNames.guide, ['ai', 'chat', 'pemandu', 'rekomendasi', 'kuliner']),
        _SearchAction('Mini Game Budaya', 'Main kuis sejarah dan budaya Yogyakarta.', CupertinoIcons.gamecontroller_fill, RouteNames.game, ['quiz', 'kuis', 'game', 'budaya', 'sejarah']),
        _SearchAction('Konversi Kurs', 'Hitung mata uang untuk biaya perjalanan.', CupertinoIcons.money_dollar_circle, '${RouteNames.converter}?tab=currency', ['kurs', 'mata uang', 'currency', 'uang']),
        _SearchAction('Konversi Waktu', 'Cek zona waktu Indonesia dan dunia.', CupertinoIcons.clock, '${RouteNames.converter}?tab=time', ['waktu', 'zona waktu', 'london', 'wib', 'wita', 'wit']),
        _SearchAction('Sensor Jelajah', 'Shake to Discover dan tilt card destinasi.', CupertinoIcons.waveform_path_ecg, RouteNames.sensor, ['sensor', 'shake', 'gyroscope', 'accelerometer']),
        _SearchAction('Profil', 'Edit profil, favorit, dan kunci aplikasi.', CupertinoIcons.person_crop_circle, RouteNames.profile, ['profil', 'tema', 'dark', 'light', 'biometrik']),
        _SearchAction('Saran & Kesan TPM', 'Kirim saran dan kesan mata kuliah TPM.', CupertinoIcons.doc_text_fill, RouteNames.feedback, ['saran', 'kesan', 'tpm', 'feedback']),
      ];

  @override
  Widget build(BuildContext context) {
    final destinations = Hive.box<DestinationModel>(AppConstants.destinationsBox)
        .values
        .toList();
    final query = _query.trim().toLowerCase();

    final destinationResults = query.isEmpty
        ? destinations.take(6).toList()
        : destinations.where((item) {
            final text = [
              item.name,
              item.category,
              item.type,
              item.description,
              item.story,
              item.localInsight,
              item.address,
              ...item.tags,
            ].join(' ').toLowerCase();
            return text.contains(query);
          }).take(10).toList();

    final actionResults = query.isEmpty
        ? _actions.take(4).toList()
        : _actions.where((item) => item.matches(query)).toList();

    return CupertinoPageScaffold(
      backgroundColor: _bgBottom,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.16,
            colors: [_bgTop, _bgMid, _bgBottom],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 42),
            physics: const BouncingScrollPhysics(),
            children: [
              const JogjaPageHeader(
                title: 'Mau cari apa?',
                subtitle: 'Temukan tempat wisata, fitur, atau bantuan yang kamu butuhkan.',
              ),
              const SizedBox(height: 18),
              _SearchBox(onChanged: (value) => setState(() => _query = value)),
              const SizedBox(height: 22),
              _SectionTitle(title: 'Aksi Cepat', subtitle: '${actionResults.length} fitur cocok'),
              const SizedBox(height: 10),
              ...actionResults.map((item) => _ActionResultTile(action: item)),
              const SizedBox(height: 22),
              _SectionTitle(
                title: query.isEmpty ? 'Rekomendasi Destinasi' : 'Destinasi Cocok',
                subtitle: '${destinationResults.length} hasil',
              ),
              const SizedBox(height: 10),
              if (destinationResults.isEmpty)
                const _EmptySearch()
              else
                ...destinationResults.map((item) => _DestinationResultTile(destination: item)),
              const SizedBox(height: 16),
              _AskAiCard(query: _query),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 32,
      opacity: 0.08,
      borderRadius: 22,
      borderColor: CupertinoColors.white.withOpacity(0.12),
      padding: EdgeInsets.zero,
      child: CupertinoTextField.borderless(
        autofocus: true,
        placeholder: 'Coba ketik candi, kuliner, kuis...',
        onChanged: onChanged,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        prefix: Padding(
          padding: const EdgeInsets.only(left: 14, right: 8),
          child: Icon(CupertinoIcons.search, size: 18, color: AppColors.textSecondary),
        ),
        placeholderStyle: AppTypography.textRegular13.copyWith(color: AppColors.textSecondary),
        style: AppTypography.textRegular13.copyWith(color: AppColors.textPrimary, fontSize: 15),
        cursorColor: AppColors.accentPrimary,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTypography.displaySemi20.copyWith(color: AppColors.textPrimary))),
        Text(subtitle, style: AppTypography.captionSmall11.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}

class _ActionResultTile extends StatelessWidget {
  const _ActionResultTile({required this.action});
  final _SearchAction action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          if (action.route == RouteNames.home ||
              action.route == RouteNames.explore ||
              action.route == RouteNames.guide ||
              action.route == RouteNames.profile) {
            context.go(action.route);
          } else {
            context.push(action.route);
          }
        },
        child: GlassCard(
          blur: 28,
          opacity: 0.072,
          borderRadius: 22,
          borderColor: CupertinoColors.white.withOpacity(0.10),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(action.icon, color: AppColors.accentPrimary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(action.title, style: AppTypography.textMedium15.copyWith(color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(action.subtitle, style: AppTypography.captionSmall11.copyWith(color: AppColors.textSecondary, height: 1.3)),
                ]),
              ),
              Icon(CupertinoIcons.chevron_right, color: AppColors.textSecondary, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DestinationResultTile extends StatelessWidget {
  const _DestinationResultTile({required this.destination});
  final DestinationModel destination;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => context.push('${RouteNames.destination}/${destination.id}'),
        child: GlassCard(
          blur: 28,
          opacity: 0.066,
          borderRadius: 22,
          borderColor: CupertinoColors.white.withOpacity(0.10),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.accentPrimary.withOpacity(0.16),
                ),
                child: const Icon(CupertinoIcons.map_pin_ellipse, color: AppColors.accentPrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(destination.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.textMedium15.copyWith(color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('${DestinationDisplayUtil.categoryFor(destination)} • ${destination.address.isEmpty ? 'Jogja' : destination.address}', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.captionSmall11.copyWith(color: AppColors.textSecondary)),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AskAiCard extends StatelessWidget {
  const _AskAiCard({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    final prompt = query.trim().isEmpty ? 'Rekomendasikan tempat seru di Jogja hari ini' : 'Ceritakan rekomendasi Jogja tentang $query';
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => context.go('${RouteNames.guide}?prompt=${Uri.encodeComponent(prompt)}'),
      child: GlassCard(
        blur: 32,
        opacity: 0.09,
        borderRadius: 26,
        borderColor: AppColors.accentPrimary.withOpacity(0.2),
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          const Icon(CupertinoIcons.sparkles, color: AppColors.accentPrimary),
          const SizedBox(width: 12),
          Expanded(child: Text('Tanya Kanca Jogja tentang pencarian ini', style: AppTypography.textMedium15.copyWith(color: AppColors.textPrimary))),
          const Icon(CupertinoIcons.chevron_right, color: AppColors.textSecondary, size: 16),
        ]),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 24,
      opacity: 0.055,
      borderRadius: 22,
      borderColor: CupertinoColors.white.withOpacity(0.08),
      padding: const EdgeInsets.all(16),
      child: Text(
        'Belum ketemu. Coba kata lain seperti budaya, kuliner, candi, tema, atau langsung tanya Kanca Jogja.',
        style: AppTypography.textRegular13.copyWith(color: AppColors.textSecondary, height: 1.4),
      ),
    );
  }
}

class _SearchAction {
  const _SearchAction(this.title, this.subtitle, this.icon, this.route, this.keywords);
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final List<String> keywords;

  bool matches(String query) => [title, subtitle, ...keywords].join(' ').toLowerCase().contains(query);
}
