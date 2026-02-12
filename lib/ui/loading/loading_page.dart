import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:spogpaws/themes/loading_animations.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final animation = LoadingAnimations.random();
    final text = LoadingTexts.random();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(animation, height: 160, decoder: customDecoder),
              const SizedBox(height: 24),
              Text(
                text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<LottieComposition?> customDecoder(List<int> bytes) {
  return LottieComposition.decodeZip(
    bytes,
    filePicker: (files) {
      return files.firstWhere(
        (f) => f.name.startsWith('animations/') && f.name.endsWith('.json'),
      );
    },
  );
}
