import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_ai/app/view/splash_controller.dart';
import 'package:map_ai/features/auth/cubit/auth_cubit.dart';
import 'package:map_ai/features/auth/repositories/auth_repository.dart';
import 'package:map_ai/features/auth/view/login_controller.dart';
import 'package:map_ai/features/auth/view/register_controller.dart';
import 'package:map_ai/features/auth/view/verify_controller.dart';
import 'package:map_ai/features/map/bloc/map_cubit.dart';
import 'package:map_ai/features/map/view/map_controller.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppController extends StatelessWidget {
  const AppController({super.key});

  NavigatorState? get navigator => navigatorKey.currentState;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) =>
                  AuthCubit(context.read<AuthRepository>())..init()),
          BlocProvider(create: (context) => MapCubit()),
        ],
        child: MaterialApp(
          title: 'MapAI',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          builder: (context, child) {
            return BlocListener<AuthCubit, AuthState>(
                listenWhen: (previous, current) =>
                    previous.status != current.status,
                listener: (context, state) {
                  print(state.status);

                  if (state.status == Status.authenticated) {
                    navigator?.pushNamedAndRemoveUntil(
                        MapViewController.routeName, (route) => false);
                  } else if (state.status == Status.unauthenticated) {
                    navigator?.pushNamedAndRemoveUntil(
                        LoginController.routeName, (route) => false);
                  } else if (state.status == Status.unverified) {
                    navigator?.pushNamedAndRemoveUntil(
                        VerifyController.routeName, (route) => false);
                  }
                },
                child: child);
          },
          theme: ThemeData(
            primarySwatch: Colors.orange,
          ),
          routes: {
            LoginController.routeName: (context) => const LoginController(),
            RegisterController.routeName: (context) =>
                const RegisterController(),
            VerifyController.routeName: (context) => const VerifyController(),
            MapViewController.routeName: (context) => const MapViewController(),
            SplashController.routeName: (context) => const SplashController()
          },
          initialRoute: SplashController.routeName,
        ),
      ),
    );
  }
}
