import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets.dart';
import '../auth_controller.dart';
import '../data/auth_repository.dart' show normalizePhone;

enum _Mode { login, signup }

/// M-Login — sign in / sign up (one account to buy and sell).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  _Mode _mode = _Mode.login;
  bool _obscure = true;
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();

  /// Sign-up only: the verification code was texted, waiting for it.
  bool _codeSent = false;
  bool _sendingCode = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _password.dispose();
    _code.dispose();
    super.dispose();
  }

  /// Checked before texting a code, so that an SMS is not spent on a form
  /// the API would reject afterwards.
  String? _signupError() {
    if (_name.text.trim().split(RegExp(r'\s+')).length < 2) {
      return 'Indiquez votre prénom et votre nom';
    }
    if (!RegExp(r'^\+261\d{9}$').hasMatch(normalizePhone(_phone.text))) {
      return 'Numéro de téléphone invalide';
    }
    if (_password.text.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }
    return null;
  }

  /// Sign-up, step 1: texts the verification code and shows the code field.
  Future<void> _sendCode() async {
    final invalid = _signupError();
    if (invalid != null) {
      showAppToast(context, invalid, icon: AppIcons.alert);
      return;
    }
    setState(() => _sendingCode = true);
    try {
      await ref.read(authControllerProvider.notifier).requestRegistrationCode(_phone.text);
      if (!mounted) return;
      setState(() {
        _codeSent = true;
        _code.clear();
      });
      showAppToast(context, 'Code envoyé par SMS', icon: AppIcons.message);
    } catch (error) {
      if (!mounted) return;
      showAppToast(
        context,
        error is ApiException ? error.message : 'Envoi du code impossible',
        icon: AppIcons.alert,
      );
    } finally {
      if (mounted) setState(() => _sendingCode = false);
    }
  }

  Future<void> _submit() async {
    final auth = ref.read(authControllerProvider.notifier);
    if (_mode == _Mode.login) {
      await auth.login(_phone.text, _password.text);
    } else if (!_codeSent) {
      return _sendCode();
    } else if (_code.text.length != 6) {
      showAppToast(context, 'Saisissez le code à 6 chiffres reçu par SMS', icon: AppIcons.alert);
      return;
    } else {
      await auth.register(_name.text, _phone.text, _password.text, _code.text);
    }
    if (!mounted) return;
    final state = ref.read(authControllerProvider);
    if (state.hasError) {
      final error = state.error;
      showAppToast(
        context,
        error is ApiException ? error.message : 'Connexion impossible',
        icon: AppIcons.alert,
      );
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authControllerProvider).isLoading || _sendingCode;
    final login = _mode == _Mode.login;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 250 + top,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(color: AppColors.pomme900),
              child: Stack(
                children: [
                  Positioned(
                    right: -60,
                    top: -40,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: const BoxDecoration(
                        color: AppColors.pommeDeep,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 30,
                    top: 50 + top,
                    child: const Icon(
                      AppIcons.sprout,
                      size: 96,
                      color: AppColors.pomme500,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 24 + top, 20, 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const AppLogo(dark: true),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              login
                                  ? 'Bon retour parmi nous'
                                  : 'Rejoignez le marché bio',
                              style: AppTypography.display(
                                size: 30,
                                weight: FontWeight.w800,
                                color: AppColors.pomme50,
                                height: 1.05,
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Un seul compte pour acheter et vendre.',
                              style: AppTypography.body(
                                size: 14,
                                color: AppColors.pommeMist,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -18),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedSwitch<_Mode>(
                      height: 42,
                      segments: const [
                        SegmentItem(value: _Mode.login, label: 'Connexion'),
                        SegmentItem(value: _Mode.signup, label: 'Inscription'),
                      ],
                      selected: _mode,
                      onChanged: (m) => setState(() {
                        _mode = m;
                        _codeSent = false;
                      }),
                    ),
                    const SizedBox(height: 16),
                    if (!login && _codeSent) ...[
                      Text(
                        'Un code à 6 chiffres a été envoyé par SMS au ${normalizePhone(_phone.text)}.',
                        style: AppTypography.body(size: 14, color: AppColors.muted),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Code de vérification',
                        hint: '6 chiffres',
                        controller: _code,
                        height: 50,
                        radius: 12,
                        fontSize: 16,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        autofocus: true,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Valider et créer mon compte',
                        height: 54,
                        expand: true,
                        loading: loading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppTextLink(
                            label: 'Modifier mes informations',
                            fontSize: 13,
                            minHeight: 44,
                            onTap: () => setState(() => _codeSent = false),
                          ),
                          AppTextLink(label: 'Renvoyer le code', fontSize: 13, minHeight: 44, onTap: _sendCode),
                        ],
                      ),
                    ] else ...[
                    if (!login) ...[
                      AppTextField(
                        label: 'Nom complet',
                        hint: 'Hery Rakoto',
                        controller: _name,
                        height: 50,
                        radius: 12,
                        fontSize: 16,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                    ],
                    AppTextField(
                      label: 'Numéro de téléphone',
                      hint: '34 00 000 00',
                      controller: _phone,
                      height: 50,
                      radius: 12,
                      fontSize: 16,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                      ],
                      prefix: Container(
                        height: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        margin: const EdgeInsets.only(right: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(color: AppColors.lineStrong),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '+261',
                          style: AppTypography.body(
                            size: 16,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Mot de passe',
                      style: AppTypography.body(size: 14, weight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    AppTextField(
                      hint: '••••••••',
                      controller: _password,
                      obscureText: _obscure,
                      height: 50,
                      radius: 12,
                      fontSize: 16,
                      onSubmitted: (_) => _submit(),
                      suffix: IconButton(
                        tooltip: _obscure
                            ? 'Afficher le mot de passe'
                            : 'Masquer le mot de passe',
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure ? AppIcons.eye : AppIcons.eyeOff,
                          size: 20,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: login ? 'Se connecter' : 'Créer mon compte',
                      height: 54,
                      expand: true,
                      loading: loading,
                      onPressed: _submit,
                    ),
                    ],
                    const SizedBox(height: 16),
                    Text.rich(
                      TextSpan(
                        style: AppTypography.body(
                          size: 12,
                          color: AppColors.muted,
                          height: 18 / 12,
                        ),
                        children: [
                          const TextSpan(
                            text: 'En continuant, vous acceptez les ',
                          ),
                          TextSpan(
                            text: 'conditions d’utilisation',
                            style: AppTypography.body(
                              size: 12,
                              color: AppColors.pomme700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' et la '),
                          TextSpan(
                            text: 'politique de confidentialité',
                            style: AppTypography.body(
                              size: 12,
                              color: AppColors.pomme700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
