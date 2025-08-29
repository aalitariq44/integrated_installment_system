import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io'; // Import dart:io for HttpOverrides
import 'app.dart';
import 'core/utils/http_override.dart'; // Import the custom HttpOverrides

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Temporarily bypass SSL certificate validation for development
  HttpOverrides.global = MyHttpOverrides();

  await Supabase.initialize(
    url: 'https://xxqwhvjejjuvlnzanlha.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh4cXdodmplamp1dmxuemFubGhhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI2NjUxMzMsImV4cCI6MjA2ODI0MTEzM30.k39bJx15XHfl_8u8P0MZZdtCqlLRFJnpZd0GefPpPZI',
  );

  runApp(const InstallmentApp());
}
