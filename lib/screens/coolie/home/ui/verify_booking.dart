import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:license_sahayak/models/get_passenger_coolie_model.dart';
import 'package:license_sahayak/utils/app_constants.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

const _kSlate50 = Color(0xFFF8FAFC);
const _kSlate100 = Color(0xFFF1F5F9);
const _kSlate200 = Color(0xFFE2E8F0);
const _kSlate400 = Color(0xFF94A3B8);
const _kSlate600 = Color(0xFF475569);
const _kSlate900 = Color(0xFF0F172A);
const _kGreen = Color(0xFF10B981);
const _kGreenDark = Color(0xFF059669);
const _kGreenBg = Color(0xFFD1FAE5);
const _kRed = Color(0xFFEF4444);
const _kRedBg = Color(0xFFFEE2E2);
const _kAmber = Color(0xFFF59E0B);
const _kAmberBg = Color(0xFFFEF3C7);
const _kBlue = Color(0xFF3B82F6);
const _kBlueBg = Color(0xFFDBEAFE);

void otpDialog({
  required TextEditingController verificationCodeController,
  required PickupDetails pickupDetails,
  required Map<String, dynamic> rateCard,
  required Future<bool> Function() onVerify,
  required Future<bool> Function(Map<String, dynamic> updateData) onRequestUpdate,
  bool allowUpdate = true,
  bool isConfirmed = false,
}) {
  Get.dialog(
    barrierDismissible: false,
    _OtpFlowDialog(
      verificationCodeController: verificationCodeController,
      rateCard: rateCard,
      pickupDetails: pickupDetails,
      onVerify: onVerify,
      onRequestUpdate: onRequestUpdate,
      allowUpdate: allowUpdate,
      isConfirmed: isConfirmed,
    ),
  );
}

class _OtpFlowDialog extends StatefulWidget {
  final TextEditingController verificationCodeController;
  final Map<String, dynamic> rateCard;
  final PickupDetails pickupDetails;
  final Future<bool> Function() onVerify;
  final Future<bool> Function(Map<String, dynamic> updateData) onRequestUpdate;
  final bool allowUpdate;
  final bool isConfirmed;

  const _OtpFlowDialog({
    required this.verificationCodeController,
    required this.rateCard,
    required this.pickupDetails,
    required this.onVerify,
    required this.onRequestUpdate,
    required this.allowUpdate,
    required this.isConfirmed,
  });

  @override
  State<_OtpFlowDialog> createState() => _OtpFlowDialogState();
}

class _OtpFlowDialogState extends State<_OtpFlowDialog> with SingleTickerProviderStateMixin {
  _DialogStep _step = _DialogStep.detailsConfirm;
  bool _isLoading = false;

  String? _selectedCarryType, _weightError;
  bool _isWheeledChair = false;
  int _luggageCount = 0;

  late AnimationController _anim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _selectedCarryType = _getCarryTypeValue(widget.pickupDetails.carryType?.toString() ?? 'head_load');
    _isWheeledChair = widget.pickupDetails.isWheeledChair == true;
    _luggageCount = widget.pickupDetails.luggageCount ?? 0;
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _fadeAnim = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  String _getCarryTypeValue(String carryType) {
    switch (carryType) {
      case 'wheeled_barrow':
        return 'wheeledBarrow';
      case 'head_load':
      default:
        return 'headLoad';
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _goToStep(_DialogStep next) {
    _anim.reverse().then((_) {
      setState(() => _step = next);
      _anim.forward();
    });
  }

  void _validateWeight(int count) {
    if (_selectedCarryType == 'headLoad' && count > 0) {
      final threshold = int.tryParse(widget.rateCard['carryTypeThresholdKg']?.toString() ?? '') ?? 40;
      final estimatedKg = count * 20;
      if (estimatedKg > threshold) {
        _weightError = 'Est. weight (${estimatedKg}kg) exceeds ${threshold}kg. Switch to Wheeled Barrow.';
      } else {
        _weightError = null;
      }
    } else {
      _weightError = null;
    }
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

  Future<void> _handleUpdateRequest() async {
    _validateWeight(_luggageCount);
    if (_weightError != null) {
      return;
    }
    final updateData = {
      "carryType": _selectedCarryType == 'headLoad'
          ? "head_load"
          : _selectedCarryType == 'wheeledBarrow'
          ? 'wheeled_barrow'
          : _selectedCarryType,
      'isWheeledChair': _isWheeledChair,
      if (_selectedCarryType == 'headLoad') 'luggageCount': _luggageCount,
    };
    try {
      setState(() => _isLoading = true);
      final success = await widget.onRequestUpdate(updateData);
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 32, offset: const Offset(0, 8)),
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildStepIndicator(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero).animate(anim),
                      child: child,
                    ),
                  ),
                  child: _buildStepBody(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        children: [
          Row(
            children: [
              _StepItem(stepNumber: 1, label: 'Details', isActive: _step == _DialogStep.detailsConfirm && !widget.isConfirmed, isCompleted: widget.isConfirmed || _step == _DialogStep.otpEntry),
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(color: (widget.isConfirmed || _step == _DialogStep.otpEntry) ? Constants.instance.primary : _kSlate200, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              _StepItem(stepNumber: 2, label: 'Verify', isActive: _step == _DialogStep.otpEntry || widget.isConfirmed, isCompleted: false),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStepBody() {
    switch (_step) {
      case _DialogStep.detailsConfirm:
        return _DetailsConfirmStep(
          key: const ValueKey('details'),
          rateCard: widget.rateCard,
          pickupDetails: widget.pickupDetails,
          onConfirm: () {
            _goToStep(_DialogStep.otpEntry);
          },
          onRequest: (!widget.isConfirmed && widget.allowUpdate) ? () => _goToStep(_DialogStep.detailsUpdate) : null,
          isConfirmed: widget.isConfirmed,
        );
      case _DialogStep.otpEntry:
        return _OtpStep(
          key: const ValueKey('otp'),
          controller: widget.verificationCodeController,
          isLoading: _isLoading,
          onVerify: _handleVerify,
          onBack: () => _goToStep(_DialogStep.detailsConfirm),
          isConfirmed: widget.isConfirmed,
        );
      case _DialogStep.detailsUpdate:
        final threshold = int.tryParse(widget.rateCard['carryTypeThresholdKg']?.toString() ?? '') ?? 40;
        return _DetailsUpdateStep(
          key: const ValueKey('detailsUpdate'),
          selectedCarryType: _selectedCarryType,
          threshold: threshold,
          isWheeledChair: _isWheeledChair,
          luggageCount: _luggageCount,
          isLoading: _isLoading,
          weightError: _weightError,
          onCarryTypeChanged: (val) {
            setState(() {
              _selectedCarryType = val;
              _validateWeight(_luggageCount);
            });
          },
          onWheeledChairChanged: (val) {
            setState(() => _isWheeledChair = val);
          },
          onLuggageCountChanged: (val) {
            setState(() {
              _luggageCount = val;
              _validateWeight(val);
            });
          },
          onSubmit: _handleUpdateRequest,
          onBack: () => _goToStep(_DialogStep.detailsConfirm),
        );
    }
  }
}

enum _DialogStep { detailsConfirm, otpEntry, detailsUpdate }

class _StepItem extends StatelessWidget {
  final int stepNumber;
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepItem({required this.stepNumber, required this.label, required this.isActive, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final primary = Constants.instance.primary;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? primary
                : isActive
                ? primary.withOpacity(0.12)
                : _kSlate100,
            border: isActive && !isCompleted ? Border.all(color: primary, width: 2) : null,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                : Text(
                    '$stepNumber',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isActive ? primary : _kSlate400),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, fontWeight: isActive || isCompleted ? FontWeight.w600 : FontWeight.w500, color: isActive || isCompleted ? _kSlate600 : _kSlate400),
        ),
      ],
    );
  }
}

class _DetailsConfirmStep extends StatelessWidget {
  final PickupDetails pickupDetails;
  final Map<String, dynamic> rateCard;
  final VoidCallback onConfirm;
  final VoidCallback? onRequest;
  final bool isConfirmed;

  const _DetailsConfirmStep({super.key, required this.pickupDetails, required this.rateCard, required this.onConfirm, this.onRequest, this.isConfirmed = false});

  String _formatCarryType(String? raw) {
    switch (raw) {
      case 'wheeled_barrow':
        return 'Wheeled Barrow';
      case 'head_load':
      default:
        return 'Head Load';
    }
  }

  bool get _hasChanges {
    final carryChanged = pickupDetails.originalCarryType != null && pickupDetails.originalCarryType != pickupDetails.carryType;
    final luggageChanged = pickupDetails.originalLuggageCount != null && pickupDetails.originalLuggageCount != pickupDetails.luggageCount;
    final chairChanged = pickupDetails.originalIsWheeledChair != null && pickupDetails.originalIsWheeledChair != pickupDetails.isWheeledChair;
    return carryChanged || luggageChanged || chairChanged;
  }

  bool get _isUpdateApproved => pickupDetails.luggageStatus == 'approved';

  @override
  Widget build(BuildContext context) {
    final primary = Constants.instance.primary;
    final carryType = _formatCarryType(pickupDetails.carryType);
    final originalCarryType = _formatCarryType(pickupDetails.originalCarryType);
    final isWheeledChair = pickupDetails.isWheeledChair == true;
    final luggageCount = pickupDetails.luggageCount ?? 0;
    final hasChanges = _hasChanges;
    final threshold = int.tryParse(rateCard['carryTypeThresholdKg']?.toString() ?? '') ?? 40;
    final exceedsThreshold = luggageCount > 0 && (luggageCount * 20) > threshold;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isConfirmed ? 'Booking Confirmed' : 'Review Booking',
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: _kSlate900, letterSpacing: -0.3),
                    ),
                    const SizedBox(height: 4),
                    Text(isConfirmed ? 'Details verified by passenger' : 'Please verify the service details', style: GoogleFonts.inter(fontSize: 13, color: _kSlate400)),
                  ],
                ),
              ),
              if (isConfirmed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: _kGreenBg, borderRadius: BorderRadius.circular(100)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 14, color: _kGreenDark),
                      const SizedBox(width: 4),
                      Text(
                        'Confirmed',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: _kGreenDark),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isUpdateApproved && hasChanges)
            _InfoBanner(icon: Icons.check_circle_outline_rounded, color: _kGreen, bgColor: _kGreenBg, borderColor: _kGreen.withOpacity(0.3), message: 'Passenger approved the updated details.'),
          if (exceedsThreshold && !isConfirmed)
            _InfoBanner(
              icon: Icons.warning_amber_rounded,
              color: _kRed,
              bgColor: _kRedBg,
              borderColor: _kRed.withOpacity(0.3),
              message: 'Est. weight (${luggageCount * 20}kg) exceeds ${threshold}kg limit for Head Load. Please request update to switch to Wheeled Barrow.',
            ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: exceedsThreshold ? _kRed.withOpacity(0.3) : (isConfirmed ? _kGreen.withOpacity(0.2) : _kSlate200), width: exceedsThreshold ? 1.0 : .6),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: exceedsThreshold ? _kRedBg : (isConfirmed ? _kGreen.withOpacity(0.1) : primary.withOpacity(0.1)),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        exceedsThreshold ? Icons.warning_amber_rounded : (isConfirmed ? Icons.check_circle_rounded : Icons.luggage_rounded),
                        color: exceedsThreshold ? _kRed : (isConfirmed ? _kGreen : primary),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        exceedsThreshold ? 'Weight Limit Exceeded' : (isConfirmed ? 'Confirmed Details' : 'Booking Details'),
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: exceedsThreshold ? _kRed : (isConfirmed ? _kGreen : primary)),
                      ),
                      if (hasChanges && !exceedsThreshold) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _kAmberBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Text(
                            'Modified',
                            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: _kAmber),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      _DetailRowV2(
                        icon: Icons.local_shipping_outlined,
                        label: 'Carry Type',
                        value: carryType,
                        originalValue: (hasChanges && pickupDetails.originalCarryType != pickupDetails.carryType) ? originalCarryType : null,
                        isConfirmed: isConfirmed,
                        isWarning: exceedsThreshold && carryType == 'Head Load',
                      ),
                      if (isWheeledChair || pickupDetails.originalIsWheeledChair == true) ...[
                        const _Divider(),
                        _DetailRowV2(
                          icon: Icons.wheelchair_pickup_rounded,
                          label: 'Wheeled Chair',
                          value: isWheeledChair ? 'Required' : 'Not Required',
                          originalValue: (pickupDetails.originalIsWheeledChair != null && pickupDetails.originalIsWheeledChair != pickupDetails.isWheeledChair)
                              ? (pickupDetails.originalIsWheeledChair == true ? 'Required' : 'Not Required')
                              : null,
                          isConfirmed: isConfirmed,
                        ),
                      ],
                      if (carryType == 'Head Load') ...[
                        const _Divider(),
                        _DetailRowV2(
                          icon: Icons.shopping_bag_outlined,
                          label: 'Number of Bags',
                          value: '$luggageCount bag${luggageCount != 1 ? 's' : ''}',
                          originalValue: (pickupDetails.originalLuggageCount != null && pickupDetails.originalLuggageCount != luggageCount)
                              ? '${pickupDetails.originalLuggageCount} bag${(pickupDetails.originalLuggageCount ?? 0) != 1 ? 's' : ''}'
                              : null,
                          isConfirmed: isConfirmed,
                          isWarning: exceedsThreshold,
                        ),
                        if (luggageCount > 0) ...[
                          const _Divider(),
                          _DetailRowV2(
                            icon: Icons.scale_outlined,
                            label: 'Est. Weight',
                            value: '${luggageCount * 20} kg',
                            isConfirmed: isConfirmed,
                            isSubtle: true,
                            isWarning: exceedsThreshold,
                            caption: exceedsThreshold ? 'Exceeds ${threshold}kg limit' : null,
                          ),
                        ],
                      ],
                      if (pickupDetails.luggageStatus != null) ...[
                        const _Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded, size: 16, color: _kSlate400),
                              const SizedBox(width: 10),
                              Text(
                                'Update Status',
                                style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w500, color: _kSlate600),
                              ),
                              const Spacer(),
                              _LuggageStatusChip(status: pickupDetails.luggageStatus!),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (!isConfirmed)
            _InfoBanner(
              icon: Icons.info_outline_rounded,
              color: _kBlue,
              bgColor: _kBlueBg,
              borderColor: _kBlue.withOpacity(0.2),
              message: onRequest != null ? 'Details incorrect? Tap "Request" to modify carry type, bags, or wheeled chair.' : 'Details confirmed by passenger. Proceed with OTP verification.',
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (onRequest != null && !isConfirmed)
                Expanded(
                  child: _ActionButton(label: 'Request', icon: Icons.edit_outlined, isPrimary: false, onTap: onRequest!),
                ),
              if (onRequest != null && !isConfirmed) const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: isConfirmed ? 'Verify OTP' : 'Confirm',
                  icon: isConfirmed ? Icons.arrow_forward_rounded : Icons.check_rounded,
                  isPrimary: true,
                  onTap: () {
                    if (exceedsThreshold && !isConfirmed) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please request update to fix weight issue'), backgroundColor: _kRed));
                    } else {
                      onConfirm();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final Color borderColor;
  final String message;

  const _InfoBanner({required this.icon, required this.color, required this.bgColor, required this.borderColor, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: GoogleFonts.inter(fontSize: 11, color: color, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: Divider(height: 1, color: Color(0xFFE2E8F0)),
  );
}

class _DetailRowV2 extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? originalValue;
  final bool isConfirmed;
  final bool isSubtle;
  final bool isWarning;
  final String? caption;

  const _DetailRowV2({required this.icon, required this.label, required this.value, this.originalValue, this.isConfirmed = false, this.isSubtle = false, this.isWarning = false, this.caption});

  @override
  Widget build(BuildContext context) {
    final bool wasChanged = originalValue != null;
    final Color iconColor = isWarning ? _kRed : (isSubtle ? _kSlate400 : _kSlate400);
    final Color labelColor = isWarning ? _kRed : (isSubtle ? _kSlate400 : _kSlate600);
    final Color valueColor = isWarning ? _kRed : (isSubtle ? _kSlate400 : _kSlate900);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 17, color: iconColor),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w500, color: labelColor),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: wasChanged ? _kAmber : valueColor),
                  ),
                  if (wasChanged)
                    Text(
                      originalValue!,
                      style: GoogleFonts.inter(fontSize: 11, color: _kSlate400, decoration: TextDecoration.lineThrough, decorationColor: _kSlate400),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (caption != null)
          Padding(
            padding: const EdgeInsets.only(left: 43, top: 2),
            child: Text(caption!, style: GoogleFonts.inter(fontSize: 10, color: _kRed)),
          ),
      ],
    );
  }
}

class _LuggageStatusChip extends StatelessWidget {
  final String status;

  const _LuggageStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color bg;
    IconData icon;
    String label;
    switch (status.toLowerCase()) {
      case 'approved':
        color = _kGreen;
        bg = _kGreenBg;
        icon = Icons.check_circle_rounded;
        label = 'Approved';
        break;
      case 'pending':
        color = _kAmber;
        bg = _kAmberBg;
        icon = Icons.pending_rounded;
        label = 'Pending';
        break;
      case 'rejected':
        color = _kRed;
        bg = _kRedBg;
        icon = Icons.cancel_rounded;
        label = 'Rejected';
        break;
      default:
        color = _kSlate400;
        bg = _kSlate100;
        icon = Icons.circle_outlined;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class _DetailsUpdateStep extends StatelessWidget {
  final String? selectedCarryType;
  final int threshold;
  final bool isWheeledChair;
  final int luggageCount;
  final bool isLoading;
  final String? weightError;
  final ValueChanged<String> onCarryTypeChanged;
  final ValueChanged<bool> onWheeledChairChanged;
  final ValueChanged<int> onLuggageCountChanged;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const _DetailsUpdateStep({
    super.key,
    required this.selectedCarryType,
    required this.threshold,
    required this.isWheeledChair,
    required this.luggageCount,
    required this.isLoading,
    this.weightError,
    required this.onCarryTypeChanged,
    required this.onWheeledChairChanged,
    required this.onLuggageCountChanged,
    required this.onSubmit,
    required this.onBack,
  });

  int get _estimatedKg => luggageCount * 20;

  @override
  Widget build(BuildContext context) {
    final primary = Constants.instance.primary;
    final exceedsThreshold = luggageCount > 0 && _estimatedKg > threshold;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: _kSlate100, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: _kSlate600),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request Update',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: _kSlate900, letterSpacing: -0.3),
                    ),
                    Text('Modify service details', style: GoogleFonts.inter(fontSize: 12, color: _kSlate400)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionLabel(label: 'Carry Type', icon: Icons.local_shipping_outlined),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: _kSlate50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kSlate200),
            ),
            child: Row(
              children: [
                _CarryTypeBtn(label: 'Head Load', value: 'headLoad', selected: selectedCarryType == 'headLoad', onTap: () => onCarryTypeChanged('headLoad')),
                _CarryTypeBtn(label: 'Wheeled Barrow', value: 'wheeledBarrow', selected: selectedCarryType == 'wheeledBarrow', onTap: () => onCarryTypeChanged('wheeledBarrow')),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel(label: 'Wheeled Chair', icon: Icons.wheelchair_pickup),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => onWheeledChairChanged(!isWheeledChair),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isWheeledChair ? primary.withOpacity(0.05) : _kSlate50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isWheeledChair ? primary : _kSlate200, width: 1.0),
              ),
              child: Row(
                children: [
                  Text('♿', style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wheeled Chair Service',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _kSlate900),
                        ),
                        Text(isWheeledChair ? 'Included in service' : 'Add if passenger needs assistance', style: GoogleFonts.inter(fontSize: 11, color: isWheeledChair ? primary : _kSlate400)),
                      ],
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 28,
                    decoration: BoxDecoration(color: isWheeledChair ? primary : _kSlate200, borderRadius: BorderRadius.circular(14)),
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          left: isWheeledChair ? 22 : 2,
                          top: 2,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: Icon(Icons.check_rounded, size: 14, color: isWheeledChair ? primary : _kSlate400),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (selectedCarryType == 'headLoad') ...[
            _SectionLabel(label: 'Luggage Count', icon: Icons.shopping_bag_outlined),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _kSlate50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: weightError != null ? _kRed : _kSlate200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Number of Bags',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: _kSlate600),
                      ),
                      if (luggageCount > 0) Text('Est. weight: $_estimatedKg kg', style: GoogleFonts.inter(fontSize: 11, color: exceedsThreshold ? _kRed : _kSlate400)),
                    ],
                  ),
                  _CountStepper(
                    value: luggageCount,
                    onDecrement: luggageCount > 0 ? () => onLuggageCountChanged(luggageCount - 1) : null,
                    onIncrement: () => onLuggageCountChanged(luggageCount + 1),
                    onDirectEdit: onLuggageCountChanged,
                  ),
                ],
              ),
            ),
            if (weightError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, size: 12, color: _kRed),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(weightError!, style: GoogleFonts.inter(fontSize: 11, color: _kRed)),
                    ),
                  ],
                ),
              ),
            if (exceedsThreshold && weightError == null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _kRedBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kRed.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: _kRed),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Estimated weight ($_estimatedKg kg) exceeds 40kg limit for Head Load. Please switch to Wheeled Barrow.',
                        style: GoogleFonts.inter(fontSize: 11, color: _kRed, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => onCarryTypeChanged('wheeledBarrow'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Text(
                      '🛒  Switch to Wheeled Barrow',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _kAmberBg, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 16, color: _kAmber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Update request will be sent to passenger for approval before proceeding.', style: GoogleFonts.inter(fontSize: 11, color: _kAmber, height: 1.4)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: (isLoading || weightError != null) ? null : onSubmit,
            child: Container(
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                color: (isLoading || weightError != null) ? primary.withOpacity(0.5) : primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: (isLoading || weightError != null) ? [] : [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: isLoading
                  ? const Center(
                      child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          weightError != null ? 'Fix Weight Issue First' : 'Send Update Request',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _kSlate400),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: _kSlate600, letterSpacing: 0.3),
        ),
      ],
    );
  }
}

class _CarryTypeBtn extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _CarryTypeBtn({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Constants.instance.primary;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: selected ? primary : Colors.transparent, borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : _kSlate600),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.icon, required this.isPrimary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Constants.instance.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isPrimary ? primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isPrimary ? null : Border.all(color: _kSlate200, width: 1.0),
          boxShadow: isPrimary ? [BoxShadow(color: primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 2))] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isPrimary ? Colors.white : _kSlate600),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isPrimary ? Colors.white : _kSlate600),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpStep extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onVerify;
  final VoidCallback onBack;
  final bool isConfirmed;

  const _OtpStep({super.key, required this.controller, required this.isLoading, required this.onVerify, required this.onBack, this.isConfirmed = false});

  @override
  Widget build(BuildContext context) {
    final primary = Constants.instance.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: _kSlate100, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: _kSlate600),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter OTP',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: _kSlate900, letterSpacing: -0.3),
                    ),
                    Text('Ask passenger for the 4-digit code', style: GoogleFonts.inter(fontSize: 12, color: _kSlate400)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(24)),
              child: Icon(Icons.lock_open_rounded, size: 32, color: primary),
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
                borderRadius: BorderRadius.circular(14),
                borderWidth: 2,
                cursorHeight: 25,
                focusedFillColor: primary.withOpacity(0.08),
                filledFillColor: primary.withOpacity(0.12),
              ),
              autoFocus: true,
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: isLoading ? null : onVerify,
            child: Container(
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isLoading ? primary.withOpacity(0.6) : primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isLoading ? [] : [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: isLoading
                  ? const Center(
                      child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_rounded, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Verify & Start Job',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountStepper extends StatefulWidget {
  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;
  final ValueChanged<int>? onDirectEdit;

  const _CountStepper({required this.value, required this.onDecrement, required this.onIncrement, this.onDirectEdit});

  @override
  State<_CountStepper> createState() => _CountStepperState();
}

class _CountStepperState extends State<_CountStepper> {
  bool _isEditing = false;
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.value}');
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) _commitEdit();
    });
  }

  @override
  void didUpdateWidget(_CountStepper old) {
    super.didUpdateWidget(old);
    if (!_isEditing) _controller.text = '${widget.value}';
  }

  void _startEdit() {
    setState(() => _isEditing = true);
    _controller.text = widget.value == 0 ? '' : '${widget.value}';
    Future.microtask(() {
      _focusNode.requestFocus();
      _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
    });
  }

  void _commitEdit() {
    final parsed = int.tryParse(_controller.text);
    final newVal = (parsed != null ? parsed.clamp(0, 99) : widget.value);
    widget.onDirectEdit?.call(newVal);
    setState(() => _isEditing = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Constants.instance.primary;
    return Container(
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepBtn(
              onTap: () {
                widget.onDecrement?.call();
                setState(() => _isEditing = false);
              },
              enabled: widget.onDecrement != null,
              bgColor: widget.onDecrement != null ? primary.withOpacity(0.1) : Colors.grey.shade200,
              iconColor: widget.onDecrement != null ? primary : Colors.grey,
              splashColor: primary.withOpacity(0.2),
              icon: Icons.remove_rounded,
            ),
            Container(width: 0.5, height: 36, color: const Color(0xFFE2E8F0)),
            Material(
              color: Colors.white,
              child: InkWell(
                onTap: _isEditing ? null : _startEdit,
                splashColor: Colors.white.withOpacity(0.08),
                highlightColor: Colors.white.withOpacity(0.04),
                child: SizedBox(width: 56, height: 36, child: Center(child: _isEditing ? _buildInput() : _buildText())),
              ),
            ),
            Container(width: 0.5, height: 36, color: const Color(0xFFE2E8F0)),
            _StepBtn(
              onTap: () {
                widget.onIncrement.call();
                setState(() => _isEditing = false);
              },
              enabled: true,
              bgColor: primary,
              iconColor: Colors.white,
              splashColor: Colors.white.withOpacity(0.2),
              icon: Icons.add_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildText() => Text(
    '${widget.value}',
    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: widget.value > 0 ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)),
  );

  Widget _buildInput() => TextField(
    controller: _controller,
    focusNode: _focusNode,
    keyboardType: TextInputType.number,
    textAlign: TextAlign.center,
    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
    decoration: const InputDecoration(
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.zero,
    ),
    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
    onSubmitted: (_) => _commitEdit(),
  );
}

class _StepBtn extends StatelessWidget {
  final VoidCallback? onTap;
  final bool enabled;
  final Color bgColor;
  final Color iconColor;
  final Color splashColor;
  final IconData icon;

  const _StepBtn({required this.onTap, required this.enabled, required this.bgColor, required this.iconColor, required this.splashColor, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      child: InkWell(
        onTap: enabled ? onTap : null,
        splashColor: splashColor,
        highlightColor: splashColor.withOpacity(0.3),
        child: SizedBox(width: 40, height: 36, child: Icon(icon, size: 16, color: iconColor)),
      ),
    );
  }
}
