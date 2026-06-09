import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/user.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../auth/data/auth_local_datasource.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  UserModel? _user;
  Uint8List? _imageBytes;
  bool _loading = true;
  bool _saving = false;

  static const _bgTop = Color(0xFF181821);
  static const _bgMid = Color(0xFF0F0F16);
  static const _bgBottom = Color(0xFF06070B);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = await getIt<AuthLocalDataSource>().currentUser();
    final prefs = await SharedPreferences.getInstance();
    final imageBase64 = prefs.getString('profile_image');
    final bio = prefs.getString('profile_bio') ??
        'Penjelajah Jogja yang suka menemukan cerita baru.';

    Uint8List? image;
    if (imageBase64 != null && imageBase64.isNotEmpty) {
      image = base64Decode(imageBase64);
    }

    if (!mounted) return;
    setState(() {
      _user = user;
      _nameController.text = user?.name ?? '';
      _emailController.text = user?.email ?? '';
      _bioController.text = bio;
      _imageBytes = image;
      _loading = false;
    });
  }

  Future<void> _pickImage() async {
    HapticFeedback.selectionClick();
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 82,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() => _imageBytes = bytes);
  }

  Future<void> _removeImage() async {
    HapticFeedback.selectionClick();
    setState(() => _imageBytes = null);
  }

  Future<void> _save() async {
    final current = _user;
    if (current == null) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final bio = _bioController.text.trim();
    if (name.length < 2) {
      _showMessage('Nama minimal 2 karakter.');
      return;
    }
    final emailOk = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!emailOk) {
      _showMessage('Email belum sesuai. Coba cek lagi, ya.');
      return;
    }

    setState(() => _saving = true);

    try {
      final api = getIt<ApiClient>();
      await api.dio.patch('/me/profile', data: {
        'fullName': name,
        'bio': bio.isEmpty ? null : bio,
      });
      if (email != current.email.toLowerCase()) {
        await api.dio.patch('/me/email', data: {'email': email});
      }
    } catch (_) {
      // Tetap simpan lokal supaya perubahan profil tidak hilang saat backend sedang tidak aktif.
    }

    final updated = UserModel(
      id: current.id,
      name: name,
      email: email,
      joinedAt: current.joinedAt,
      quizBestScore: current.quizBestScore,
      visitedCount: current.visitedCount,
    );

    final usersBox = Hive.box<UserModel>(AppConstants.usersBox);
    if (current.email.toLowerCase() != email) {
      await usersBox.delete(current.email);
    }
    await usersBox.put(updated.email, updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.currentUserKey, updated.email);
    await prefs.setString(
        'profile_bio',
        bio.isEmpty
            ? 'Penjelajah Jogja yang suka menemukan cerita baru.'
            : bio);
    if (_imageBytes == null) {
      await prefs.remove('profile_image');
    } else {
      await prefs.setString('profile_image', base64Encode(_imageBytes!));
    }

    if (!mounted) return;
    setState(() {
      _user = updated;
      _saving = false;
    });
    _showMessage('Profil berhasil diperbarui.');
  }

  void _showMessage(String message) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Edit Profil'),
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
    return CupertinoPageScaffold(
      backgroundColor: _bgBottom,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.18,
            colors: [Color(0xFF282836), _bgTop, _bgMid, _bgBottom],
            stops: [0, 0.32, 0.68, 1],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(child: CupertinoActivityIndicator())
              : ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 34),
                  children: [
                    Row(
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(context).maybePop(),
                          child: const Icon(CupertinoIcons.chevron_back,
                              color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Edit Profil',
                            style: AppTypography.displayBold34.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 30,
                              letterSpacing: -0.9,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    GlassCard(
                      blur: 34,
                      opacity: 0.078,
                      borderRadius: 30,
                      borderColor: CupertinoColors.white.withOpacity(0.12),
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 92,
                              height: 92,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: CupertinoColors.white.withOpacity(0.08),
                                border: Border.all(
                                    color: CupertinoColors.white
                                        .withOpacity(0.14)),
                              ),
                              child: _imageBytes == null
                                  ? const Icon(
                                      CupertinoIcons.person_crop_circle_fill,
                                      size: 58,
                                      color: AppColors.textSecondary)
                                  : Image.memory(_imageBytes!,
                                      fit: BoxFit.cover,
                                      cacheWidth: 184,
                                      cacheHeight: 184),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              CupertinoButton(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                onPressed: _pickImage,
                                child: const Text(
                                  'Ganti Foto',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              CupertinoButton(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                onPressed: _removeImage,
                                child: const Text(
                                  'Hapus',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _FieldCard(
                      label: 'Nama tampilan',
                      controller: _nameController,
                      placeholder: 'Nama kamu',
                      enabled: true,
                    ),
                    const SizedBox(height: 12),
                    _FieldCard(
                      label: 'Email akun',
                      controller: _emailController,
                      placeholder: 'email@example.com',
                      enabled: true,
                    ),
                    const SizedBox(height: 12),
                    _FieldCard(
                      label: 'Bio singkat',
                      controller: _bioController,
                      placeholder: 'Ceritakan sedikit tentang gaya jelajahmu',
                      enabled: true,
                      minLines: 2,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 22),
                    CupertinoButton(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.accentPrimary,
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const CupertinoActivityIndicator(
                              color: CupertinoColors.white)
                          : Text(
                              'Simpan Perubahan',
                              style: AppTypography.textMedium15.copyWith(
                                color: CupertinoColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.label,
    required this.controller,
    required this.placeholder,
    required this.enabled,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String placeholder;
  final bool enabled;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 30,
      opacity: 0.074,
      borderRadius: 24,
      borderColor: CupertinoColors.white.withOpacity(0.11),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.captionSmall11.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          CupertinoTextField.borderless(
            controller: controller,
            enabled: enabled,
            placeholder: placeholder,
            minLines: minLines,
            maxLines: maxLines,
            style: AppTypography.textMedium15.copyWith(
              color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            placeholderStyle: AppTypography.textRegular13.copyWith(
              color: AppColors.textSecondary,
            ),
            padding: EdgeInsets.zero,
            cursorColor: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}
