import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:license_sahayak/utils/app_constants.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

const _kSlate50 = Color(0xFFF8FAFC);
const _kSlate100 = Color(0xFFF1F5F9);
const _kSlate200 = Color(0xFFE2E8F0);
const _kSlate400 = Color(0xFF94A3B8);
const _kSlate600 = Color(0xFF475569);
const _kSlate900 = Color(0xFF0F172A);
const _kGreen = Color(0xFF22C55E);
const _kGreenBg = Color(0xFFDCFCE7);
const _kRed = Color(0xFFEF4444);
const _kRedBg = Color(0xFFFEE2E2);
const _kAmber = Color(0xFFD97706);
const _kAmberBg = Color(0xFFFFFBEB);

void otpDialog({
  required TextEditingController verificationCodeController,
  required double bookedWeight,
  required Future<bool> Function() onVerify,
  required Future<bool> Function(double newWeight) onRequestWeightUpdate,
  bool allowWeightUpdate = true,
  bool isWeightConfirmed = false,
}) {
  Get.dialog(
    barrierDismissible: false,
    _OtpFlowDialog(
      verificationCodeController: verificationCodeController,
      bookedWeight: bookedWeight,
      onVerify: onVerify,
      onRequestWeightUpdate: onRequestWeightUpdate,
      allowWeightUpdate: allowWeightUpdate,
      isWeightConfirmed: isWeightConfirmed,
    ),
  );
}

class _OtpFlowDialog extends StatefulWidget {
  final TextEditingController verificationCodeController;
  final double bookedWeight;
  final Future<bool> Function() onVerify;
  final Future<bool> Function(double newWeight) onRequestWeightUpdate;
  final bool allowWeightUpdate;
  final bool isWeightConfirmed;

  const _OtpFlowDialog({
    required this.verificationCodeController,
    required this.bookedWeight,
    required this.onVerify,
    required this.onRequestWeightUpdate,
    required this.allowWeightUpdate,
    required this.isWeightConfirmed,
  });

  @override
  State<_OtpFlowDialog> createState() => _OtpFlowDialogState();
}

class _OtpFlowDialogState extends State<_OtpFlowDialog> with SingleTickerProviderStateMixin {
  _DialogStep _step = _DialogStep.weightConfirm;
  bool _isLoading = false;

  final _weightController = TextEditingController();
  final _weightFormKey = GlobalKey<FormState>();

  late AnimationController _anim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _fadeAnim = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _goToStep(_DialogStep next) {
    _anim.reverse().then((_) {
      setState(() => _step = next);
      _anim.forward();
    });
  }

  Future<void> _handleVerify() async {
    if (widget.verificationCodeController.text.length < 4) return;
    try {
      setState(() => _isLoading = true);
      final success = await widget.onVerify();
      if (!success) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleWeightUpdate() async {
    if (!(_weightFormKey.currentState?.validate() ?? false)) return;
    final newWeight = double.tryParse(_weightController.text) ?? 0;
    try {
      setState(() => _isLoading = true);
      final success = await widget.onRequestWeightUpdate(newWeight);
      if (!success) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 40, offset: const Offset(0, 16))],
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildStepIndicator(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero).animate(anim),
                    child: child,
                  ),
                ),
                child: _buildStepBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = [('Weight', Icons.scale_rounded), ('OTP', Icons.lock_open_rounded)];
    int activeIndex;
    if (widget.isWeightConfirmed) {
      activeIndex = 1;
    } else {
      activeIndex = _step == _DialogStep.weightConfirm ? 0 : 1;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _StepDot(
              icon: steps[i].$2,
              label: steps[i].$1,
              isActive: i == activeIndex,
              isDone: widget.isWeightConfirmed ? i <= activeIndex : i < activeIndex,
              isWeightConfirmed: widget.isWeightConfirmed && i == 0,
            ),
            if (i < steps.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(color: (widget.isWeightConfirmed || activeIndex > i) ? Constants.instance.primary : _kSlate200, borderRadius: BorderRadius.circular(2)),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepBody() {
    switch (_step) {
      case _DialogStep.weightConfirm:
        return _WeightConfirmStep(
          key: const ValueKey('weight'),
          bookedWeight: widget.bookedWeight,
          onAccept: () {
            _goToStep(_DialogStep.otpEntry);
          },
          onNotAcceptable: (!widget.isWeightConfirmed && widget.allowWeightUpdate) ? () => _goToStep(_DialogStep.weightUpdate) : null,
          isWeightConfirmed: widget.isWeightConfirmed,
        );
      case _DialogStep.otpEntry:
        return _OtpStep(
          key: const ValueKey('otp'),
          controller: widget.verificationCodeController,
          isLoading: _isLoading,
          onVerify: _handleVerify,
          onBack: widget.isWeightConfirmed ? null : () => _goToStep(_DialogStep.weightConfirm),
          isWeightConfirmed: widget.isWeightConfirmed,
        );
      case _DialogStep.weightUpdate:
        return _WeightUpdateStep(
          key: const ValueKey('weightUpdate'),
          bookedWeight: widget.bookedWeight,
          weightController: _weightController,
          formKey: _weightFormKey,
          isLoading: _isLoading,
          onSubmit: _handleWeightUpdate,
          onBack: () => _goToStep(_DialogStep.weightConfirm),
        );
    }
  }
}

enum _DialogStep { weightConfirm, otpEntry, weightUpdate }

class _StepDot extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDone;
  final bool isWeightConfirmed;

  const _StepDot({required this.icon, required this.label, required this.isActive, required this.isDone, this.isWeightConfirmed = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDone || isWeightConfirmed
                ? Constants.instance.primary
                : isActive
                ? Constants.instance.primary.withOpacity(0.12)
                : _kSlate100,
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? Constants.instance.primary : Colors.transparent, width: 2),
          ),
          child: Icon(
            (isDone || isWeightConfirmed) ? Icons.check_rounded : icon,
            size: 18,
            color: (isDone || isWeightConfirmed)
                ? Colors.white
                : isActive
                ? Constants.instance.primary
                : _kSlate400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: (isActive || isWeightConfirmed) ? Constants.instance.primary : _kSlate400),
        ),
      ],
    );
  }
}

class _WeightConfirmStep extends StatelessWidget {
  final double bookedWeight;
  final VoidCallback onAccept;
  final VoidCallback? onNotAcceptable;
  final bool isWeightConfirmed;

  const _WeightConfirmStep({super.key, required this.bookedWeight, required this.onAccept, this.onNotAcceptable, this.isWeightConfirmed = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  isWeightConfirmed ? 'Weight Confirmed ✓' : 'Confirm Luggage Weight',
                  style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: _kSlate900),
                ),
              ),
              if (isWeightConfirmed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _kGreenBg, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    'Accepted',
                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: _kGreen),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isWeightConfirmed ? 'Passenger has accepted the weight. You can proceed with OTP verification.' : 'Check the actual weight before starting the job.',
            style: GoogleFonts.poppins(fontSize: 12, color: _kSlate400),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: isWeightConfirmed ? _kGreenBg : _kSlate50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isWeightConfirmed ? _kGreen.withOpacity(0.3) : _kSlate200),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(color: isWeightConfirmed ? _kGreen.withOpacity(0.1) : Constants.instance.primary.withOpacity(.1), borderRadius: BorderRadius.circular(16)),
                  child: Icon(isWeightConfirmed ? Icons.check_circle_rounded : Icons.scale_rounded, color: isWeightConfirmed ? _kGreen : Constants.instance.primary, size: 28),
                ),
                const SizedBox(height: 12),
                Text(isWeightConfirmed ? 'Confirmed Weight' : 'Booked Weight', style: GoogleFonts.poppins(fontSize: 12, color: isWeightConfirmed ? _kGreen : _kSlate400)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      bookedWeight.toStringAsFixed(0),
                      style: GoogleFonts.poppins(fontSize: 42, fontWeight: FontWeight.w800, color: isWeightConfirmed ? _kGreen : _kSlate900, height: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6, left: 4),
                      child: Text(
                        'kg',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: isWeightConfirmed ? _kGreen : _kSlate400),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (!isWeightConfirmed)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _kAmberBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: _kAmber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      onNotAcceptable != null
                          ? 'If actual weight differs from booked weight, tap "Not Acceptable" to request an update.'
                          : 'Weight has been confirmed by passenger. Proceed with OTP verification.',
                      style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF92400E), height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (onNotAcceptable != null && !isWeightConfirmed) ...[
                Expanded(
                  child: _OutlineButton(label: 'Not Acceptable', icon: Icons.close_rounded, color: _kRed, bgColor: _kRedBg, onTap: onNotAcceptable!),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: _FilledButton(
                  label: isWeightConfirmed ? 'Continue to OTP' : 'Confirm',
                  icon: isWeightConfirmed ? Icons.arrow_forward_rounded : Icons.check_rounded,
                  color: isWeightConfirmed ? Constants.instance.primary : _kGreen,
                  onTap: onAccept,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OtpStep extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onVerify;
  final VoidCallback? onBack;
  final bool isWeightConfirmed;

  const _OtpStep({super.key, required this.controller, required this.isLoading, required this.onVerify, this.onBack, this.isWeightConfirmed = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (onBack != null)
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(color: _kSlate100, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: _kSlate600),
                  ),
                ),
              if (onBack != null) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter Passenger OTP',
                      style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: _kSlate900),
                    ),
                    Text('Ask passenger for the 4-digit code', style: GoogleFonts.poppins(fontSize: 11, color: _kSlate400)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: Constants.instance.primary.withOpacity(0.10), borderRadius: BorderRadius.circular(20)),
              child: Icon(Icons.lock_open_rounded, size: 32, color: Constants.instance.primary),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: MaterialPinField(
              length: 4,
              onChanged: (value) {
                controller.text = value;
              },
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enableHapticFeedback: true,
              hapticFeedbackType: HapticFeedbackType.selection,
              theme: MaterialPinTheme(
                cellSize: const Size(56, 56),
                shape: MaterialPinShape.filled,
                borderRadius: BorderRadius.circular(12),
                borderWidth: 2,
                cursorHeight: 25,
                focusedFillColor: Constants.instance.primary.withOpacity(0.05),
                filledFillColor: Constants.instance.primary.withOpacity(0.1),
              ),
              autoFocus: true,
            ),
          ),
          const SizedBox(height: 28),
          _FilledButton(label: 'Verify & Start Job', icon: Icons.verified_rounded, color: Constants.instance.primary, isLoading: isLoading, fullWidth: true, height: 54, onTap: onVerify),
        ],
      ),
    );
  }
}

class _WeightUpdateStep extends StatelessWidget {
  final double bookedWeight;
  final TextEditingController weightController;
  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const _WeightUpdateStep({super.key, required this.bookedWeight, required this.weightController, required this.formKey, required this.isLoading, required this.onSubmit, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: _kSlate100, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: _kSlate600),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Request Weight Update',
                    style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: _kSlate900),
                  ),
                  Text('Enter the actual weight you measured', style: GoogleFonts.poppins(fontSize: 11, color: _kSlate400)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _kRedBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kRed.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cancel_outlined, size: 14, color: _kRed),
                    const SizedBox(width: 6),
                    Text(
                      'Booked: ${bookedWeight.toStringAsFixed(0)} kg',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: _kRed),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_rounded, size: 16, color: _kSlate400),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _kGreenBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kGreen.withOpacity(0.25)),
                  ),
                  child: Text(
                    'Actual weight',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: _kGreen),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Form(
            key: formKey,
            child: TextFormField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d?'))],
              style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: _kSlate900),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: _kSlate200),
                suffixText: 'kg',
                suffixStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: _kSlate400),
                filled: true,
                fillColor: _kSlate50,
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _kSlate200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _kSlate200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Constants.instance.primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _kRed),
                ),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Enter actual weight';
                final w = double.tryParse(val);
                if (w == null || w <= 0) return 'Enter a valid weight';
                if (w == bookedWeight) return 'Same as booked weight — no update needed';
                return null;
              },
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kAmberBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 15, color: _kAmber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'A weight update request will be sent to the passenger for approval before you can proceed.',
                    style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF92400E), height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _FilledButton(label: 'Send Update Request', icon: Icons.send_rounded, color: Constants.instance.primary, isLoading: isLoading, fullWidth: true, height: 54, onTap: onSubmit),
        ],
      ),
    );
  }
}

class _FilledButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final bool fullWidth;
  final double height;
  final VoidCallback onTap;

  const _FilledButton({required this.label, required this.icon, required this.color, required this.onTap, this.isLoading = false, this.fullWidth = false, this.height = 48});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: height,
        width: fullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          color: isLoading ? color.withOpacity(0.6) : color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: color.withOpacity(0.30), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _OutlineButton({required this.label, required this.icon, required this.color, required this.bgColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
