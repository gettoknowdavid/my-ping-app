import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ping/_ping.dart';

@lazySingleton
class MediaService {
  const MediaService({
    required ImagePicker imagePicker,
    required ImageCropper imageCropper,
  }) : _imagePicker = imagePicker,
       _imageCropper = imageCropper;

  final ImagePicker _imagePicker;
  final ImageCropper _imageCropper;

  Future<File?> gallery({bool cropImage = false}) async {
    final result = await _imagePicker.pickImage(source: .gallery);
    if (result == null) return null;
    return cropImage ? _cropImage(result.path) : File(result.path);
  }

  Future<File?> camera({bool cropImage = false}) async {
    final result = await _imagePicker.pickImage(
      source: .camera,
      preferredCameraDevice: .front,
    );
    if (result == null) return null;
    return cropImage ? _cropImage(result.path) : File(result.path);
  }

  Future<File?> _cropImage(String sourcePath) async {
    final croppedFile = await _imageCropper.cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop your image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          cropStyle: .circle,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
          ],
        ),
        IOSUiSettings(
          title: 'Crop your image',
          cropStyle: .circle,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
          ],
        ),
      ],
    );
    return croppedFile != null ? File(croppedFile.path) : null;
  }
}
