import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantgo/Screens/aboutScholarshipScreen.dart';
import 'package:grantgo/cubit/scholarship/cubit/saved_scholarship_cubit.dart';
import 'package:grantgo/cubit/scholarship/cubit/saved_scholarship_state.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  static const Color kBgColor = Color(0xFF0A0F1D);
  static const Color kCardColor = Color(0xFF141C2F);
  static const Color kPrimaryColor = Color(0xFF6366F1);
  static const Color kSecondaryColor = Color(0xFF38BDF8);
  static const Color kBorderColor = Color(0xFF222F4A);
  static const Color kTextMuted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    context.read<SavedScholarshipsCubit>().fetchSavedScholarships();
  }

  Color _fundingColor(String type) {
    switch (type) {
      case 'Fully':
        return const Color(0xFF10B981);
      case 'Partial':
        return const Color(0xFFF59E0B);
      default:
        return kSecondaryColor;
    }
  }

  IconData _fundingIcon(String type) {
    switch (type) {
      case 'Fully':
        return Icons.verified_user_rounded;
      case 'Partial':
        return Icons.pie_chart_rounded;
      default:
        return Icons.help_center_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: BlocConsumer<SavedScholarshipsCubit, SavedScholarshipsState>(
                listener: (context, state) {
                  if (state is SavedActionSuccess && !state.isSaved) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: const Color(0xFFEF4444),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is SavedScholarshipsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: kPrimaryColor,
                        strokeWidth: 2.5,
                      ),
                    );
                  }

                  if (state is SavedScholarshipsFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_off_rounded,
                            color: kTextMuted.withOpacity(0.5),
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.error,
                            style: const TextStyle(
                              color: kTextMuted,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is SavedScholarshipsSuccess) {
                    final list = state.savedScholarships;

                    if (list.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: kCardColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: kBorderColor),
                              ),
                              child: const Icon(
                                Icons.bookmark_border_rounded,
                                color: kTextMuted,
                                size: 44,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'No Saved Scholarships',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tap the bookmark icon on any\nscholarship to save it here',
                              style: TextStyle(
                                color: kTextMuted,
                                fontSize: 13,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final s = list[index];
                        return _savedCard(s);
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: kSecondaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Scholara',
                style: TextStyle(
                  color: kSecondaryColor.withOpacity(0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Saved\nScholarships',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _savedCard(dynamic s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.hardEdge, // ✅ prevent overflow
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kBorderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.2),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AboutScholarshipScreen(scholarshipId: s.id.toString()),
              ),
            );
          },
          splashColor: kPrimaryColor.withOpacity(0.1),
          highlightColor: kPrimaryColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header Row: Location & [Funding Badge + Delete] ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: kBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.g_translate_rounded,
                              size: 14,
                              color: kSecondaryColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s.location.toUpperCase(),
                              style: const TextStyle(
                                color: kSecondaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ✅ Flexible to prevent overflow on right side
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _fundingColor(
                                  s.fundingType,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: _fundingColor(
                                    s.fundingType,
                                  ).withOpacity(0.25),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _fundingIcon(s.fundingType),
                                    size: 12,
                                    color: _fundingColor(s.fundingType),
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      s.fundingType,
                                      style: TextStyle(
                                        color: _fundingColor(s.fundingType),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Delete button
                          GestureDetector(
                            onTap: () {
                              context
                                  .read<SavedScholarshipsCubit>()
                                  .removeSavedScholarship(s.id.toString());
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(
                                    0xFFEF4444,
                                  ).withOpacity(0.3),
                                  width: 1.2,
                                ),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                size: 16,
                                color: Color(0xFFF87171),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Title ──
                Text(
                  s.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                Container(height: 1, color: kBorderColor.withOpacity(0.6)),
                const SizedBox(height: 14),

                // ── Degree ──
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: (s.degree as List).map((d) {
                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 120),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: kBgColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kBorderColor),
                        ),
                        child: Text(
                          d,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // ── Deadline ──
                if (s.deadline != null && s.deadline.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 11,
                          color: Color(0xFFF87171),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          s.deadline.length >= 10
                              ? s.deadline.substring(0, 10)
                              : s.deadline,
                          style: const TextStyle(
                            color: Color(0xFFF87171),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Fields of Study ✅ ──
                if (s.fieldsOfStudy != null &&
                    (s.fieldsOfStudy as List).isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: (s.fieldsOfStudy as List)
                        .take(3) // ✅ max 3
                        .map(
                          (f) => ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 140),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF7C3AED,
                                ).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(
                                    0xFF7C3AED,
                                  ).withOpacity(0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.menu_book_outlined,
                                    size: 11,
                                    color: Color(0xFFA78BFA),
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      f,
                                      style: const TextStyle(
                                        color: Color(0xFFA78BFA),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
