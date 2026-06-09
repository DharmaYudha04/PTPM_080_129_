import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/glass_card.dart';

class CurrencyConverterView extends ConsumerStatefulWidget {
  const CurrencyConverterView({
    required this.rates,
    required this.updatedAt,
    required this.nextUpdateAt,
    required this.sourceName,
    required this.fromFallback,
    required this.fromCache,
    required this.onRefresh,
    super.key,
  });

  final Map<String, double> rates;
  final DateTime? updatedAt;
  final DateTime? nextUpdateAt;
  final String sourceName;
  final bool fromFallback;
  final bool fromCache;
  final VoidCallback onRefresh;

  @override
  ConsumerState<CurrencyConverterView> createState() =>
      _CurrencyConverterViewState();
}

class _CurrencyConverterViewState extends ConsumerState<CurrencyConverterView> {
  final _controller = TextEditingController(text: '1');

  String from = 'USD';
  String to = 'IDR';

  List<String> get _currencies {
    final codes = widget.rates.keys.where((code) => code.length == 3).toList()
      ..sort();
    return codes.isEmpty ? const ['USD', 'IDR'] : codes;
  }

  @override
  void didUpdateWidget(covariant CurrencyConverterView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final codes = _currencies;
    if (!codes.contains(from)) from = codes.first;
    if (!codes.contains(to)) to = codes.contains('IDR') ? 'IDR' : codes.last;
    if (from == to && codes.length > 1) to = codes.firstWhere((c) => c != from);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _swap() {
    HapticFeedback.selectionClick();
    setState(() {
      final previous = from;
      from = to;
      to = previous;
    });
  }

  Future<void> _selectCurrency({required bool isFrom}) async {
    HapticFeedback.selectionClick();
    final selected = await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) => _CurrencyPickerSheet(
        currencies: _currencies,
        selected: isFrom ? from : to,
        title: isFrom ? 'Pilih mata uang asal' : 'Pilih mata uang tujuan',
      ),
    );

    if (selected == null || !mounted) return;
    setState(() {
      if (isFrom) {
        from = selected;
        if (from == to && _currencies.length > 1) {
          to = _currencies.firstWhere((code) => code != from);
        }
      } else {
        to = selected;
        if (to == from && _currencies.length > 1) {
          from = _currencies.firstWhere((code) => code != to);
        }
      }
    });
  }

  double get _input {
    return double.tryParse(_controller.text.replaceAll(',', '.')) ?? 0;
  }

  double get _result {
    final fromRate = widget.rates[from] ?? 1;
    final toRate = widget.rates[to] ?? 1;
    if (fromRate == 0) return 0;
    return _input / fromRate * toRate;
  }

  String _symbol(String code) => _currencyMeta[code]?.symbol ?? code;

  String _name(String code) => _currencyMeta[code]?.name ?? code;

  String _updateLabel(String rateText) {
    final updated = widget.updatedAt == null
        ? 'belum diketahui'
        : _formatDateTime(widget.updatedAt!);
    final next = widget.nextUpdateAt == null
        ? null
        : _formatDateTime(widget.nextUpdateAt!);
    final source = widget.fromFallback
        ? 'mode offline'
        : widget.fromCache
            ? '${widget.sourceName} - cache terbaru'
            : '${widget.sourceName} - online';
    return [
      rateText,
      'Diperbarui $updated - $source',
      if (next != null) 'Update provider berikutnya $next',
    ].join('\n');
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }

  String _format(double value) {
    if (value >= 1000000) return value.toStringAsFixed(0);
    if (value >= 1000) return value.toStringAsFixed(2);
    if (value >= 1) return value.toStringAsFixed(2);
    return value.toStringAsFixed(4);
  }

  @override
  Widget build(BuildContext context) {
    final rateText =
        '1 $from kira-kira ${_format((widget.rates[to] ?? 1) / (widget.rates[from] ?? 1))} $to - ${_currencies.length} mata uang tersedia';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
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
                  AppColors.accentPrimary.withOpacity(0.13),
                  CupertinoColors.white.withOpacity(0.038),
                  CupertinoColors.black.withOpacity(0.02),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Konversi Kurs',
                  style: AppTypography.displaySemi22.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: -0.55,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hitung kurs dari data terbaru. Kamu juga bisa refresh sebelum menghitung biaya perjalanan.',
                  style: AppTypography.textRegular13.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 20),
                _AmountInput(
                  controller: _controller,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                _ResultPanel(
                  symbol: _symbol(to),
                  code: to,
                  result: _format(_result),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _CurrencyTile(
                        code: from,
                        symbol: _symbol(from),
                        name: _name(from),
                        onTap: () => _selectCurrency(isFrom: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _SwapButton(onTap: _swap),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _CurrencyTile(
                        code: to,
                        symbol: _symbol(to),
                        name: _name(to),
                        onTap: () => _selectCurrency(isFrom: false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final refreshButton = _RefreshRatesButton(
              onRefresh: widget.onRefresh,
            );

            if (constraints.maxWidth < 360) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _RateHint(text: _updateLabel(rateText)),
                  const SizedBox(height: 10),
                  Align(alignment: Alignment.centerLeft, child: refreshButton),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: _RateHint(
                    text: _updateLabel(rateText),
                  ),
                ),
                const SizedBox(width: 10),
                refreshButton,
              ],
            );
          },
        ),
      ],
    );
  }
}

class _RefreshRatesButton extends StatelessWidget {
  const _RefreshRatesButton({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 0,
      onPressed: onRefresh,
      child: GlassCard(
        blur: 20,
        opacity: 0.07,
        borderRadius: 18,
        borderColor: CupertinoColors.white.withOpacity(0.10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          'Refresh',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.captionSmall11.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _AmountInput extends StatelessWidget {
  const _AmountInput({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: CupertinoColors.white.withOpacity(0.055),
        border: Border.all(
          color: CupertinoColors.white.withOpacity(0.08),
          width: 0.8,
        ),
      ),
      child: CupertinoTextField.borderless(
        controller: controller,
        onChanged: onChanged,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
        placeholder: 'Jumlah',
        placeholderStyle: AppTypography.textRegular13.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w400,
        ),
        style: AppTypography.displayBold34.copyWith(
          color: AppColors.textPrimary,
          fontSize: 30,
          letterSpacing: -0.9,
        ),
        cursorColor: AppColors.textPrimary,
      ),
    );
  }
}

class _CurrencyTile extends StatefulWidget {
  const _CurrencyTile({
    required this.code,
    required this.symbol,
    required this.name,
    required this.onTap,
  });

  final String code;
  final String symbol;
  final String name;
  final VoidCallback onTap;

  @override
  State<_CurrencyTile> createState() => _CurrencyTileState();
}

class _CurrencyTileState extends State<_CurrencyTile> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) {
        _setPressed(false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          height: 70,
          padding: const EdgeInsets.fromLTRB(11, 11, 11, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: CupertinoColors.white.withOpacity(0.052),
            border: Border.all(
              color: CupertinoColors.white.withOpacity(0.075),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentTertiary.withOpacity(0.14),
                ),
                child: Text(
                  widget.symbol,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textMedium15.copyWith(
                    color: AppColors.accentTertiary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.code,
                            style: AppTypography.textMedium15.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w400,
                              letterSpacing: -0.15,
                            ),
                          ),
                        ),
                        const Icon(
                          CupertinoIcons.chevron_down,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.captionSmall11.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
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

class _CurrencyPickerSheet extends StatefulWidget {
  const _CurrencyPickerSheet({
    required this.currencies,
    required this.selected,
    required this.title,
  });

  final List<String> currencies;
  final String selected;
  final String title;

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = widget.currencies.where((code) {
      final meta = _currencyMeta[code];
      return code.toLowerCase().contains(query) ||
          (meta?.name.toLowerCase().contains(query) ?? false);
    }).toList();

    return CupertinoPopupSurface(
      isSurfacePainted: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.72,
        decoration: const BoxDecoration(
          color: Color(0xFF12121A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 10, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: AppTypography.displaySemi20.copyWith(
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Tutup'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: CupertinoSearchTextField(
                  controller: _searchController,
                  placeholder: 'Cari negara, nama mata uang, atau kode',
                  style: AppTypography.textRegular13.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => Container(
                    height: 1,
                    margin: const EdgeInsets.only(left: 68),
                    color: CupertinoColors.white.withOpacity(0.06),
                  ),
                  itemBuilder: (context, index) {
                    final code = filtered[index];
                    final meta = _currencyMeta[code];
                    final selected = code == widget.selected;
                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(code),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    AppColors.accentTertiary.withOpacity(0.14),
                              ),
                              child: Text(
                                meta?.symbol ?? code,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.textMedium15.copyWith(
                                  color: AppColors.accentTertiary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    code,
                                    style: AppTypography.textMedium15.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    meta?.name ?? 'Currency code $code',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        AppTypography.captionSmall11.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (selected)
                              const Icon(
                                CupertinoIcons.check_mark_circled_solid,
                                color: AppColors.accentPrimary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwapButton extends StatefulWidget {
  const _SwapButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_SwapButton> createState() => _SwapButtonState();
}

class _SwapButtonState extends State<_SwapButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) {
        _setPressed(false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: GlassCard(
          width: 46,
          height: 46,
          blur: 24,
          opacity: 0.095,
          borderRadius: 999,
          borderColor: CupertinoColors.white.withOpacity(0.10),
          padding: EdgeInsets.zero,
          child: const Center(
            child: Icon(
              CupertinoIcons.arrow_2_squarepath,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel(
      {required this.symbol, required this.code, required this.result});

  final String symbol;
  final String code;
  final String result;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 30,
      opacity: 0.085,
      borderRadius: 28,
      borderColor: CupertinoColors.white.withOpacity(0.11),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Converted',
            style: AppTypography.captionSmall11.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$symbol $result',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.displayBold34.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 31,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                code,
                style: AppTypography.textMedium15.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RateHint extends StatelessWidget {
  const _RateHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 26,
      opacity: 0.066,
      borderRadius: 20,
      borderColor: CupertinoColors.white.withOpacity(0.09),
      padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.chart_bar_alt_fill,
            size: 15,
            color: AppColors.accentTertiary,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: AppTypography.captionSmall11.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyMeta {
  const _CurrencyMeta(this.name, this.symbol);
  final String name;
  final String symbol;
}

const _currencyMeta = <String, _CurrencyMeta>{
  'AED': _CurrencyMeta('United Arab Emirates Dirham', 'د.إ'),
  'AFN': _CurrencyMeta('Afghan Afghani', '؋'),
  'ALL': _CurrencyMeta('Albanian Lek', 'L'),
  'AMD': _CurrencyMeta('Armenian Dram', '֏'),
  'ANG': _CurrencyMeta('Netherlands Antillean Guilder', 'ƒ'),
  'AOA': _CurrencyMeta('Angolan Kwanza', 'Kz'),
  'ARS': _CurrencyMeta('Argentine Peso', r'$'),
  'AUD': _CurrencyMeta('Australian Dollar', r'$'),
  'AWG': _CurrencyMeta('Aruban Florin', 'ƒ'),
  'AZN': _CurrencyMeta('Azerbaijani Manat', '₼'),
  'BAM': _CurrencyMeta('Bosnia-Herzegovina Convertible Mark', 'KM'),
  'BBD': _CurrencyMeta('Barbadian Dollar', r'$'),
  'BDT': _CurrencyMeta('Bangladeshi Taka', '৳'),
  'BGN': _CurrencyMeta('Bulgarian Lev', 'лв'),
  'BHD': _CurrencyMeta('Bahraini Dinar', '.د.ب'),
  'BIF': _CurrencyMeta('Burundian Franc', 'FBu'),
  'BMD': _CurrencyMeta('Bermudian Dollar', r'$'),
  'BND': _CurrencyMeta('Brunei Dollar', r'$'),
  'BOB': _CurrencyMeta('Bolivian Boliviano', 'Bs'),
  'BRL': _CurrencyMeta('Brazilian Real', r'R$'),
  'BSD': _CurrencyMeta('Bahamian Dollar', r'$'),
  'BTN': _CurrencyMeta('Bhutanese Ngultrum', 'Nu.'),
  'BWP': _CurrencyMeta('Botswana Pula', 'P'),
  'BYN': _CurrencyMeta('Belarusian Ruble', 'Br'),
  'BZD': _CurrencyMeta('Belize Dollar', r'$'),
  'CAD': _CurrencyMeta('Canadian Dollar', r'$'),
  'CDF': _CurrencyMeta('Congolese Franc', 'FC'),
  'CHF': _CurrencyMeta('Swiss Franc', 'CHF'),
  'CLP': _CurrencyMeta('Chilean Peso', r'$'),
  'CNY': _CurrencyMeta('Chinese Yuan', '¥'),
  'COP': _CurrencyMeta('Colombian Peso', r'$'),
  'CRC': _CurrencyMeta('Costa Rican Colón', '₡'),
  'CUP': _CurrencyMeta('Cuban Peso', r'$'),
  'CVE': _CurrencyMeta('Cape Verdean Escudo', r'$'),
  'CZK': _CurrencyMeta('Czech Koruna', 'Kč'),
  'DJF': _CurrencyMeta('Djiboutian Franc', 'Fdj'),
  'DKK': _CurrencyMeta('Danish Krone', 'kr'),
  'DOP': _CurrencyMeta('Dominican Peso', r'$'),
  'DZD': _CurrencyMeta('Algerian Dinar', 'دج'),
  'EGP': _CurrencyMeta('Egyptian Pound', '£'),
  'ERN': _CurrencyMeta('Eritrean Nakfa', 'Nfk'),
  'ETB': _CurrencyMeta('Ethiopian Birr', 'Br'),
  'EUR': _CurrencyMeta('Euro', '€'),
  'FJD': _CurrencyMeta('Fijian Dollar', r'$'),
  'FKP': _CurrencyMeta('Falkland Islands Pound', '£'),
  'FOK': _CurrencyMeta('Faroese Króna', 'kr'),
  'GBP': _CurrencyMeta('British Pound Sterling', '£'),
  'GEL': _CurrencyMeta('Georgian Lari', '₾'),
  'GGP': _CurrencyMeta('Guernsey Pound', '£'),
  'GHS': _CurrencyMeta('Ghanaian Cedi', '₵'),
  'GIP': _CurrencyMeta('Gibraltar Pound', '£'),
  'GMD': _CurrencyMeta('Gambian Dalasi', 'D'),
  'GNF': _CurrencyMeta('Guinean Franc', 'FG'),
  'GTQ': _CurrencyMeta('Guatemalan Quetzal', 'Q'),
  'GYD': _CurrencyMeta('Guyanese Dollar', r'$'),
  'HKD': _CurrencyMeta('Hong Kong Dollar', r'$'),
  'HNL': _CurrencyMeta('Honduran Lempira', 'L'),
  'HRK': _CurrencyMeta('Croatian Kuna', 'kn'),
  'HTG': _CurrencyMeta('Haitian Gourde', 'G'),
  'HUF': _CurrencyMeta('Hungarian Forint', 'Ft'),
  'IDR': _CurrencyMeta('Indonesian Rupiah', 'Rp'),
  'ILS': _CurrencyMeta('Israeli New Shekel', '₪'),
  'IMP': _CurrencyMeta('Manx Pound', '£'),
  'INR': _CurrencyMeta('Indian Rupee', '₹'),
  'IQD': _CurrencyMeta('Iraqi Dinar', 'ع.د'),
  'IRR': _CurrencyMeta('Iranian Rial', '﷼'),
  'ISK': _CurrencyMeta('Icelandic Króna', 'kr'),
  'JEP': _CurrencyMeta('Jersey Pound', '£'),
  'JMD': _CurrencyMeta('Jamaican Dollar', r'$'),
  'JOD': _CurrencyMeta('Jordanian Dinar', 'د.ا'),
  'JPY': _CurrencyMeta('Japanese Yen', '¥'),
  'KES': _CurrencyMeta('Kenyan Shilling', 'KSh'),
  'KGS': _CurrencyMeta('Kyrgyzstani Som', 'с'),
  'KHR': _CurrencyMeta('Cambodian Riel', '៛'),
  'KID': _CurrencyMeta('Kiribati Dollar', r'$'),
  'KMF': _CurrencyMeta('Comorian Franc', 'CF'),
  'KRW': _CurrencyMeta('South Korean Won', '₩'),
  'KWD': _CurrencyMeta('Kuwaiti Dinar', 'د.ك'),
  'KYD': _CurrencyMeta('Cayman Islands Dollar', r'$'),
  'KZT': _CurrencyMeta('Kazakhstani Tenge', '₸'),
  'LAK': _CurrencyMeta('Lao Kip', '₭'),
  'LBP': _CurrencyMeta('Lebanese Pound', 'ل.ل'),
  'LKR': _CurrencyMeta('Sri Lankan Rupee', 'Rs'),
  'LRD': _CurrencyMeta('Liberian Dollar', r'$'),
  'LSL': _CurrencyMeta('Lesotho Loti', 'L'),
  'LYD': _CurrencyMeta('Libyan Dinar', 'ل.د'),
  'MAD': _CurrencyMeta('Moroccan Dirham', 'د.م.'),
  'MDL': _CurrencyMeta('Moldovan Leu', 'L'),
  'MGA': _CurrencyMeta('Malagasy Ariary', 'Ar'),
  'MKD': _CurrencyMeta('Macedonian Denar', 'ден'),
  'MMK': _CurrencyMeta('Myanmar Kyat', 'K'),
  'MNT': _CurrencyMeta('Mongolian Tögrög', '₮'),
  'MOP': _CurrencyMeta('Macanese Pataca', 'P'),
  'MRU': _CurrencyMeta('Mauritanian Ouguiya', 'UM'),
  'MUR': _CurrencyMeta('Mauritian Rupee', '₨'),
  'MVR': _CurrencyMeta('Maldivian Rufiyaa', 'Rf'),
  'MWK': _CurrencyMeta('Malawian Kwacha', 'MK'),
  'MXN': _CurrencyMeta('Mexican Peso', r'$'),
  'MYR': _CurrencyMeta('Malaysian Ringgit', 'RM'),
  'MZN': _CurrencyMeta('Mozambican Metical', 'MT'),
  'NAD': _CurrencyMeta('Namibian Dollar', r'$'),
  'NGN': _CurrencyMeta('Nigerian Naira', '₦'),
  'NIO': _CurrencyMeta('Nicaraguan Córdoba', r'C$'),
  'NOK': _CurrencyMeta('Norwegian Krone', 'kr'),
  'NPR': _CurrencyMeta('Nepalese Rupee', '₨'),
  'NZD': _CurrencyMeta('New Zealand Dollar', r'$'),
  'OMR': _CurrencyMeta('Omani Rial', 'ر.ع.'),
  'PAB': _CurrencyMeta('Panamanian Balboa', 'B/.'),
  'PEN': _CurrencyMeta('Peruvian Sol', 'S/'),
  'PGK': _CurrencyMeta('Papua New Guinean Kina', 'K'),
  'PHP': _CurrencyMeta('Philippine Peso', '₱'),
  'PKR': _CurrencyMeta('Pakistani Rupee', '₨'),
  'PLN': _CurrencyMeta('Polish Złoty', 'zł'),
  'PYG': _CurrencyMeta('Paraguayan Guaraní', '₲'),
  'QAR': _CurrencyMeta('Qatari Riyal', 'ر.ق'),
  'RON': _CurrencyMeta('Romanian Leu', 'lei'),
  'RSD': _CurrencyMeta('Serbian Dinar', 'дин'),
  'RUB': _CurrencyMeta('Russian Ruble', '₽'),
  'RWF': _CurrencyMeta('Rwandan Franc', 'FRw'),
  'SAR': _CurrencyMeta('Saudi Riyal', '﷼'),
  'SBD': _CurrencyMeta('Solomon Islands Dollar', r'$'),
  'SCR': _CurrencyMeta('Seychellois Rupee', '₨'),
  'SDG': _CurrencyMeta('Sudanese Pound', 'ج.س.'),
  'SEK': _CurrencyMeta('Swedish Krona', 'kr'),
  'SGD': _CurrencyMeta('Singapore Dollar', r'$'),
  'SHP': _CurrencyMeta('Saint Helena Pound', '£'),
  'SLE': _CurrencyMeta('Sierra Leonean Leone', 'Le'),
  'SOS': _CurrencyMeta('Somali Shilling', 'Sh'),
  'SRD': _CurrencyMeta('Surinamese Dollar', r'$'),
  'SSP': _CurrencyMeta('South Sudanese Pound', '£'),
  'STN': _CurrencyMeta('São Tomé and Príncipe Dobra', 'Db'),
  'SYP': _CurrencyMeta('Syrian Pound', '£'),
  'SZL': _CurrencyMeta('Eswatini Lilangeni', 'L'),
  'THB': _CurrencyMeta('Thai Baht', '฿'),
  'TJS': _CurrencyMeta('Tajikistani Somoni', 'ЅМ'),
  'TMT': _CurrencyMeta('Turkmenistani Manat', 'm'),
  'TND': _CurrencyMeta('Tunisian Dinar', 'د.ت'),
  'TOP': _CurrencyMeta('Tongan Paʻanga', r'T$'),
  'TRY': _CurrencyMeta('Turkish Lira', '₺'),
  'TTD': _CurrencyMeta('Trinidad and Tobago Dollar', r'$'),
  'TVD': _CurrencyMeta('Tuvaluan Dollar', r'$'),
  'TWD': _CurrencyMeta('New Taiwan Dollar', r'NT$'),
  'TZS': _CurrencyMeta('Tanzanian Shilling', 'TSh'),
  'UAH': _CurrencyMeta('Ukrainian Hryvnia', '₴'),
  'UGX': _CurrencyMeta('Ugandan Shilling', 'USh'),
  'USD': _CurrencyMeta('US Dollar', r'$'),
  'UYU': _CurrencyMeta('Uruguayan Peso', r'$'),
  'UZS': _CurrencyMeta('Uzbekistani Soʻm', 'сўм'),
  'VES': _CurrencyMeta('Venezuelan Bolívar', 'Bs.'),
  'VND': _CurrencyMeta('Vietnamese Đồng', '₫'),
  'VUV': _CurrencyMeta('Vanuatu Vatu', 'VT'),
  'WST': _CurrencyMeta('Samoan Tālā', 'T'),
  'XAF': _CurrencyMeta('Central African CFA Franc', 'FCFA'),
  'XCD': _CurrencyMeta('East Caribbean Dollar', r'$'),
  'XOF': _CurrencyMeta('West African CFA Franc', 'CFA'),
  'XPF': _CurrencyMeta('CFP Franc', '₣'),
  'YER': _CurrencyMeta('Yemeni Rial', '﷼'),
  'ZAR': _CurrencyMeta('South African Rand', 'R'),
  'ZMW': _CurrencyMeta('Zambian Kwacha', 'ZK'),
  'ZWL': _CurrencyMeta('Zimbabwean Dollar', r'$'),
};
