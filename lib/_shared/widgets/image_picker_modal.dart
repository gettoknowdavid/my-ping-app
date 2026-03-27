import 'dart:io' show File;

import 'package:flutter/widgets.dart';
import 'package:ping/_ping.dart';
import 'package:ping/_shared/_shared.dart';

class ImagePickerModal extends StatelessWidget {
  const ImagePickerModal._() : super(key: null);

  static Future<File?> show(BuildContext context) => showShadSheet<File?>(
    context: context,
    useRootNavigator: true,
    side: ShadSheetSide.bottom,
    builder: (_) => const ImagePickerModal._(),
  );

  @override
  Widget build(BuildContext context) {
    final mediaService = di<MediaService>();
    return Padding(
      padding: const .fromLTRB(16, 0, 16, 16),
      child: ShadSheet(
        title: const Text('Pick an image source'),
        description: const Text(
          '''You can either take a picture or choose from your gallery''',
        ),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            const SizedBox(height: 16),
            ShadButton.outline(
              onPressed: () async {
                final file = await mediaService.camera(cropImage: true);
                if (file != null && context.mounted) context.pop(file);
              },
              leading: const Icon(LucideIcons.camera),
              child: const Text('Camera'),
            ),
            const SizedBox(height: 16),
            ShadButton.outline(
              onPressed: () async {
                final file = await mediaService.gallery(cropImage: true);
                if (file != null && context.mounted) context.pop(file);
              },
              leading: const Icon(LucideIcons.images),
              child: const Text('Gallery'),
            ),
          ],
        ),
      ),
    );
  }
}
