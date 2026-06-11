import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantgo/cubit/CV/cubit/cv_cubit.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDark,
      body: SafeArea(
        child: BlocBuilder<CvCubit, CvState>(
          builder: (context, state) {
            List<dynamic> recs = [];
            if (state is CvAnalyzed) {
              recs = state.recommendations;
            } else if (state is CvRecommendationsReady) {
              recs = state.recommendations;
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(recs.length)),
                if (recs.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(context, state),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) =>
                            _recCard(recs[i] as Map<String, dynamic>),
                        childCount: recs.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [kBlueLight, kPurpleLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Text(
                  'AI Matches',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
              if (count > 0)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: kBlueLight.withOpacity(0.2)),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_outlined,
                    size: 18,
                    color: kBlueLight,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count > 0
                ? '⚡ Precision engine matched $count prime opportunities'
                : 'Configure profile or upload CV to synchronize targets',
            style: const TextStyle(
              color: kTextMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          if (count > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kBlue.withOpacity(0.15), kPurple.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBlue.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    size: 14,
                    color: kGreen,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'INTELLIGENT SELECTION VERIFIED',
                    style: TextStyle(
                      fontSize: 10,
                      color: kBlueLight.withOpacity(0.9),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, CvState state) {
    final isAnalyzing =
        state is CvAnalyzing || state is CvGeneratingRecommendations;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (isAnalyzing)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 2),

                    builder: (context, value, child) {
                      return Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: kBlueLight.withOpacity(0.15 * (1.0 - value)),
                            width: 4 * value,
                          ),
                        ),
                      );
                    },
                  ),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: kBgCard,
                    gradient: RadialGradient(
                      colors: [kBlue.withOpacity(0.15), Colors.transparent],
                      radius: 0.6,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isAnalyzing
                          ? kBlueLight.withOpacity(0.3)
                          : kBorder,
                    ),
                  ),
                  child: isAnalyzing
                      ? const Padding(
                          padding: EdgeInsets.all(26),
                          child: CircularProgressIndicator(
                            color: kBlueLight,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(
                          Icons.radar_rounded,
                          color: kPurpleLight,
                          size: 38,
                        ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              isAnalyzing ? 'Scanning Ecosystem...' : 'No Synchronized Matches',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isAnalyzing
                  ? 'AI agent is cross-referencing global parameters with your academic index.'
                  : 'Establish parameters inside your Profile portfolio or trigger full CV verification to pop matches.',
              style: const TextStyle(
                color: kTextMuted,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _recCard(Map<String, dynamic> rec) {
    final scholarship = rec['scholarshipId'] as Map<String, dynamic>? ?? {};
    final title = scholarship['title'] ?? 'Scholarship Opportunity';
    final score = rec['compatibilityScore'] ?? 0;
    final funding = scholarship['fundingType'] ?? '—';
    final degree = (scholarship['degree'] as List?)?.join(', ') ?? '—';
    final deadline = scholarship['deadline']?.toString().substring(0, 10);

    final matchVal = (score is num)
        ? score.toInt()
        : int.tryParse(score.toString()) ?? 0;

    final matchColor = matchVal >= 80
        ? kGreen
        : matchVal >= 60
        ? kBlueLight
        : kPurpleLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kBgCard.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorder.withOpacity(0.8), width: 1),
        gradient: LinearGradient(
          colors: [kBgCard, kBgCard.withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {},
          splashColor: kBlue.withOpacity(0.05),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📊 الـ Custom Progress Indicator المحترف لنسبة المطابقة
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 58,
                      height: 58,
                      child: CircularProgressIndicator(
                        value: matchVal / 100,
                        backgroundColor: Colors.white.withOpacity(0.03),
                        valueColor: AlwaysStoppedAnimation<Color>(matchColor),
                        strokeWidth: 3.5,
                      ),
                    ),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: matchColor.withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$matchVal%',
                          style: TextStyle(
                            color: matchColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _miniTag(
                            funding.toString(),
                            kGreen,
                            Icons.account_balance_wallet_outlined,
                          ),
                          _miniTag(
                            degree.toString(),
                            kBlueLight,
                            Icons.school_outlined,
                          ),
                        ],
                      ),
                      if (deadline != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: Colors.orange.withOpacity(0.8),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Closing: $deadline',
                              style: TextStyle(
                                color: kTextMuted.withOpacity(0.7),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniTag(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.18), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
