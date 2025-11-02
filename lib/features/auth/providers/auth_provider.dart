import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ai_chat_app/shared/services/supabase_service.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  User? build() {
    final supabase = SupabaseService.instance;
    
    supabase.authStateChanges.listen((event) {
      state = event.session?.user;
    });
    
    return supabase.currentUser;
  }

  Future<void> signIn(String email, String password) async {
    final supabase = SupabaseService.instance;
    await supabase.signIn(email: email, password: password);
    state = supabase.currentUser;
  }

  Future<void> signUp(String email, String password) async {
    final supabase = SupabaseService.instance;
    await supabase.signUp(email: email, password: password);
    state = supabase.currentUser;
  }

  Future<void> signOut() async {
    final supabase = SupabaseService.instance;
    await supabase.signOut();
    state = null;
  }
}
