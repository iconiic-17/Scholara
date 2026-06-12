import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:grantgo/Services/dio_client.dart';
import 'package:grantgo/Services/token_storage.dart';

class AboutScholarshipScreen extends StatefulWidget {
  final String scholarshipId;

  const AboutScholarshipScreen({super.key, required this.scholarshipId});

  @override
  State<AboutScholarshipScreen> createState() => _AboutScholarshipScreenState();
}

class _AboutScholarshipScreenState extends State<AboutScholarshipScreen> {
  static const Color kBgDark = Color(0xFF0A0F1E);
  static const Color kBgCard = Color(0xFF0D1426);
  static const Color kBlue = Color(0xFF2563EB);
  static const Color kPurple = Color(0xFF7C3AED);
  static const Color kBlueLight = Color(0xFF60A5FA);
  static const Color kPurpleLight = Color(0xFFA78BFA);
  static const Color kGreen = Color(0xFF34D399);
  static const Color kOrange = Color(0xFFFBBF24);
  static const Color kBorder = Color(0xFF1E2A40);
  static const Color kTextMuted = Color(0x99FFFFFF);

  Map<String, dynamic>? _scholarship;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchScholarship();
  }

  Future<void> _fetchScholarship() async {
    try {
      final token = await TokenStorage.getToken();
      final res = await appDio.get(
        '/scholarships/${widget.scholarshipId}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      setState(() {
        _scholarship = res.data as Map<String, dynamic>;
        _loading = false;
      });
    } on DioException catch (e) {
      setState(() {
        _error = e.response?.data?['message'] ?? 'Failed to load scholarship';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDark,
      body: Stack(
        children: [
          _loading
              ? _buildLoading()
              : _error != null
              ? _buildError()
              : _buildContent(),
          if (!_loading && _scholarship != null)
            _buildApplyButton(_scholarship?['link'] as String?),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: kBlueLight, strokeWidth: 2.5),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: kOrange, size: 48),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: kTextMuted, fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final s = _scholarship!;
    final title = s['title'] ?? 'Scholarship';
    final fundingType = s['fundingType'] ?? '—';
    final location = s['location'] ?? '—';
    final gender = s['gender'] ?? '—';
    final deadline = (s['deadline'] as String?)?.substring(0, 10);
    final degree = (s['degree'] as List?)?.join(', ') ?? '—';
    final fields = (s['fieldsOfStudy'] as List?)?.cast<String>() ?? [];
    final nationalities = (s['nationality'] as List?)?.cast<String>() ?? [];
    final criteria = (s['criteria'] as List?)?.cast<String>() ?? [];
    final benefits = (s['benefits'] as List?)?.cast<String>() ?? [];

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kBlue.withOpacity(0.18), kPurple.withOpacity(0.10)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(bottom: BorderSide(color: kBorder, width: 1)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kBgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: kBorder),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: kBlueLight,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: kGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: kGreen.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        fundingType.toString().toUpperCase(),
                        style: const TextStyle(
                          color: kGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      title.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1.3,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip(
                          Icons.location_on_outlined,
                          location.toString(),
                          Colors.orange,
                        ),
                        _chip(
                          Icons.school_outlined,
                          degree.toString(),
                          kBlueLight,
                        ),
                        _chip(
                          Icons.wc_rounded,
                          gender.toString(),
                          kPurpleLight,
                        ),
                        if (deadline != null)
                          _chip(
                            Icons.calendar_today_rounded,
                            'Closes $deadline',
                            kOrange,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (fields.isNotEmpty) ...[
                _sectionTitle('Fields of Study', Icons.menu_book_outlined),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: fields.map((f) => _tag(f, kPurpleLight)).toList(),
                ),
                const SizedBox(height: 24),
              ],

              if (nationalities.isNotEmpty) ...[
                _sectionTitle('Open To', Icons.public_rounded),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: nationalities
                      .map((n) => _tag(n, kBlueLight))
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],

              if (benefits.isNotEmpty) ...[
                _sectionTitle('Advantages', Icons.card_giftcard_rounded),
                const SizedBox(height: 10),
                ...benefits.map((b) => _bulletRow(b, kGreen)),
                const SizedBox(height: 24),
              ],

              if (criteria.isNotEmpty) ...[
                _sectionTitle('Requirments', Icons.checklist_rounded),
                const SizedBox(height: 10),
                ...criteria.map((c) => _bulletRow(c, kOrange)),
                const SizedBox(height: 24),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildApplyButton(String? link) {
    final hasLink = link != null && link.isNotEmpty;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: kBgDark,
          border: Border(top: BorderSide(color: kBorder, width: 1)),
        ),
        child: GestureDetector(
          onTap: hasLink
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening: $link'),
                      backgroundColor: kBlue,
                    ),
                  );
                }
              : null,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              gradient: hasLink
                  ? const LinearGradient(
                      colors: [kBlue, kPurple],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              color: hasLink ? null : kBgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: hasLink ? Colors.transparent : kBorder),
            ),
            child: Center(
              child: Text(
                hasLink ? 'Apply Now' : 'No Link Available',
                style: TextStyle(
                  color: hasLink ? Colors.white : kTextMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────
  Widget _sectionTitle(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: kBlueLight),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _bulletRow(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: kTextMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
