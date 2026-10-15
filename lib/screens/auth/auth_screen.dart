import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spr0ut/spr0ut.dart';

import '../../config/home_prefs.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/arbor_graphic.dart';

enum AuthScreenState { enterEmail, enterCode, confirmProfile }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.onLoggedIn});

  final VoidCallback? onLoggedIn;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthScreenState _viewState = AuthScreenState.enterEmail;

  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  final _codeController = TextEditingController();
  final _codeFocusNode = FocusNode();

  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _academyController = TextEditingController();
  final _gradYearController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  Spr0utIdentity? _verifiedIdentity;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onCodeChanged);
    _emailFocusNode.addListener(_onEmailFocusChanged);
  }

  void _onEmailFocusChanged() {
    if (!_emailFocusNode.hasFocus) {
      _autoCompleteEmail();
    }
  }

  void _autoCompleteEmail() {
    final raw = _emailController.text.trim().toLowerCase();
    if (raw.isNotEmpty && !raw.contains('@')) {
      _emailController.text = '$raw@bergen.org';
      _emailController.selection = TextSelection.fromPosition(
        TextPosition(offset: _emailController.text.length),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    _codeController.dispose();
    _codeFocusNode.dispose();
    _fnameController.dispose();
    _lnameController.dispose();
    _academyController.dispose();
    _gradYearController.dispose();
    super.dispose();
  }

  void _onCodeChanged() {
    setState(() {});
    if (_codeController.text.trim().length == 8 &&
        !_isLoading &&
        _viewState == AuthScreenState.enterCode) {
      _handleVerifyCode();
    }
  }

  Future<void> _handleSendEmail() async {
    _autoCompleteEmail();
    final email = _emailController.text.trim().toLowerCase();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter your email address.');
      return;
    }

    if (!email.endsWith('@bergen.org')) {
      setState(
        () => _errorMessage =
            'Please enter your school email address ending in bergen.org.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      try {
        await AuthService.instance.send8DigitEmailCode(email);
      } catch (_) {
      }

      setState(() {
        _viewState = AuthScreenState.enterCode;
        _isLoading = false;
      });

      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _codeFocusNode.requestFocus();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not send verification code. Please try again.';
      });
    }
  }

  Future<void> _handleVerifyCode() async {
    final email = _emailController.text.trim().toLowerCase();
    final code = _codeController.text.trim();

    if (code.length != 8) {
      setState(() => _errorMessage = 'Please enter the full 8-digit code.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final identity = await AuthService.instance.verify8DigitCode(
        email: email,
        code: code,
      );

      _verifiedIdentity = identity;

      final existingProfile = await AuthService.instance.checkExistingProfile(
        identity.uid,
      );

      if (existingProfile != null && existingProfile.displayName.isNotEmpty) {
        AuthService.instance.setActiveUser(existingProfile);

        if (!mounted) return;
        if (widget.onLoggedIn != null) {
          widget.onLoggedIn!();
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
        }
        return;
      }

      final rosterStudent = Spr0utRoster.instance.lookup(email);

      _fnameController.text = rosterStudent?.firstName ?? '';
      _lnameController.text = rosterStudent?.lastName ?? '';
      _academyController.text = rosterStudent?.academy ?? 'ATCS';
      _gradYearController.text = (rosterStudent?.gradYear ?? 2029).toString();

      setState(() {
        _viewState = AuthScreenState.confirmProfile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'The code is invalid or has expired. Please try again.';
      });
    }
  }

  Future<void> _handleSaveProfile() async {
    final fname = _fnameController.text.trim();
    final lname = _lnameController.text.trim();
    final academy = _academyController.text.trim().toUpperCase();
    final gradYear = int.tryParse(_gradYearController.text.trim()) ?? 2029;
    final email = _emailController.text.trim().toLowerCase();
    final uid = _verifiedIdentity?.uid ?? 'usr_${email.split('@')[0]}';

    if (fname.isEmpty || lname.isEmpty) {
      setState(
        () => _errorMessage = 'Please provide both your first and last name.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.instance.saveProfile(
        uid: uid,
        email: email,
        firstName: fname,
        lastName: lname,
        academy: academy,
        gradYear: gradYear,
      );

      if (!mounted) return;

      if (widget.onLoggedIn != null) {
        widget.onLoggedIn!();
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not save profile. Please try again.';
      });
    }
  }

  void _goBackToEmail() {
    setState(() {
      _viewState = AuthScreenState.enterEmail;
      _errorMessage = null;
      _codeController.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _emailFocusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark ||
        MediaQuery.platformBrightnessOf(context) == Brightness.dark ||
        HomePrefs.instance.dark;
    final p = Palette.of(Gr0veColors.grover, dark: isDark);

    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              right: 0,
              bottom: 0,
              child: ArborGraphic(
                color: Gr0veColors.grover,
                width: 250,
                height: 210,
                opacity: 0.45,
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 48),
                        Text(
                          'GR0VE',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: Gr0veColors.grover,
                            letterSpacing: 3.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        switch (_viewState) {
                          AuthScreenState.enterEmail => _buildEmailStep(p),
                          AuthScreenState.enterCode => _buildCodeStep(p),
                          AuthScreenState.confirmProfile =>
                            _buildConfirmProfileStep(p),
                        },
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailStep(Palette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Enter your school email address to continue',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: p.sub,
          ),
        ),
        const SizedBox(height: 36),
        TextField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          enabled: !_isLoading,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: p.text,
          ),
          decoration: InputDecoration(
            hintText: 'name@bergen.org',
            hintStyle: GoogleFonts.inter(color: p.sub),
            filled: true,
            fillColor: p.surface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: p.line, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Gr0veColors.grover, width: 2),
            ),
          ),
          onSubmitted: (_) => _handleSendEmail(),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          _buildErrorText(_errorMessage!),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSendEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: p.ink,
              foregroundColor: p.onAccent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: p.onAccent,
                      strokeWidth: 2.0,
                    ),
                  )
                : const Text('CONTINUE'),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeStep(Palette p) {
    final email = _emailController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Enter the 8 digit code sent to $email',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: p.sub,
          ),
        ),
        const SizedBox(height: 36),
        _buildContinuous8BoxInput(p),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          _buildErrorText(_errorMessage!),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleVerifyCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: p.ink,
              foregroundColor: p.onAccent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: p.onAccent,
                      strokeWidth: 2.0,
                    ),
                  )
                : const Text('CONTINUE'),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _isLoading ? null : _goBackToEmail,
          child: Text(
            'Use a different email address',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: p.sub,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinuous8BoxInput(Palette p) {
    return TextField(
      controller: _codeController,
      focusNode: _codeFocusNode,
      autofocus: true,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 8,
      autofillHints: const [AutofillHints.oneTimeCode],
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      cursorColor: Gr0veColors.grover,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: 10,
        color: p.text,
      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: '00000000',
        hintStyle: GoogleFonts.jetBrainsMono(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          letterSpacing: 10,
          color: p.line,
        ),
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.only(left: 10, top: 16, bottom: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.line, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Gr0veColors.grover, width: 2),
        ),
      ),
    );
  }

  Widget _buildConfirmProfileStep(Palette p) {
    final gradYear = int.tryParse(_gradYearController.text.trim()) ?? 2029;
    final now = DateTime.now();
    final seniorGradYear = now.month >= 8 ? now.year + 1 : now.year;
    final grade = gradYear > 0
        ? (12 - (gradYear - seniorGradYear)).clamp(9, 12)
        : 10;
    final gradeLabel = switch (grade) {
      9 => 'Freshman',
      10 => 'Sophomore',
      11 => 'Junior',
      12 => 'Senior',
      _ => 'Grade $grade',
    };

    InputDecoration profileDec(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: p.sub),
      filled: true,
      fillColor: p.surface,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: p.line, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Gr0veColors.grover, width: 2),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Confirm or update your student details.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: p.sub,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'First name',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: p.text,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _fnameController,
          enabled: !_isLoading,
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: p.text),
          decoration: profileDec('First name'),
        ),
        const SizedBox(height: 16),
        Text(
          'Last name',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: p.text,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _lnameController,
          enabled: !_isLoading,
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: p.text),
          decoration: profileDec('Last name'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Academy',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: p.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _academyController,
                    enabled: !_isLoading,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: p.text,
                    ),
                    decoration: profileDec('e.g. ATCS'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Graduation year ($gradeLabel)',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: p.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _gradYearController,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: p.text,
                    ),
                    decoration: profileDec('e.g. 2029'),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          _buildErrorText(_errorMessage!),
        ],
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSaveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: p.ink,
              foregroundColor: p.onAccent,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: p.onAccent,
                      strokeWidth: 2.0,
                    ),
                  )
                : const Text('CONFIRM AND CONTINUE'),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorText(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Gr0veColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Gr0veColors.error.withOpacity(0.25)),
      ),
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Gr0veColors.error,
        ),
      ),
    );
  }
}
