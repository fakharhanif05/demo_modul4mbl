import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationUtils {
  /// Safely navigates to a named route, closing any open dialogs first
  static void safeOffAllNamed(String route, {dynamic arguments}) {
    // Close any open dialogs
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    // Use post-frame callback to ensure navigation happens after current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAllNamed(route, arguments: arguments);
    });
  }

  /// Safely navigates to a named route (replaces current route)
  static void safeOffNamed(String route, {dynamic arguments}) {
    // Close any open dialogs
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    // Use post-frame callback to ensure navigation happens after current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offNamed(route, arguments: arguments);
    });
  }

  /// Safely navigates to a named route (pushes new route)
  static void safeToNamed(String route, {dynamic arguments}) {
    // Close any open dialogs
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    // Use post-frame callback to ensure navigation happens after current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.toNamed(route, arguments: arguments);
    });
  }
}
