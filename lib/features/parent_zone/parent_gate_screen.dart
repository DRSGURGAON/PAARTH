import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/navigation/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../game/models/parent_gate_challenge.dart';
import '../../game/systems/parent_gate_challenge_generator.dart';
import '../../shared/widgets/big_rounded_button.dart';

/// A simple "grown-ups only" gate in front of the Parent Zone (design
/// brief: "Behind an age-appropriate parent gate (V1: simple gate,
/// designed to be replaceable with something stronger later)"). A
/// child could brute-force a fixed answer, so a wrong attempt swaps in
/// a fresh challenge rather than letting them keep guessing the same one.
class ParentGateScreen extends StatefulWidget {
  const ParentGateScreen({this.random, super.key});

  /// Injectable randomness so tests can run deterministic challenges.
  final Random? random;

  @override
  State<ParentGateScreen> createState() => ParentGateScreenState();
}

@visibleForTesting
class ParentGateScreenState extends State<ParentGateScreen> {
  late ParentGateChallengeGenerator _generator;
  late ParentGateChallenge _challenge;
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @visibleForTesting
  ParentGateChallenge get currentChallenge => _challenge;

  @override
  void initState() {
    super.initState();
    _generator = ParentGateChallengeGenerator(random: widget.random);
    _challenge = _generator.next();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final entered = int.tryParse(_controller.text);
    if (entered == _challenge.answer) {
      Navigator.of(context).pushReplacementNamed(RouteNames.parentZone);
      return;
    }
    setState(() {
      _error = 'Not quite — try again.';
      _challenge = _generator.next();
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('For Grown-Ups')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.shield_rounded, size: 56, color: AppColors.grapePurple),
              const SizedBox(height: 16),
              Text(
                'Quick check for parents/guardians',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              Text(
                _challenge.prompt,
                textAlign: TextAlign.center,
                style: textTheme.displayMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                key: const ValueKey('parent_gate_input'),
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                onSubmitted: (_) => _submit(),
              ),
              SizedBox(
                height: 32,
                child: _error == null
                    ? null
                    : Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge
                            ?.copyWith(color: AppColors.gentleWarning),
                      ),
              ),
              const Spacer(flex: 2),
              BigRoundedButton(
                label: 'Continue',
                icon: Icons.arrow_forward_rounded,
                backgroundColor: AppColors.grapePurple,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
