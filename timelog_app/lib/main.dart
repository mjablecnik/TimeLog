import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().requestPermission();
  runApp(
    const ProviderScope(
      child: TimeLogApp(),
    ),
  );
}
