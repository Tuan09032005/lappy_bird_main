import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager {
  static final SupabaseManager _instance = SupabaseManager._internal();
  factory SupabaseManager() => _instance;
  SupabaseManager._internal();

  late final SupabaseClient client;

  Future<void> init() async {
    await Supabase.initialize(
      url: 'https://znbruwgfqbyyuyzmepjo.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpuYnJ1d2dmcWJ5eXV5em1lcGpvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIyNzI5MTMsImV4cCI6MjA3Nzg0ODkxM30.0etVYgQ_xejMk7yEWd4RobnBlHV6qA15h-q5_BjwrEo',
    );
    client = Supabase.instance.client;
  }
}