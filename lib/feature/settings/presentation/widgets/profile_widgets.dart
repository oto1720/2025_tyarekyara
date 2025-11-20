import 'dart:io';
import 'package:flutter/material.dart';

/// セクションタイトル
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
        letterSpacing: 0.5,
      ),
    );
  }
}

/// プロフィール画像表示
class ProfileImageDisplay extends StatelessWidget {
  final File? selectedImage;
  final String? iconUrl;
  final VoidCallback onTap;

  const ProfileImageDisplay({
    super.key,
    this.selectedImage,
    this.iconUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: _buildImage(context),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    print('=== ProfileImageDisplay._buildImage ===');
    print('selectedImage: ${selectedImage?.path}');
    print('iconUrl (raw): $iconUrl');

    // 選択した一時画像を優先表示
    if (selectedImage != null) {
      print('一時画像を表示');
      return Image.file(
        selectedImage!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    }

    // 保存済みの画像URLを表示
    if (iconUrl != null && iconUrl!.isNotEmpty) {
      // URLをトリム（あらゆる種類の空白文字を除去）
      final cleanUrl = iconUrl!.replaceAll(RegExp(r'\s+'), '');
      print('iconUrlが存在 (cleaned): $cleanUrl');
      print('iconUrl length: ${iconUrl!.length}, cleanUrl length: ${cleanUrl.length}');

      // アセット画像かネットワーク画像かを判定
      if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
        print('ネットワーク画像として読み込み開始');
        return Image.network(
          cleanUrl,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // ネットワークエラー時はデフォルトアイコンを表示
            print('❌ 画像読み込みエラー: $error');
            print('スタックトレース: $stackTrace');
            return Container(
              color: Colors.red[50],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 40,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'エラー',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              print('✅ 画像読み込み完了');
              return child;
            }
            final progress = loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null;
            print('画像読み込み中: ${progress != null ? "${(progress * 100).toStringAsFixed(0)}%" : "不明"}');
            return Center(
              child: CircularProgressIndicator(
                value: progress,
              ),
            );
          },
        );
      } else {
        print('⚠️ iconUrlがhttp/httpsで始まっていません: $cleanUrl');
      }
    } else {
      print('iconUrlが空またはnull');
    }

    // デフォルトアイコン
    print('デフォルトアイコンを表示');
    return Icon(
      Icons.person,
      size: 60,
      color: Theme.of(context).primaryColor,
    );
  }
}

/// 標準テキストフィールド
class StandardTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const StandardTextField({
    super.key,
    this.controller,
    this.initialValue,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        errorText: errorText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

/// パスワードフィールド
class PasswordTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String label;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const PasswordTextField({
    super.key,
    this.controller,
    this.initialValue,
    required this.label,
    this.errorText,
    this.onChanged,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock_outline),
        errorText: widget.errorText,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

/// ドロップダウンフィールド
class DropdownField extends StatelessWidget {
  final String? value;
  final String label;
  final IconData icon;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const DropdownField({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      isExpanded: true,
    );
  }
}

/// 保存ボタン
class SaveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const SaveButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              )
            : const Text(
                '保存する',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

/// 画像選択ダイアログ
class ImagePickerDialog extends StatelessWidget {
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  const ImagePickerDialog({
    super.key,
    required this.onGallery,
    required this.onCamera,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onGallery,
    required VoidCallback onCamera,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ImagePickerDialog(
        onGallery: onGallery,
        onCamera: onCamera,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('プロフィール画像を選択'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('ギャラリーから選択'),
            onTap: () {
              Navigator.pop(context);
              onGallery();
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('カメラで撮影'),
            onTap: () {
              Navigator.pop(context);
              onCamera();
            },
          ),
        ],
      ),
    );
  }
}
