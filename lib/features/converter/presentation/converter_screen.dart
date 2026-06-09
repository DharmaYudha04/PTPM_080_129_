import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../data/currency_remote_datasource.dart';
import 'widgets/currency_converter_view.dart';
import 'widgets/time_converter_view.dart';
import '../../../shared/widgets/jogja_page_header.dart';

final currencyRefreshTickProvider = StateProvider<int>((ref) => 0);

final currencyRatesProvider = FutureProvider.autoDispose<CurrencyRatesResult>((
  ref,
) {
  final tick = ref.watch(currencyRefreshTickProvider);
  return CurrencyRemoteDataSource(
    dio: getIt(),
    prefs: getIt(),
  ).fetchRates(forceRefresh: tick > 0);
});

class ConverterScreen extends ConsumerStatefulWidget {
  const ConverterScreen({super.key, this.initialMode = 'currency'});

  final String initialMode;

  @override
  ConsumerState<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends ConsumerState<ConverterScreen> {
  late String mode;

  @override
  void initState() {
    super.initState();
    mode = widget.initialMode == 'time' ? 'time' : 'currency';
  }

  static const _bgTop = Color(0xFF181821);
  static const _bgMid = Color(0xFF0F0F16);
  static const _bgBottom = Color(0xFF06070B);

  @override
  Widget build(BuildContext context) {
    final rates = ref.watch(currencyRatesProvider);

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
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 22),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 126),
              children: [
                const JogjaPageHeader(
                    title: 'Konverter Wisata',
                    subtitle: 'Cek kurs dan waktu sebelum jalan-jalan.'),
                const SizedBox(height: 18),
                _ModeSwitch(
                  mode: mode,
                  onChanged: (value) => setState(() => mode = value),
                ),
                const SizedBox(height: 18),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: mode == 'currency'
                      ? rates.when(
                          data: (value) => CurrencyConverterView(
                            key: const ValueKey('currency'),
                            rates: value.rates,
                            updatedAt: value.updatedAt,
                            nextUpdateAt: value.nextUpdateAt,
                            sourceName: value.sourceName,
                            fromFallback: value.fromFallback,
                            fromCache: value.fromCache,
                            onRefresh: () => ref
                                .read(currencyRefreshTickProvider.notifier)
                                .state++,
                          ),
                          loading: () => const LoadingSkeleton(height: 260),
                          error: (_, __) => const _ErrorCard(),
                        )
                      : const TimeConverterView(
                          key: ValueKey('time'),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: unused_element
class _ConverterHeader extends StatelessWidget {
  const _ConverterHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentTertiary.withOpacity(0.14),
            border: Border.all(
              color: CupertinoColors.white.withOpacity(0.10),
            ),
          ),
          child: const Icon(
            CupertinoIcons.arrow_2_circlepath,
            size: 20,
            color: AppColors.accentTertiary,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Converter',
                style: AppTypography.displayBold34.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 31,
                  letterSpacing: -0.9,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Currency & time utility for your Jogja trip.',
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

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({
    required this.mode,
    required this.onChanged,
  });

  final String mode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isCurrency = mode == 'currency';

    return Container(
      height: 48,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: CupertinoColors.white.withOpacity(0.065),
        border: Border.all(
          color: CupertinoColors.white.withOpacity(0.10),
          width: 0.8,
        ),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            alignment:
                isCurrency ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: CupertinoColors.white.withOpacity(0.16),
                  border: Border.all(
                    color: CupertinoColors.white.withOpacity(0.08),
                    width: 0.8,
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _ModeItem(
                  label: 'Kurs',
                  icon: CupertinoIcons.money_dollar_circle,
                  selected: isCurrency,
                  onTap: () => onChanged('currency'),
                ),
              ),
              Expanded(
                child: _ModeItem(
                  label: 'Waktu',
                  icon: CupertinoIcons.clock,
                  selected: !isCurrency,
                  onTap: () => onChanged('time'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeItem extends StatelessWidget {
  const _ModeItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onTap,
      child: SizedBox.expand(
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color:
                    selected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.textRegular13.copyWith(
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.1,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 30,
      opacity: 0.075,
      borderRadius: 24,
      borderColor: CupertinoColors.white.withOpacity(0.11),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 20,
            color: AppColors.accentPrimary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Currency data belum bisa dimuat. Coba cek koneksi internet.',
              style: AppTypography.textRegular13.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
