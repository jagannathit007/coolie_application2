import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:license_sahayak/repositories/authentication_repo.dart';

class _DS {
  static const Color primary = Color(0xFFC60000);
  static const Color primaryMuted = Color(0x12C60000);
  static const Color primaryBorder = Color(0x33C60000);
  static const Color bg = Color(0xFFF4F5F7);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFEEF0F4);
  static const Color labelPrimary = Color(0xFF0F172A);
  static const Color labelSecond = Color(0xFF475569);
  static const Color labelMuted = Color(0xFF94A3B8);
  static const Color labelHint = Color(0xFFCBD5E1);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberEmpty = Color(0xFFE2E8F0);
  static const double radius = 16;
  static const double radiusSm = 10;
  static const double radiusPill = 50;

  static TextStyle text(double size, FontWeight w, Color c) => GoogleFonts.dmSans(fontSize: size, fontWeight: w, color: c);
}

class FeedbackSheet extends StatefulWidget {
  const FeedbackSheet({super.key});

  @override
  State<FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<FeedbackSheet> {
  final AuthenticationRepo authRepo = AuthenticationRepo();

  final _msgCtrl = TextEditingController();
  int _rating = 0;
  String _category = 'general';
  bool _submitting = false;

  static const _categories = [
    _Cat('general', 'General', Icons.chat_bubble_outline_rounded),
    _Cat('bug', 'Bug', Icons.bug_report_outlined),
    _Cat('feature', 'Feature', Icons.lightbulb_outline_rounded),
    _Cat('improvement', 'Improvement', Icons.trending_up_rounded),
    _Cat('other', 'Other', Icons.more_horiz_rounded),
  ];

  static const _ratingLabels = ['', 'Poor', 'Fair', 'Good', 'Great', 'Excellent'];

  bool get _canSubmit => !_submitting && _rating > 0 && _msgCtrl.text.trim().isNotEmpty;

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: _DS.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 6),
            width: 36,
            height: 4,
            decoration: BoxDecoration(color: _DS.border, borderRadius: BorderRadius.circular(2)),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SheetHeader(),
                  const SizedBox(height: 24),
                  _SectionLabel(label: 'Rate your experience'),
                  const SizedBox(height: 12),
                  _StarRating(rating: _rating, label: _ratingLabels[_rating], onRate: (r) => setState(() => _rating = r)),
                  const SizedBox(height: 22),
                  _SectionLabel(label: 'Category'),
                  const SizedBox(height: 10),
                  _CategoryChips(categories: _categories, selected: _category, onSelect: (v) => setState(() => _category = v)),
                  const SizedBox(height: 22),
                  _SectionLabel(label: 'Your message'),
                  const SizedBox(height: 10),
                  _MessageField(controller: _msgCtrl, onChanged: (_) => setState(() {})),
                  const SizedBox(height: 24),
                  _SubmitButton(enabled: _canSubmit, submitting: _submitting, onTap: _submit),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await authRepo.submitFeedback({"app": "license sahayak", "message": _msgCtrl.text, "rating": _rating, "category": _category});
    if (mounted) {
      setState(() => _submitting = false);
      Navigator.of(context).pop();
    }
  }
}

class _SheetHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: _DS.primaryMuted, borderRadius: BorderRadius.circular(_DS.radiusSm)),
          child: const Icon(Icons.rate_review_outlined, size: 20, color: _DS.primary),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send Feedback', style: _DS.text(17, FontWeight.w700, _DS.labelPrimary)),
            Text('Help us improve your experience', style: _DS.text(12, FontWeight.w400, _DS.labelMuted)),
          ],
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: _DS.text(13, FontWeight.w600, _DS.labelSecond));
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating, required this.label, required this.onRate});

  final int rating;
  final String label;
  final ValueChanged<int> onRate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _DS.bg,
        borderRadius: BorderRadius.circular(_DS.radius),
        border: Border.all(color: _DS.border, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < rating;
              return GestureDetector(
                onTap: () => onRate(i + 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(filled ? Icons.star_rounded : Icons.star_outline_rounded, size: 38, color: filled ? _DS.amber : _DS.amberEmpty),
                ),
              );
            }),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Text(label, key: ValueKey(label), style: _DS.text(13, FontWeight.w600, _DS.amber)),
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.categories, required this.selected, required this.onSelect});

  final List<_Cat> categories;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected = selected == cat.value;
        return GestureDetector(
          onTap: () => onSelect(cat.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? _DS.primaryMuted : _DS.bg,
              borderRadius: BorderRadius.circular(_DS.radiusPill),
              border: Border.all(color: isSelected ? _DS.primaryBorder : _DS.border, width: isSelected ? 1.2 : 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(cat.icon, size: 14, color: isSelected ? _DS.primary : _DS.labelMuted),
                const SizedBox(width: 6),
                Text(cat.label, style: _DS.text(12.5, isSelected ? FontWeight.w600 : FontWeight.w400, isSelected ? _DS.primary : _DS.labelMuted)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MessageField extends StatelessWidget {
  const _MessageField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: 4,
      maxLength: 500,
      style: _DS.text(13.5, FontWeight.w400, _DS.labelPrimary),
      decoration: InputDecoration(
        hintText: 'Share your thoughts with us…',
        hintStyle: _DS.text(13.5, FontWeight.w400, _DS.labelHint),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: _DS.bg,
        isDense: true,
        counterStyle: _DS.text(10.5, FontWeight.w400, _DS.labelMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_DS.radius),
          borderSide: const BorderSide(color: _DS.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_DS.radius),
          borderSide: const BorderSide(color: _DS.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_DS.radius),
          borderSide: const BorderSide(color: _DS.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.enabled, required this.submitting, required this.onTap});

  final bool enabled, submitting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _DS.primary,
          disabledBackgroundColor: _DS.labelMuted,
          disabledForegroundColor: _DS.labelMuted,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_DS.radius)),
        ),
        child: submitting
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Submit Feedback', style: _DS.text(14.5, FontWeight.w700, Colors.white)),
                ],
              ),
      ),
    );
  }
}

class _Cat {
  final String value, label;
  final IconData icon;

  const _Cat(this.value, this.label, this.icon);
}
