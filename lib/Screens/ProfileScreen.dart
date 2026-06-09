import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantgo/Services/token_storage.dart';
import 'package:grantgo/Screens/WelcomeScreen.dart';
import 'package:grantgo/cubit/profile/cubit/profile_cubit.dart';
import 'package:grantgo/cubit/profile/cubit/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color kBgColor = Color(0xFF0A0F1E);
  static const Color kCardColor = Color(0xFF0D1426);
  static const Color kBlue = Color(0xFF2563EB);
  static const Color kPurple = Color(0xFF7C3AED);
  static const Color kBlueLight = Color(0xFF60A5FA);
  static const Color kPurpleLight = Color(0xFFA78BFA);
  static const Color kBorderColor = Color(0xFF1A2540);
  static const Color kTextMuted = Color(0xFF64748B);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController fieldOfStudyController = TextEditingController();
  final TextEditingController educationLevelController =
      TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController majorController = TextEditingController();
  final TextEditingController gpaController = TextEditingController();
  final TextEditingController cvUrlController = TextEditingController();

  bool _isEditing = false;

  // لوائح محلية لإدارة التعديلات الإضافية ديناميكياً لتطابق الـ API
  List<String> _currentSkills = [];
  List<String> _currentCertificates = [];
  List<Map<String, String>> _currentLanguages = [];

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().fetchProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    nationalityController.dispose();
    fieldOfStudyController.dispose();
    educationLevelController.dispose();
    ageController.dispose();
    countryController.dispose();
    majorController.dispose();
    gpaController.dispose();
    cvUrlController.dispose();
    super.dispose();
  }

  void _fillControllers(Map<String, dynamic> user) {
    nameController.text = user['name'] ?? '';
    nationalityController.text = user['nationality'] ?? '';
    fieldOfStudyController.text = user['fieldOfStudy'] ?? '';
    educationLevelController.text = user['educationLevel'] ?? '';
    ageController.text = user['age']?.toString() ?? '';
    countryController.text = user['country'] ?? '';
    majorController.text = user['major'] ?? '';
    gpaController.text = user['gpa']?.toString() ?? '';
    cvUrlController.text = user['cvUrl'] ?? '';

    // ملء القوائم المحلية من بيانات السيرفر مباشرة
    _currentSkills = _parseStringList(user['skills']);
    _currentCertificates = _parseStringList(user['certificates']);
    _currentLanguages = _parseLanguages(user['languages']);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileSuccess) _fillControllers(state.user);
        if (state is ProfileUpdateSuccess) {
          setState(() => _isEditing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFF10B981),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        if (state is ProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      },
      builder: (context, state) {
        final user = state is ProfileSuccess ? state.user : <String, dynamic>{};

        return Scaffold(
          backgroundColor: kBgColor,
          body: Stack(
            children: [
              // Glow effects
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [kBlue.withOpacity(0.18), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                left: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [kPurple.withOpacity(0.15), Colors.transparent],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: state is ProfileLoading && !_isEditing
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: kBlue,
                          strokeWidth: 2.5,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(context, state),
                            const SizedBox(height: 32),
                            _buildAvatarSection(user),
                            const SizedBox(height: 32),
                            _buildSection(
                              title: 'Personal Information',
                              icon: Icons.person_outline_rounded,
                              children: [
                                _editableTile(
                                  icon: Icons.person_outline_rounded,
                                  label: 'Name',
                                  controller: nameController,
                                ),
                                _editableTile(
                                  icon: Icons.cake_outlined,
                                  label: 'Age',
                                  controller: ageController,
                                  keyboardType: TextInputType.number,
                                ),
                                _editableTile(
                                  icon: Icons.location_on_outlined,
                                  label: 'Country',
                                  controller: countryController,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildSection(
                              title: 'Academic Information',
                              icon: Icons.school_outlined,
                              children: [
                                _editableTile(
                                  icon: Icons.menu_book_outlined,
                                  label: 'Major',
                                  controller: majorController,
                                ),
                                _editableTile(
                                  icon: Icons.workspace_premium_outlined,
                                  label: 'Education Level',
                                  controller: educationLevelController,
                                ),
                                _editableTile(
                                  icon: Icons.grade_outlined,
                                  label: 'GPA',
                                  controller: gpaController,
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildListSection(
                              title: 'Languages',
                              icon: Icons.language_outlined,
                              items: _currentLanguages,
                              onAddPressed: _showAddLanguageDialog,
                            ),
                            const SizedBox(height: 20),
                            _buildChipSection(
                              title: 'Skills',
                              icon: Icons.lightbulb_outline_rounded,
                              chips: _currentSkills,
                              color: kBlue,
                              onAddPressed: () =>
                                  _showAddChipDialog('Skill', _currentSkills),
                            ),
                            const SizedBox(height: 20),
                            _buildChipSection(
                              title: 'Certificates',
                              icon: Icons.verified_outlined,
                              chips: _currentCertificates,
                              color: kPurple,
                              onAddPressed: () => _showAddChipDialog(
                                'Certificate',
                                _currentCertificates,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildExperienceSection(user['experience']),
                            const SizedBox(height: 20),
                            _buildSection(
                              title: 'CV',
                              icon: Icons.attach_file_rounded,
                              children: [
                                _editableTile(
                                  icon: Icons.link_rounded,
                                  label: 'CV URL',
                                  controller: cvUrlController,
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            _buildLogoutButton(context),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Helpers ────────────────────────────────────────────────

  List<String> _parseStringList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }

  List<Map<String, String>> _parseLanguages(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw
          .map<Map<String, String>>(
            (e) => {
              'language': e['language']?.toString() ?? '',
              'proficiency': e['proficiency']?.toString() ?? '',
            },
          )
          .toList();
    }
    return [];
  }

  List<Map<String, String>> _parseExperience(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw
          .map<Map<String, String>>(
            (e) => {
              'title': e['title']?.toString() ?? '',
              'company': e['company']?.toString() ?? '',
              'years': e['years']?.toString() ?? '',
            },
          )
          .toList();
    }
    return [];
  }

  // ── Popups الحوارية الجاهزة للإضافة الدقيقة ────────────────────────

  void _showAddChipDialog(String type, List<String> targetList) {
    final TextEditingController inputController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: kBorderColor),
        ),
        title: Text(
          'Add $type',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: inputController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter $type name',
            hintStyle: TextStyle(
              color: kTextMuted.withOpacity(0.5),
              fontSize: 14,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: kBorderColor),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: kBlueLight),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: kTextMuted)),
          ),
          TextButton(
            onPressed: () {
              if (inputController.text.trim().isNotEmpty) {
                setState(() {
                  targetList.add(inputController.text.trim());
                });
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Add',
              style: TextStyle(color: kBlueLight, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddLanguageDialog() {
    final TextEditingController langController = TextEditingController();
    final TextEditingController profController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: kBorderColor),
        ),
        title: const Text(
          'Add Language',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: langController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Language (e.g. English)',
                hintStyle: TextStyle(
                  color: kTextMuted.withOpacity(0.5),
                  fontSize: 14,
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: kBorderColor),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: kBlueLight),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: profController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Proficiency (e.g. Fluent, Native)',
                hintStyle: TextStyle(
                  color: kTextMuted.withOpacity(0.5),
                  fontSize: 14,
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: kBorderColor),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: kBlueLight),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: kTextMuted)),
          ),
          TextButton(
            onPressed: () {
              if (langController.text.trim().isNotEmpty &&
                  profController.text.trim().isNotEmpty) {
                setState(() {
                  _currentLanguages.add({
                    'language': langController.text.trim(),
                    'proficiency': profController.text.trim(),
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Add',
              style: TextStyle(color: kBlueLight, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ── Widgets ────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, ProfileState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: kBlueLight,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Scholara',
                  style: TextStyle(
                    color: kBlueLight.withOpacity(0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'My Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            if (_isEditing) {
              context.read<ProfileCubit>().updateProfile(
                name: nameController.text,
                nationality: nationalityController.text,
                fieldOfStudy: fieldOfStudyController.text,
                educationLevel: educationLevelController.text,
                age: ageController.text,
                country: countryController.text,
                major: majorController.text,
                gpa: gpaController.text,
                cvUrl: cvUrlController.text,
                skills: _currentSkills,
                certificates: _currentCertificates,
                languages: _currentLanguages,
              );
            } else {
              setState(() => _isEditing = true);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isEditing
                    ? [const Color(0xFF10B981), const Color(0xFF059669)]
                    : [kBlue, kPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: (_isEditing ? const Color(0xFF10B981) : kBlue)
                      .withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isEditing ? Icons.check_rounded : Icons.edit_rounded,
                  color: Colors.white,
                  size: 15,
                ),
                const SizedBox(width: 6),
                Text(
                  _isEditing ? 'Save' : 'Edit',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSection(Map<String, dynamic> user) {
    final name = (user['name'] ?? '').toString();
    final parts = name.trim().split(' ');
    var initials = parts
        .map((p) => p.isNotEmpty ? p[0] : '')
        .join()
        .toUpperCase();
    if (initials.length > 2) initials = initials.substring(0, 2);
    final email = user['email'] ?? '';

    return Center(
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kBlue, kPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kBlue.withOpacity(0.5),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials.isNotEmpty ? initials : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (name.isNotEmpty)
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          const SizedBox(height: 6),
          if (email.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: kBlueLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: kBlueLight.withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Text(
                email,
                style: const TextStyle(
                  color: kBlueLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(title),
        const SizedBox(height: 12),
        ...children.map(
          (w) => Padding(padding: const EdgeInsets.only(bottom: 10), child: w),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kBlue, kPurple],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _editableTile({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isEditing ? kBlue.withOpacity(0.5) : kBorderColor,
          width: 1.2,
        ),
        boxShadow: _isEditing
            ? [
                BoxShadow(
                  color: kBlue.withOpacity(0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isEditing
                  ? kBlue.withOpacity(0.15)
                  : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: _isEditing ? kBlueLight : kBlueLight.withOpacity(0.7),
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: _isEditing ? kBlueLight : kTextMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  enabled: _isEditing,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: '—',
                    hintStyle: TextStyle(
                      color: kTextMuted.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isEditing)
            Icon(Icons.edit_rounded, color: kBlue.withOpacity(0.5), size: 14),
        ],
      ),
    );
  }

  Widget _buildListSection({
    required String title,
    required IconData icon,
    required List<Map<String, String>> items,
    required VoidCallback onAddPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionHeader(title),
            if (_isEditing)
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline_rounded,
                  color: kBlueLight,
                  size: 20,
                ),
                onPressed: onAddPressed,
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          _emptyCard()
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorderColor, width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.language_outlined,
                        color: kBlueLight,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['language'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['proficiency'] ?? '',
                            style: const TextStyle(
                              color: kTextMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_isEditing)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            items.remove(item);
                          });
                        },
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: kBlue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: kBlue.withOpacity(0.3)),
                        ),
                        child: Text(
                          item['proficiency'] ?? '',
                          style: const TextStyle(
                            color: kBlueLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChipSection({
    required String title,
    required IconData icon,
    required List<String> chips,
    required Color color,
    required VoidCallback onAddPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionHeader(title),
            if (_isEditing)
              IconButton(
                icon: Icon(
                  Icons.add_circle_outline_rounded,
                  color: color == kBlue ? kBlueLight : kPurpleLight,
                  size: 20,
                ),
                onPressed: onAddPressed,
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (chips.isEmpty)
          _emptyCard()
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kBorderColor, width: 1.2),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips
                  .map(
                    (chip) => Container(
                      padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            chip,
                            style: TextStyle(
                              color: color == kBlue ? kBlueLight : kPurpleLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_isEditing) ...[
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  chips.remove(chip);
                                });
                              },
                              child: Icon(
                                Icons.close_rounded,
                                size: 14,
                                color: color == kBlue
                                    ? kBlueLight
                                    : kPurpleLight,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildExperienceSection(dynamic raw) {
    final items = _parseExperience(raw);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Experience'),
        const SizedBox(height: 12),
        if (items.isEmpty)
          _emptyCard()
        else
          ...items.map(
            (exp) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorderColor, width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.work_outline_rounded,
                        color: kPurpleLight,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exp['title'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            exp['company'] ?? '',
                            style: const TextStyle(
                              color: kTextMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: kPurple.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kPurple.withOpacity(0.3)),
                      ),
                      child: Text(
                        '${exp['years']}y',
                        style: const TextStyle(
                          color: kPurpleLight,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _emptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderColor, width: 1.2),
      ),
      child: Center(
        child: Text(
          '—',
          style: TextStyle(color: kTextMuted.withOpacity(0.6), fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await TokenStorage.deleteToken();
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const Welcomescreen()),
            (route) => false,
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFEF4444).withOpacity(0.3),
            width: 1.2,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFF87171), size: 20),
            SizedBox(width: 10),
            Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFFF87171),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
