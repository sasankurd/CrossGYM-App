import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/photo.dart';

/// Picks a picture from the device. Returns a shrunken PNG, or null when the
/// person cancelled. Shows a message when the file is not a picture.
Future<Uint8List?> pickPhoto(
  BuildContext context, {
  required bool square,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final bytes = result?.files.single.bytes;
    if (bytes == null) return null;
    return await shrinkImage(bytes, square: square);
  } on Object {
    messenger.showSnackBar(const SnackBar(
        content: Text('That file could not be read as a picture.')));
    return null;
  }
}

/// Lets the person choose or remove their profile picture.
Future<void> editProfilePhoto(BuildContext context) async {
  final state = AppScope.of(context);
  final choice = await showModalBottomSheet<String>(
    context: context,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose a photo'),
            onTap: () => Navigator.of(sheet).pop('pick'),
          ),
          if (state.me.photo != null)
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Remove photo'),
              onTap: () => Navigator.of(sheet).pop('remove'),
            ),
        ],
      ),
    ),
  );
  if (!context.mounted || choice == null) return;
  if (choice == 'remove') {
    state.setMyPhoto(null);
    return;
  }
  final png = await pickPhoto(context, square: true);
  if (png != null) state.setMyPhoto(png);
}
