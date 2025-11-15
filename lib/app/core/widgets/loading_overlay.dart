// ============ core/widgets/loading_overlay.dart ============
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingOverlay {
  static void show() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hide() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}