import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:license_sahayak/screens/coolie/attendance/attendance_service.dart';
import 'package:license_sahayak/utils/app_constants.dart';

class CollieCreation extends StatefulWidget {
  const CollieCreation({super.key});

  @override
  State<CollieCreation> createState() => _CollieCreationState();
}

class _CollieCreationState extends State<CollieCreation> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _service = AttendanceService();

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _buckleController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedGender, _documentFileName;
  String _deviceType = 'SmartPhone';
  File? _profileImage, _documentFile;
  bool _isLoading = false;

  static final Color _primary = Constants.instance.primary;
  static const Color _primaryLight = Color(0xFFFEE8E8);
  static const Color _bgPage = Color(0xFFF4F6FA);
  static const Color _bgCard = Colors.white;
  static const Color _textMain = Color(0xFF111827);
  static const Color _textMuted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _inputBg = Color(0xFFF9FAFB);

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<Map<String, dynamic>> _deviceTypes = [
    {'value': 'SmartPhone', 'label': 'Smartphone', 'icon': Icons.smartphone_outlined},
    {'value': 'Tablet', 'label': 'Tablet', 'icon': Icons.tablet_outlined},
    {'value': 'Other', 'label': 'Other', 'icon': Icons.devices_other_outlined},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _buckleController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      if (await file.length() > 5 * 1024 * 1024) {
        _showSnackBar('Profile image must be under 5 MB', isError: true);
        return;
      }
      setState(() => _profileImage = file);
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx']);
    if (result != null) {
      final file = File(result.files.single.path!);
      if (await file.length() > 10 * 1024 * 1024) {
        _showSnackBar('Document must be under 10 MB', isError: true);
        return;
      }
      setState(() {
        _documentFile = file;
        _documentFileName = result.files.single.name;
      });
    }
  }

  void _removeDocument() => setState(() {
    _documentFile = null;
    _documentFileName = null;
  });

  Future<void> _createCollie() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender == null) {
      _showSnackBar('Please select a gender', isError: true);
      return;
    }
    if (_profileImage == null) {
      _showSnackBar('Please add a profile photo', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final formData = dio.FormData.fromMap({
        'name': _nameController.text.trim(),
        'mobileNo': _mobileController.text.trim(),
        'age': int.parse(_ageController.text.trim()),
        'gender': _selectedGender,
        'buckleNumber': _buckleController.text.trim(),
        'address': _addressController.text.trim(),
        'emailId': _emailController.text.trim(),
        'deviceType': _deviceType,
      });
      formData.files.add(MapEntry('image', await dio.MultipartFile.fromFile(_profileImage!.path, filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg')));
      if (_documentFile != null) {
        final ext = _documentFileName!.split('.').last;
        formData.files.add(MapEntry('document', await dio.MultipartFile.fromFile(_documentFile!.path, filename: 'document_${DateTime.now().millisecondsSinceEpoch}.$ext')));
      }
      final created = await _service.createCollie(formData);
      if (created != null && mounted) {
        _showSnackBar('Collie created successfully!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnackBar('Failed to create: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: GoogleFonts.poppins(fontSize: 13))),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFDC2626) : const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(statusBarColor: _primary, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: _bgPage,
        appBar: _buildAppBar(),
        body: Form(
          key: _formKey,
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildAvatarSection()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildCard(icon: Icons.person_outline_rounded, title: 'Personal details', required: true, child: _buildPersonalFields()),
                        const SizedBox(height: 12),
                        _buildCard(icon: Icons.devices_outlined, title: 'Device type', child: _buildDeviceSection()),
                        const SizedBox(height: 12),
                        _buildCard(icon: Icons.description_outlined, title: 'ID proof document', required: false, child: _documentFile == null ? _buildUploadZone() : _buildDocumentPreview()),
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: Container(
        color: _primary,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      splashRadius: 20,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New registration',
                            style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          Text('Step 1 of 3 — Personal info', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withOpacity(0.7))),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text('45%', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.85))),
                    ),
                  ],
                ),
              ),
              LinearProgressIndicator(value: 0.45, backgroundColor: Colors.white.withOpacity(0.25), valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), minHeight: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Container(
      color: _bgCard,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickProfileImage,
            child: Stack(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _primaryLight,
                    border: Border.all(color: _profileImage != null ? _primary : _primary.withOpacity(0.3), width: 2, style: _profileImage != null ? BorderStyle.solid : BorderStyle.solid),
                    image: _profileImage != null ? DecorationImage(image: FileImage(_profileImage!), fit: BoxFit.cover) : null,
                  ),
                  child: _profileImage == null ? Icon(Icons.person_rounded, size: 40, color: _primary.withOpacity(0.5)) : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: _primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, size: 13, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _profileImage != null ? 'Change photo' : 'Add profile photo',
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: _primary),
          ),
          const SizedBox(height: 2),
          Text('JPG or PNG · max 5 MB', style: GoogleFonts.poppins(fontSize: 11, color: _textMuted)),
        ],
      ),
    );
  }

  Widget _buildCard({required IconData icon, required String title, required Widget child, bool required = true}) {
    return Container(
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(color: _primaryLight, borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, size: 16, color: _primary),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: _textMuted, letterSpacing: 0.3),
                ),
                if (!required)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: _bgPage, borderRadius: BorderRadius.circular(100)),
                      child: Text('Optional', style: GoogleFonts.poppins(fontSize: 10, color: _textMuted)),
                    ),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: _border.withOpacity(0.5)),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildPersonalFields() {
    return Column(
      children: [
        _field(controller: _nameController, label: 'Full name', hint: 'e.g. Ramesh Kumar', icon: Icons.person_outline_rounded, required: true),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _field(
                controller: _mobileController,
                label: 'Mobile',
                maxLength: 10,
                hint: '10-digit number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                required: true,
                validator: (v) {
                  if (v?.isEmpty == true) return 'Required';
                  if (v!.length != 10) return 'Enter 10 digits';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _field(
                controller: _ageController,
                label: 'Age',
                maxLength: 3,
                hint: 'Years',
                icon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
                required: true,
                validator: (v) {
                  if (v?.isEmpty == true) return 'Required';
                  if (int.tryParse(v!) == null) return 'Invalid';
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildGenderToggle(),
        const SizedBox(height: 14),
        _field(
          controller: _emailController,
          label: 'Email address',
          hint: 'collie@example.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          required: true,
          validator: (v) {
            if (v?.isEmpty == true) return 'Required';
            if (!v!.contains('@') || !v.contains('.')) return 'Invalid email';
            return null;
          },
        ),
        const SizedBox(height: 14),
        _field(controller: _buckleController, label: 'Buckle / badge number', hint: 'Unique badge ID', icon: Icons.badge_outlined, required: true),
        const SizedBox(height: 14),
        _field(controller: _addressController, label: 'Residential address', hint: 'Full address with PIN code', icon: Icons.home_outlined, maxLines: 3, required: true),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    bool required = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: _textMuted),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.w600),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator ?? (required ? (v) => v?.isEmpty == true ? '$label is required' : null : null),
          style: GoogleFonts.poppins(fontSize: 13, color: _textMain),
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 13, color: _textMuted.withOpacity(0.5)),
            prefixIcon: Icon(icon, size: 18, color: _primary.withOpacity(0.7)),
            filled: true,
            fillColor: _inputBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _border.withOpacity(0.8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFDC2626)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
            ),
            errorStyle: GoogleFonts.poppins(fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Gender',
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: _textMuted),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: _genders.map((g) {
            final selected = _selectedGender == g;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedGender = g),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: EdgeInsets.only(right: g != _genders.last ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? _primary : _inputBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? _primary : _border, width: selected ? 1.5 : 1),
                  ),
                  child: Text(
                    g,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: selected ? Colors.white : _textMuted),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDeviceSection() {
    return Row(
      children: _deviceTypes.map((d) {
        final selected = _deviceType == d['value'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _deviceType = d['value']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(right: d != _deviceTypes.last ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected ? _primaryLight : _inputBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selected ? _primary : _border, width: selected ? 1.5 : 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(d['icon'] as IconData, size: 22, color: selected ? _primary : _textMuted),
                  const SizedBox(height: 6),
                  Text(
                    d['label'] as String,
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: selected ? _primary : _textMuted),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUploadZone() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickDocument,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: _inputBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border.withOpacity(0.8), width: 1.5, style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Icon(Icons.cloud_upload_outlined, size: 36, color: _primary.withOpacity(0.5)),
                const SizedBox(height: 10),
                Text(
                  'Upload ID proof',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: _textMain),
                ),
                const SizedBox(height: 3),
                Text('PDF, JPG, PNG, DOC · max 10 MB', style: GoogleFonts.poppins(fontSize: 11, color: _textMuted)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(color: _primaryLight, borderRadius: BorderRadius.circular(100)),
                  child: Text(
                    'Browse file',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: _primary),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: ['Aadhaar', 'PAN card', 'Voter ID'].map((label) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _bgPage,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: _border),
              ),
              child: Text(label, style: GoogleFonts.poppins(fontSize: 11, color: _textMuted)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDocumentPreview() {
    final sizeKB = (_documentFile!.lengthSync() / 1024).toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: _primaryLight, borderRadius: BorderRadius.circular(10)),
            child: Icon(_getFileIcon(), size: 22, color: _primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _documentFileName!,
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: _textMain),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text('$sizeKB KB', style: GoogleFonts.poppins(fontSize: 11, color: _textMuted)),
              ],
            ),
          ),
          GestureDetector(
            onTap: _removeDocument,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(100)),
              child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFFDC2626)),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon() {
    final ext = _documentFileName!.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: _bgCard,
          border: Border(top: BorderSide(color: _border.withOpacity(0.6))),
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _createCollie,
            icon: _isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.person_add_alt_1_rounded, size: 18),
            label: Text(_isLoading ? 'Creating…' : 'Create collie', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }
}
