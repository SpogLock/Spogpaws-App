import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spogpaws/bloc/user/user_bloc.dart';
import 'package:spogpaws/repositories/clinic_repository.dart';
import 'package:spogpaws/repositories/update_policy_repository.dart';
import 'package:spogpaws/repositories/adoption_repository.dart';
import 'package:spogpaws/repositories/tip_repository.dart';
import 'package:spogpaws/repositories/user_repository.dart';
import 'package:spogpaws/themes/app_theme.dart';
import 'package:spogpaws/ui/loading/splash_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError(
      'Missing Supabase config in .env. Set SUPABASE_URL and SUPABASE_ANON_KEY.',
    );
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>(create: (_) => UserRepository()),
        RepositoryProvider<UpdatePolicyRepository>(
          create: (_) => UpdatePolicyRepository(),
        ),
        RepositoryProvider<AdoptionRepository>(
          create: (_) => AdoptionRepository(),
        ),
        RepositoryProvider<ClinicRepository>(create: (_) => ClinicRepository()),
        RepositoryProvider<TipRepository>(create: (_) => TipRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<UserBloc>(
            create: (context) =>
                UserBloc(userRepository: context.read<UserRepository>()),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          debugShowCheckedModeBanner: false,
          home: const SplashPage(),
        ),
      ),
    );
  }
}
