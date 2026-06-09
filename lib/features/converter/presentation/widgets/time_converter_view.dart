import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_util.dart';
import '../../../../shared/widgets/glass_card.dart';

class TimeConverterView extends StatefulWidget {
  const TimeConverterView({super.key});

  @override
  State<TimeConverterView> createState() => _TimeConverterViewState();
}

class _TimeConverterViewState extends State<TimeConverterView> {
  late Timer _timer;
  DateTime _baseLocalTime = DateTime.now();
  _WorldZone _fromZone = _defaultZones.first;
  _WorldZone _toZone = _defaultZones[3];

  @override
  void initState() {
    super.initState();
    tz_data.initializeTimeZones();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _isUsingNow) {
        setState(() => _baseLocalTime = DateTime.now());
      }
    });
  }

  bool get _isUsingNow =>
      DateTime.now().difference(_baseLocalTime).inSeconds.abs() < 90;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final picked = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (context) =>
          _DateTimePickerSheet(initialDateTime: _baseLocalTime),
    );
    if (picked == null || !mounted) return;
    setState(() => _baseLocalTime = picked);
  }

  Future<void> _pickZone({required bool isFrom}) async {
    final selected = await showCupertinoModalPopup<_WorldZone>(
      context: context,
      builder: (context) => _ZonePickerSheet(
        title: isFrom ? 'Pilih zona asal' : 'Pilih zona tujuan',
        selected: isFrom ? _fromZone : _toZone,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (isFrom) {
        _fromZone = selected;
      } else {
        _toZone = selected;
      }
    });
  }

  DateTime _timeInZone(_WorldZone zone) {
    final sourceLocation = tz.getLocation(_fromZone.tzId);
    final sourceTime = tz.TZDateTime(
      sourceLocation,
      _baseLocalTime.year,
      _baseLocalTime.month,
      _baseLocalTime.day,
      _baseLocalTime.hour,
      _baseLocalTime.minute,
      _baseLocalTime.second,
    );
    return tz.TZDateTime.from(sourceTime.toUtc(), tz.getLocation(zone.tzId));
  }

  String _offsetLabel(_WorldZone zone) {
    final time = _timeInZone(zone);
    final offset = time.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final totalMinutes = offset.inMinutes.abs();
    final hours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final minutes = (totalMinutes % 60).toString().padLeft(2, '0');
    return 'UTC$sign$hours:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    final converted = _timeInZone(_toZone);
    final requiredZones = _requiredZones.map((zone) {
      return _TimeZoneItem(
        code: zone.shortLabel,
        city: zone.city,
        offsetLabel: _offsetLabel(zone),
        time: _timeInZone(zone),
        color: zone.color,
      );
    }).toList();

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
                  AppColors.accentTertiary.withOpacity(0.13),
                  CupertinoColors.white.withOpacity(0.038),
                  CupertinoColors.black.withOpacity(0.02),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Konversi Waktu',
                  style: AppTypography.displaySemi22.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: -0.55,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pilih waktu, kota asal, lalu lihat hasilnya di zona tujuan.',
                  style: AppTypography.textRegular13.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Waktu yang ingin dikonversi',
                  style: AppTypography.textMedium15.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                _DateTimeButton(
                  label: _isUsingNow
                      ? 'Sekarang • ${DateUtil.hourMinute(_baseLocalTime)}'
                      : '${_baseLocalTime.day.toString().padLeft(2, '0')}/${_baseLocalTime.month.toString().padLeft(2, '0')}/${_baseLocalTime.year} • ${DateUtil.hourMinute(_baseLocalTime)}',
                  onPick: _pickDateTime,
                  onUseNow: () =>
                      setState(() => _baseLocalTime = DateTime.now()),
                ),
                const SizedBox(height: 14),
                _ZoneSelectRow(
                  label: 'Dari',
                  zone: _fromZone,
                  offset: _offsetLabel(_fromZone),
                  onTap: () => _pickZone(isFrom: true),
                ),
                const SizedBox(height: 10),
                _ZoneSelectRow(
                  label: 'Ke',
                  zone: _toZone,
                  offset: _offsetLabel(_toZone),
                  onTap: () => _pickZone(isFrom: false),
                ),
                const SizedBox(height: 16),
                _MainTimeCard(
                  title: '${_fromZone.city} → ${_toZone.city}',
                  subtitle:
                      '${_fromZone.country} ke ${_toZone.country} • ${_offsetLabel(_toZone)}',
                  time: converted,
                  color: AppColors.accentTertiary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Zona Waktu Indonesia',
          style: AppTypography.textMedium15.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requiredZones.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisExtent: 78,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) => _TimeRow(zone: requiredZones[index]),
        ),
      ],
    );
  }
}

class _ZoneSelectRow extends StatelessWidget {
  const _ZoneSelectRow({
    required this.label,
    required this.zone,
    required this.offset,
    required this.onTap,
  });

  final String label;
  final _WorldZone zone;
  final String offset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: CupertinoColors.white.withOpacity(0.055),
          border: Border.all(color: CupertinoColors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: zone.color.withOpacity(0.14),
              ),
              child: Text(
                zone.shortLabel.characters.first,
                style: AppTypography.textMedium15.copyWith(color: zone.color),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$label • $offset',
                    style: AppTypography.captionSmall11.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${zone.city}, ${zone.country}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.textMedium15.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_down,
                size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _DateTimeButton extends StatelessWidget {
  const _DateTimeButton(
      {required this.label, required this.onPick, required this.onUseNow});

  final String label;
  final VoidCallback onPick;
  final VoidCallback onUseNow;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onPick,
            child: GlassCard(
              blur: 22,
              opacity: 0.072,
              borderRadius: 20,
              borderColor: CupertinoColors.white.withOpacity(0.09),
              padding: const EdgeInsets.fromLTRB(15, 16, 15, 16),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.clock,
                      size: 18, color: AppColors.accentPrimary),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.captionSmall11.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onUseNow,
          child: GlassCard(
            blur: 22,
            opacity: 0.072,
            borderRadius: 20,
            borderColor: CupertinoColors.white.withOpacity(0.09),
            padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
            child: Text(
              'Sekarang',
              style: AppTypography.captionSmall11
                  .copyWith(color: AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}

class _DateTimePickerSheet extends StatefulWidget {
  const _DateTimePickerSheet({required this.initialDateTime});

  final DateTime initialDateTime;

  @override
  State<_DateTimePickerSheet> createState() => _DateTimePickerSheetState();
}

class _DateTimePickerSheetState extends State<_DateTimePickerSheet> {
  late DateTime value = widget.initialDateTime;

  @override
  Widget build(BuildContext context) {
    return CupertinoPopupSurface(
      isSurfacePainted: false,
      child: Container(
        height: 340,
        decoration: const BoxDecoration(
          color: Color(0xFF12121A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 10, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Pilih tanggal & jam',
                        style: AppTypography.displaySemi20
                            .copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(value),
                      child: const Text('Pakai'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: value,
                  use24hFormat: true,
                  onDateTimeChanged: (newValue) => value = newValue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZonePickerSheet extends StatefulWidget {
  const _ZonePickerSheet({required this.title, required this.selected});

  final String title;
  final _WorldZone selected;

  @override
  State<_ZonePickerSheet> createState() => _ZonePickerSheetState();
}

class _ZonePickerSheetState extends State<_ZonePickerSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final zones = _defaultZones.where((zone) {
      return zone.country.toLowerCase().contains(query) ||
          zone.city.toLowerCase().contains(query) ||
          zone.shortLabel.toLowerCase().contains(query) ||
          zone.tzId.toLowerCase().contains(query);
    }).toList();

    return CupertinoPopupSurface(
      isSurfacePainted: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.74,
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
                  placeholder: 'Cari negara, kota, WIB, WITA, WIT, London...',
                  style: AppTypography.textRegular13
                      .copyWith(color: AppColors.textPrimary),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: zones.length,
                  separatorBuilder: (_, __) => Container(
                    height: 1,
                    margin: const EdgeInsets.only(left: 68),
                    color: CupertinoColors.white.withOpacity(0.06),
                  ),
                  itemBuilder: (context, index) {
                    final zone = zones[index];
                    final selected = zone.tzId == widget.selected.tzId;
                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(zone),
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
                                color: zone.color.withOpacity(0.14),
                              ),
                              child: Text(
                                zone.shortLabel.characters.first,
                                style: AppTypography.textMedium15
                                    .copyWith(color: zone.color),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${zone.city}, ${zone.country}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.textMedium15
                                        .copyWith(color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${zone.shortLabel} • ${zone.tzId}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.captionSmall11
                                        .copyWith(
                                            color: AppColors.textSecondary),
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

class _MainTimeCard extends StatelessWidget {
  const _MainTimeCard({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  final String title;
  final String subtitle;
  final DateTime time;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: CupertinoColors.white.withOpacity(0.060),
        border: Border.all(
          color: CupertinoColors.white.withOpacity(0.085),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: color.withOpacity(0.14)),
            child: Icon(CupertinoIcons.clock_fill, size: 19, color: color),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textRegular13.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.displaySemi22.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Text(
            DateUtil.hourMinute(time),
            style: AppTypography.displayBold34.copyWith(
              color: AppColors.textPrimary,
              fontSize: 36,
              letterSpacing: -1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({required this.zone});

  final _TimeZoneItem zone;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 28,
      opacity: 0.070,
      borderRadius: 24,
      borderColor: CupertinoColors.white.withOpacity(0.10),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: zone.color.withOpacity(0.14)),
            child: Text(
              zone.code.characters.first,
              style: AppTypography.textMedium15.copyWith(
                color: zone.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone.code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.textMedium15.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${zone.city} • ${zone.offsetLabel}',
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
          Text(
            DateUtil.hourMinute(zone.time),
            style: AppTypography.displaySemi20.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: -0.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeZoneItem {
  const _TimeZoneItem({
    required this.code,
    required this.city,
    required this.offsetLabel,
    required this.time,
    required this.color,
  });

  final String code;
  final String city;
  final String offsetLabel;
  final DateTime time;
  final Color color;
}

class _WorldZone {
  const _WorldZone({
    required this.country,
    required this.city,
    required this.tzId,
    required this.shortLabel,
    required this.color,
  });

  final String country;
  final String city;
  final String tzId;
  final String shortLabel;
  final Color color;
}

const _requiredZones = [
  _WorldZone(
      country: 'Indonesia',
      city: 'Yogyakarta',
      tzId: 'Asia/Jakarta',
      shortLabel: 'WIB',
      color: AppColors.accentPrimary),
  _WorldZone(
      country: 'Indonesia',
      city: 'Makassar',
      tzId: 'Asia/Makassar',
      shortLabel: 'WITA',
      color: AppColors.accentTertiary),
  _WorldZone(
      country: 'Indonesia',
      city: 'Jayapura',
      tzId: 'Asia/Jayapura',
      shortLabel: 'WIT',
      color: AppColors.accentSecondary),
  _WorldZone(
      country: 'United Kingdom',
      city: 'London',
      tzId: 'Europe/London',
      shortLabel: 'London',
      color: AppColors.textSecondary),
];

const _defaultZones = <_WorldZone>[
  ..._requiredZones,
  _WorldZone(
      country: 'United States',
      city: 'New York',
      tzId: 'America/New_York',
      shortLabel: 'NYC',
      color: AppColors.accentPrimary),
  _WorldZone(
      country: 'United States',
      city: 'Los Angeles',
      tzId: 'America/Los_Angeles',
      shortLabel: 'LA',
      color: AppColors.accentSecondary),
  _WorldZone(
      country: 'United States',
      city: 'Chicago',
      tzId: 'America/Chicago',
      shortLabel: 'CHI',
      color: AppColors.accentTertiary),
  _WorldZone(
      country: 'Canada',
      city: 'Toronto',
      tzId: 'America/Toronto',
      shortLabel: 'Toronto',
      color: AppColors.accentPrimary),
  _WorldZone(
      country: 'Canada',
      city: 'Vancouver',
      tzId: 'America/Vancouver',
      shortLabel: 'Vancouver',
      color: AppColors.accentSecondary),
  _WorldZone(
      country: 'Mexico',
      city: 'Mexico City',
      tzId: 'America/Mexico_City',
      shortLabel: 'CDMX',
      color: AppColors.accentTertiary),
  _WorldZone(
      country: 'Brazil',
      city: 'São Paulo',
      tzId: 'America/Sao_Paulo',
      shortLabel: 'Sao Paulo',
      color: AppColors.accentPrimary),
  _WorldZone(
      country: 'Argentina',
      city: 'Buenos Aires',
      tzId: 'America/Argentina/Buenos_Aires',
      shortLabel: 'BA',
      color: AppColors.accentSecondary),
  _WorldZone(
      country: 'Chile',
      city: 'Santiago',
      tzId: 'America/Santiago',
      shortLabel: 'Santiago',
      color: AppColors.accentTertiary),
  _WorldZone(
      country: 'Colombia',
      city: 'Bogota',
      tzId: 'America/Bogota',
      shortLabel: 'Bogota',
      color: AppColors.accentPrimary),
  _WorldZone(
      country: 'Peru',
      city: 'Lima',
      tzId: 'America/Lima',
      shortLabel: 'Lima',
      color: AppColors.accentSecondary),
  _WorldZone(
      country: 'France',
      city: 'Paris',
      tzId: 'Europe/Paris',
      shortLabel: 'Paris',
      color: AppColors.accentTertiary),
  _WorldZone(
      country: 'Germany',
      city: 'Berlin',
      tzId: 'Europe/Berlin',
      shortLabel: 'Berlin',
      color: AppColors.accentPrimary),
  _WorldZone(
      country: 'Netherlands',
      city: 'Amsterdam',
      tzId: 'Europe/Amsterdam',
      shortLabel: 'AMS',
      color: AppColors.accentSecondary),
  _WorldZone(
      country: 'Spain',
      city: 'Madrid',
      tzId: 'Europe/Madrid',
      shortLabel: 'Madrid',
      color: AppColors.accentTertiary),
  _WorldZone(
      country: 'Italy',
      city: 'Rome',
      tzId: 'Europe/Rome',
      shortLabel: 'Rome',
      color: AppColors.accentPrimary),
  _WorldZone(
      country: 'Switzerland',
      city: 'Zurich',
      tzId: 'Europe/Zurich',
      shortLabel: 'Zurich',
      color: AppColors.accentSecondary),
  _WorldZone(
      country: 'Turkey',
      city: 'Istanbul',
      tzId: 'Europe/Istanbul',
      shortLabel: 'Istanbul',
      color: AppColors.accentTertiary),
  _WorldZone(
      country: 'Russia',
      city: 'Moscow',
      tzId: 'Europe/Moscow',
      shortLabel: 'Moscow',
      color: AppColors.accentPrimary),
  _WorldZone(
      country: 'United Arab Emirates',
      city: 'Dubai',
      tzId: 'Asia/Dubai',
      shortLabel: 'Dubai',
      color: AppColors.accentSecondary),
  _WorldZone(
      country: 'Saudi Arabia',
      city: 'Riyadh',
      tzId: 'Asia/Riyadh',
      shortLabel: 'Riyadh',
      color: AppColors.accentTertiary),
  _WorldZone(
      country: 'Qatar',
      city: 'Doha',
      tzId: 'Asia/Qatar',
      shortLabel: 'Doha',
      color: AppColors.accentPrimary),
  _WorldZone(
      country: 'India',
      city: 'New Delhi',
      tzId: 'Asia/Kolkata',
      shortLabel: 'Delhi',
      color: AppColors.accentSecondary),
  _WorldZone(
      country: 'Pakistan',
      city: 'Karachi',
      tzId: 'Asia/Karachi',
      shortLabel: 'Karachi',
      color: AppColors.accentTertiary),
  _WorldZone(
      country: 'Bangladesh',
      city: 'Dhaka',
      tzId: 'Asia/Dhaka',
      shortLabel: 'Dhaka',
      color: AppColors.accentPrimary),
  _WorldZone(
      country: 'Thailand',
      city: 'Bangkok',
      tzId: 'Asia/Bangkok',
      shortLabel: 'Bangkok',
      color: AppColors.accentSecondary),
  _WorldZone(
      country: 'Vietnam',
      city: 'Ho Chi Minh',
      tzId: 'Asia/Ho_Chi_Minh',
      shortLabel: 'HCMC',
      color: AppColors.accentTertiary),
  _WorldZone(
      country: 'Malaysia',
      city: 'Kuala Lumpur',
      tzId: 'Asia/Kuala_Lumpur',
      shortLabel: 'KL',
      color: AppColors.accentPrimary),
  _WorldZone(
      country: 'Singapore',
      city: 'Singapore',
      tzId: 'Asia/Singapore',
      shortLabel: 'SG',
      color: AppColors.accentSecondary),
  _WorldZone(
      country: 'Philippines',
      city: 'Manila',
      tzId: 'Asia/Manila',
      shortLabel: 'Manila',
      color: AppColors.accentTertiary),
  _WorldZone(
      country: 'China',
      city: 'Shanghai',
      tzId: 'Asia/Shanghai',
      shortLabel: 'Shanghai',
      color: AppColors.accentPrimary),
  _WorldZone(
      country: 'Hong Kong',
      city: 'Hong Kong',
      tzId: 'Asia/Hong_Kong',
      shortLabel: 'HK',
      color: AppColors.accentSecondary),
  _WorldZone(
      country: 'Taiwan',
      city: 'Taipei',
      tzId: 'Asia/Taipei',
      shortLabel: 'Taipei',
      color: AppColors.accentTertiary),
  _WorldZone(
      country: 'Japan',
      city: 'Tokyo',
      tzId: 'Asia/Tokyo',
      shortLabel: 'Tokyo',
      color: AppColors.accentPrimary),
  _WorldZone(
      country: 'South Korea',
      city: 'Seoul',
      tzId: 'Asia/Seoul',
      shortLabel: 'Seoul',
      color: AppColors.accentSecondary),
  _WorldZone(
      country: 'Australia',
      city: 'Sydney',
      tzId: 'Australia/Sydney',
      shortLabel: 'Sydney',
      color: AppColors.accentTertiary),
  _WorldZone(
      country: 'Australia',
      city: 'Perth',
      tzId: 'Australia/Perth',
      shortLabel: 'Perth',
      color: AppColors.accentPrimary),
  _WorldZone(
      country: 'New Zealand',
      city: 'Auckland',
      tzId: 'Pacific/Auckland',
      shortLabel: 'Auckland',
      color: AppColors.accentSecondary),
  _WorldZone(
      country: 'Egypt',
      city: 'Cairo',
      tzId: 'Africa/Cairo',
      shortLabel: 'Cairo',
      color: AppColors.accentTertiary),
  _WorldZone(
      country: 'South Africa',
      city: 'Johannesburg',
      tzId: 'Africa/Johannesburg',
      shortLabel: 'Joburg',
      color: AppColors.accentPrimary),
  _WorldZone(
      country: 'Kenya',
      city: 'Nairobi',
      tzId: 'Africa/Nairobi',
      shortLabel: 'Nairobi',
      color: AppColors.accentSecondary),
  _WorldZone(
      country: 'Nigeria',
      city: 'Lagos',
      tzId: 'Africa/Lagos',
      shortLabel: 'Lagos',
      color: AppColors.accentTertiary),
  _WorldZone(
      country: 'Morocco',
      city: 'Casablanca',
      tzId: 'Africa/Casablanca',
      shortLabel: 'Casa',
      color: AppColors.accentPrimary),
  _WorldZone(
      country: 'Hawaii',
      city: 'Honolulu',
      tzId: 'Pacific/Honolulu',
      shortLabel: 'HNL',
      color: AppColors.accentSecondary),
  _WorldZone(
      country: 'Fiji',
      city: 'Suva',
      tzId: 'Pacific/Fiji',
      shortLabel: 'Fiji',
      color: AppColors.accentTertiary),
];
