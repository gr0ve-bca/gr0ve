import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:spr0ut/spr0ut.dart';
import '../../../../config/home_prefs.dart';
import '../../../../config/theme.dart';
import '../../../../services/auth_service.dart';
import '../common/panel_card.dart';

enum MiniAuthState { enterEmail, enterCode, confirmProfile }

class MiniLoginCard extends StatefulWidget {
  const MiniLoginCard({
    super.key,
    required this.p,
    this.onLoggedIn,
    this.fill = true,
    this.mobile = false,
  });

  final Palette p;
  final VoidCallback? onLoggedIn;
  final bool fill;
  final bool mobile;

  @override
  State<MiniLoginCard> createState() => _MiniLoginCardState();
}

class _MiniLoginCardState extends State<MiniLoginCard> {
  MiniAuthState _state = MiniAuthState.enterEmail;

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

  void _onCodeChanged() {
    setState(() {});
    if (_codeController.text.trim().length == 6 &&
        !_isLoading &&
        _state == MiniAuthState.enterCode) {
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
        await AuthService.instance.send6DigitEmailCode(email);
      } catch (_) {}

      setState(() {
        _state = MiniAuthState.enterCode;
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

    if (code.length != 6) {
      setState(() => _errorMessage = 'Please enter the full 6-digit code.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final identity = await AuthService.instance.verify6DigitCode(
        email: email,
        code: code,
      );

      _verifiedIdentity = identity;

      final existingProfile = await AuthService.instance.checkExistingProfile(
        identity.uid,
      );

      if (existingProfile != null && existingProfile.displayName.isNotEmpty) {
        AuthService.instance.setActiveUser(existingProfile);
        widget.onLoggedIn?.call();
        return;
      }

      final rosterStudent = Spr0utRoster.instance.lookup(email);

      _fnameController.text = rosterStudent?.firstName ?? '';
      _lnameController.text = rosterStudent?.lastName ?? '';
      _academyController.text = rosterStudent?.academy ?? 'ATCS';
      _gradYearController.text = (rosterStudent?.gradYear ?? 2029).toString();

      setState(() {
        _state = MiniAuthState.confirmProfile;
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
      final profile = await AuthService.instance.saveProfile(
        uid: uid,
        email: email,
        firstName: fname,
        lastName: lname,
        academy: academy,
        gradYear: gradYear,
      );
      AuthService.instance.setActiveUser(profile);
      widget.onLoggedIn?.call();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to save profile. Please try again.';
      });
    }
  }

  void _goBackToEmail() {
    setState(() {
      _state = MiniAuthState.enterEmail;
      _errorMessage = null;
      _codeController.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _emailFocusNode.requestFocus();
    });
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

  InputDecoration _inputDec(Palette p, String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.inter(color: p.sub, fontSize: 15),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    filled: true,
    fillColor: p.surface,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: p.line, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: p.ink, width: 2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return panelCard(
      p,
      'Sign In',
      LucideIcons.logIn,
      SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: switch (_state) {
            MiniAuthState.enterEmail => _buildEmailStep(p),
            MiniAuthState.enterCode => _buildCodeStep(p),
            MiniAuthState.confirmProfile => _buildProfileStep(p),
          },
        ),
      ),
      fill: widget.fill,
      enter: 1,
      mobile: widget.mobile,
    );
  }

  Widget _buildEmailStep(Palette p) => Column(
    key: const ValueKey('email_step'),
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const SizedBox(height: 12),
      Text(
        'GR0VE',
        textAlign: TextAlign.center,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: p.ink,
          letterSpacing: 3.0,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        'Enter your school email address to continue',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: p.sub,
        ),
      ),
      const SizedBox(height: 28),
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
        decoration: _inputDec(p, 'name@bergen.org'),
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
                    strokeWidth: 2,
                    color: p.onAccent,
                  ),
                )
              : const Text('CONTINUE'),
        ),
      ),
    ],
  );

  Widget _buildCodeStep(Palette p) {
    final email = _emailController.text.trim();

    return Column(
      key: const ValueKey('code_step'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        Text(
          'GR0VE',
          textAlign: TextAlign.center,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: p.ink,
            letterSpacing: 3.0,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Enter the 6 digit code sent to $email',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: p.sub,
          ),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: _codeController,
          focusNode: _codeFocusNode,
          autofocus: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 6,
          autofillHints: const [AutofillHints.oneTimeCode],
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          cursorColor: p.ink,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 8,
            color: p.text,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: '000000',
            hintStyle: GoogleFonts.jetBrainsMono(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 8,
              color: p.line,
            ),
            filled: true,
            fillColor: p.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: p.line, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: p.ink, width: 2),
            ),
          ),
          onSubmitted: (_) => _handleVerifyCode(),
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
                      strokeWidth: 2,
                      color: p.onAccent,
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

  Widget _buildProfileStep(Palette p) {
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

    return Column(
      key: const ValueKey('profile_step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Confirm or update your student details.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: p.sub),
          ),
        ),
        const SizedBox(height: 24),
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
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: p.text,
          ),
          decoration: _inputDec(p, 'First name'),
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
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: p.text,
          ),
          decoration: _inputDec(p, 'Last name'),
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
                    decoration: _inputDec(p, 'e.g. ATCS'),
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
                    decoration: _inputDec(p, 'e.g. 2029'),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                      strokeWidth: 2,
                      color: p.onAccent,
                    ),
                  )
                : const Text('CONFIRM AND CONTINUE'),
          ),
        ),
      ],
    );
  }
}
