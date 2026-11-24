import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';

/// Sign in and sign up in one screen.
///
/// Email accounts are stored in this browser only. Apple, Google and Facebook
/// are simulated until a real sign-in service is connected (docs/AUTH.md).
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _signUp = true;
  bool _hidePassword = true;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    final state = AppScope.of(context);
    final error = _signUp
        ? state.signUpWithEmail(
            name: _name.text,
            email: _email.text,
            password: _password.text,
          )
        : state.signInWithEmail(_email.text, _password.text);
    if (error != null) setState(() => _error = error);
  }

  void _switchMode(bool signUp) => setState(() {
        _signUp = signUp;
        _error = null;
      });

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final text = Theme.of(context).textTheme;
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, top + 32, 20, bottom + 32),
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: BrandMark(size: 52),
              ),
              const SizedBox(height: 20),
              Text(
                _signUp ? 'Create your account' : 'Welcome back',
                style: text.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                _signUp
                    ? 'Train, eat and track in one place. We will ask a few '
                        'questions next to set your daily calories.'
                    : 'Sign in to pick up your training and food log.',
                style: text.bodyMedium?.copyWith(color: AppColors.gray300),
              ),
              const SizedBox(height: 20),
              SubTabs(
                labels: const ['Sign up', 'Sign in'],
                index: _signUp ? 0 : 1,
                onChanged: (i) => _switchMode(i == 0),
              ),
              const SizedBox(height: 16),
              NeoCard(
                padding: const EdgeInsets.all(16),
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_signUp) ...[
                        TextField(
                          controller: _name,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [AutofillHints.name],
                          decoration: const InputDecoration(labelText: 'Name'),
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _password,
                        obscureText: _hidePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: [
                          _signUp
                              ? AutofillHints.newPassword
                              : AutofillHints.password,
                        ],
                        onSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          helperText: _signUp ? 'At least 8 characters' : null,
                          suffixIcon: IconButton(
                            tooltip: _hidePassword
                                ? 'Show password'
                                : 'Hide password',
                            icon: Icon(_hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                            onPressed: () => setState(
                                () => _hidePassword = !_hidePassword),
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Semantics(
                          liveRegion: true,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 18, color: AppColors.rose),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: text.bodySmall
                                      ?.copyWith(color: AppColors.rose),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _submit,
                        child: Text(_signUp ? 'Create account' : 'Sign in'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.hairline)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or continue with',
                      style: text.bodySmall
                          ?.copyWith(color: AppColors.gray400),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.hairline)),
                ],
              ),
              const SizedBox(height: 16),
              _SocialButton(
                icon: Icons.apple,
                label: 'Continue with Apple',
                onTap: () => state.signInDemo('apple'),
              ),
              const SizedBox(height: 10),
              _SocialButton(
                icon: Icons.mail_outline,
                label: 'Continue with Gmail',
                onTap: () => state.signInDemo('google'),
              ),
              const SizedBox(height: 10),
              _SocialButton(
                icon: Icons.facebook,
                label: 'Continue with Facebook',
                onTap: () => state.signInDemo('facebook'),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: state.continueAsGuest,
                icon: const Icon(Icons.person_outline, size: 18),
                label: const Text('Continue as guest'),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: AppColors.gray400),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Demo mode: Apple, Gmail and Facebook sign-in are '
                      'simulated until a real sign-in service is connected. '
                      'Accounts are stored only in this browser.',
                      style: text.bodySmall
                          ?.copyWith(color: AppColors.gray400),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
    );
  }
}
