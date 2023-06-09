import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_ai/app/utils/fonts.dart';
import 'package:map_ai/features/auth/cubit/auth_cubit.dart';

class VerifyController extends StatelessWidget {
  const VerifyController({super.key});

  static const String routeName = '/verify';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            AppBar(backgroundColor: Colors.orange, title: const Text('MapAI')),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Verify your E-Mail', style: AppFonts.header),
                const SizedBox(height: 20),
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: CupertinoTextField(
                      placeholder: 'Verification code',
                      keyboardType: TextInputType.number,
                      padding: const EdgeInsets.all(10),
                      onChanged: (String value) =>
                          context.read<AuthCubit>().changeCode(value)),
                ),
                const SizedBox(height: 10),
                BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                  return CupertinoButton.filled(
                      child: state.requestStatus == RequestStatus.loading
                          ? const CupertinoActivityIndicator()
                          : const Text('Verify user'),
                      onPressed: () {
                        context.read<AuthCubit>().verifyUser();
                      });
                }),
              ],
            ),
          ),
        ));
  }
}
