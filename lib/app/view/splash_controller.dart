import 'package:flutter/material.dart';
import 'package:map_ai/app/utils/fonts.dart';

class SplashController extends StatelessWidget {
  const SplashController({super.key});

  static const String routeName = '/';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.orange,
      body: Center(child: Text('MapAI', style: AppFonts.header)),
    );
  }
}
