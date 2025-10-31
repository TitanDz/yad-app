import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static void showSuccess(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    ElegantNotification.success(
      title: Text(title),
      description: Text(message),
      onDismiss: () {},
    ).show(context);
  }

  static void showError(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    ElegantNotification.error(
      title: Text(title),
      description: Text(message),
      onDismiss: () {},
    ).show(context);
  }

  static void showInfo(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    ElegantNotification.info(
      title: Text(title),
      description: Text(message),
      onDismiss: () {},
    ).show(context);
  }

  static void showWarning(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    ElegantNotification.info(
      title: Text(title),
      description: Text(message),
      onDismiss: () {},
    ).show(context);
  }
}
