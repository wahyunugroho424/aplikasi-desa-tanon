import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseDatabase.instance.databaseURL =
      'https://lepi-store-app-default-rtdb.asia-southeast1.firebasedatabase.app';

  await Supabase.initialize(
    url: 'https://jiywbhtwhzwnyvcxttfe.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImppeXdiaHR3aHp3bnl2Y3h0dGZlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAzNDI5MzksImV4cCI6MjA3NTkxODkzOX0.Or1cVjgXH0N9lV2WEfGHzGwJL5NJKMn3x828yhtXfQA',
    debug: true,
  );

  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'E-Tanon App',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF2F6FF),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
