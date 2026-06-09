import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantgo/Screens/Motivation_letterScreen.dart';
import 'package:grantgo/cubit/CV/cubit/cv_cubit.dart';
import 'package:dio/dio.dart';
import 'package:grantgo/cubit/Motivation/cubit/motivation_cubit.dart';

class CvScreen extends StatelessWidget {
  const CvScreen({super.key});

  static const Color kBgDark = Color(0xFF0A0F1E);
  static const Color kBgCard = Color(0xFF0D1426);
  static const Color kBlue = Color(0xFF2563EB);
  static const Color kPurple = Color(0xFF7C3AED);
  static const Color kBlueLight = Color(0xFF60A5FA);
  static const Color kPurpleLight = Color(0xFFA78BFA);
  static const Color kGreen = Color(0xFF34D399);
  static const Color kOrange = Color(0xFFFBBF24);
  static const Color kBorder = Color(0xFF1E2A40);
  static const Color kTextMuted = Color(0x73FFFFFF);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: kBgDark,
        body: SafeArea(
          child: Stack(
            children: [
              _glow(top: -60, right: -60, color: kBlue),
              _glow(bottom: 120, left: -40, color: kPurple),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (b) => const LinearGradient(
                            colors: [kBlueLight, kPurpleLight],
                          ).createShader(b),
                          child: const Text(
                            'AI Tools',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Analyze your documents with AI',
                          style: TextStyle(
                            color: kTextMuted,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 46,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: kBgCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: kBorder),
                          ),
                          child: TabBar(
                            indicator: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [kBlue, kPurple],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: kBlue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.white.withOpacity(0.4),
                            labelStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            tabs: const [
                              Tab(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.description_rounded, size: 15),
                                    SizedBox(width: 6),
                                    Text('CV Analysis'),
                                  ],
                                ),
                              ),
                              Tab(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.edit_note_rounded, size: 15),
                                    SizedBox(width: 6),
                                    Text('Motivation'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // Tab 1 — CV Analysis
                        BlocConsumer<CvCubit, CvState>(
                          listener: (context, state) {
                            if (state is CvError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(state.message),
                                  backgroundColor: Colors.red.shade800,
                                ),
                              );
                            }
                          },
                          builder: (context, state) {
                            final cubit = context.read<CvCubit>();
                            final isBusy =
                                state is CvGeneratingRecommendations ||
                                state is CvAnalyzing;
                            return SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                20,
                                20,
                                30,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildCvSubHeader(),
                                  const SizedBox(height: 20),
                                  _buildCvCard(state, cubit),
                                  if (state is CvUploaded ||
                                      isBusy ||
                                      (state is CvError &&
                                          _hadUpload(cubit))) ...[
                                    const SizedBox(height: 16),
                                    _buildAnalyzeButton(state, cubit),
                                  ],
                                  if (isBusy) ...[
                                    const SizedBox(height: 20),
                                    _buildProgressSteps(state),
                                  ],
                                  if (state is CvAnalyzed) ...[
                                    const SizedBox(height: 20),
                                    _buildAnalysisResult(state.analysis),
                                    const SizedBox(height: 20),
                                    _buildRecommendations(
                                      state.recommendations,
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),

                        BlocProvider(
                          create: (_) => MotivationCubit(Dio()),
                          child: const MotivationView(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hadUpload(CvCubit cubit) => cubit.uploadedCvUrl != null;

  Widget _glow({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(0.2), Colors.transparent],
          ),
        ),
      ),
    );
  }

  Widget _buildCvSubHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: kBlue.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBlue.withOpacity(0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 14, color: kBlueLight),
          SizedBox(width: 6),
          Text(
            'AI-POWERED CV ANALYSIS',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF93C5FD),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCvCard(CvState state, CvCubit cubit) {
    final isUploading = state is CvUploading;
    final hasCV =
        state is CvUploaded ||
        state is CvGeneratingRecommendations ||
        state is CvAnalyzing ||
        state is CvAnalyzed;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: kBlue.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kBlue.withOpacity(0.2), kPurple.withOpacity(0.2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kBlue.withOpacity(0.3)),
            ),
            child: isUploading
                ? const Padding(
                    padding: EdgeInsets.all(18),
                    child: CircularProgressIndicator(
                      color: kBlueLight,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    hasCV
                        ? Icons.check_circle_rounded
                        : Icons.picture_as_pdf_rounded,
                    color: hasCV ? kGreen : kBlueLight,
                    size: 34,
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            isUploading
                ? 'Uploading...'
                : hasCV
                ? 'CV Uploaded ✓'
                : 'Upload Your CV',
            style: TextStyle(
              color: isUploading
                  ? kBlueLight
                  : hasCV
                  ? kGreen
                  : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasCV
                ? 'Your CV is ready for analysis'
                : 'Upload a PDF file to get personalized scholarship matches',
            style: const TextStyle(
              color: kTextMuted,
              fontSize: 13,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: isUploading ? null : cubit.pickAndUploadCv,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kBlue, kPurple],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: kBlue.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.upload_file_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasCV ? 'Replace CV' : 'Choose PDF File',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton(CvState state, CvCubit cubit) {
    final isBusy = state is CvGeneratingRecommendations || state is CvAnalyzing;
    return GestureDetector(
      onTap: isBusy ? null : cubit.runFullAnalysis,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: isBusy ? kBgCard : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isBusy
                ? kBlue.withOpacity(0.4)
                : Colors.white.withOpacity(0.12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isBusy)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: kBlueLight,
                  strokeWidth: 2,
                ),
              )
            else
              const Icon(
                Icons.auto_awesome_rounded,
                color: kPurpleLight,
                size: 18,
              ),
            const SizedBox(width: 10),
            Text(
              isBusy ? 'Processing...' : 'Analyze with AI',
              style: TextStyle(
                color: isBusy ? kBlueLight : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSteps(CvState state) {
    final steps = [
      {
        'label': 'Generating Recommendations',
        'done': state is CvAnalyzing || state is CvAnalyzed,
      },
      {'label': 'Analyzing your CV with AI', 'done': state is CvAnalyzed},
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: steps.asMap().entries.map((e) {
          final isDone = e.value['done'] as bool;
          final isActive = !isDone;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isDone
                        ? kGreen.withOpacity(0.15)
                        : kBlue.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDone
                          ? kGreen.withOpacity(0.4)
                          : kBlue.withOpacity(0.3),
                    ),
                  ),
                  child: isDone
                      ? const Icon(Icons.check_rounded, color: kGreen, size: 16)
                      : isActive
                      ? const Padding(
                          padding: EdgeInsets.all(6),
                          child: CircularProgressIndicator(
                            color: kBlueLight,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.circle_outlined,
                          color: kTextMuted,
                          size: 16,
                        ),
                ),
                const SizedBox(width: 12),
                Text(
                  e.value['label'] as String,
                  style: TextStyle(
                    color: isDone
                        ? kGreen
                        : isActive
                        ? Colors.white
                        : kTextMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAnalysisResult(Map<String, dynamic> analysis) {
    final score = (analysis['score'] ?? 0).toString();
    final summary = analysis['summary'] ?? 'Analysis complete.';
    final suggestions = analysis['suggestions'] as Map<String, dynamic>?;
    final high = (suggestions?['highPriority'] as List?)?.cast<String>() ?? [];
    final medium =
        (suggestions?['mediumPriority'] as List?)?.cast<String>() ?? [];
    final low = (suggestions?['lowPriority'] as List?)?.cast<String>() ?? [];
    final extractedData = analysis['extractedData'] as Map<String, dynamic>?;
    final report = extractedData?['report'] as Map<String, dynamic>?;
    final agentScores = report?['agentScores'] as Map<String, dynamic>?;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: kGreen.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: kGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kGreen.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: kGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Analysis Result',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: kBorder),
          const SizedBox(height: 16),
          Row(
            children: [
              _statBox('CV Score', score, kGreen),
              const SizedBox(width: 10),
              _statBox('High Priority', '${high.length}', Colors.redAccent),
              const SizedBox(width: 10),
              _statBox(
                'Suggestions',
                '${high.length + medium.length + low.length}',
                kBlueLight,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (agentScores != null && agentScores.isNotEmpty) ...[
            const Text(
              'Detailed Scores',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            ...agentScores.entries.map(
              (e) => _agentScoreRow(e.key, (e.value as num).toInt()),
            ),
            const SizedBox(height: 16),
          ],
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: Text(
              summary.toString(),
              style: const TextStyle(
                color: kTextMuted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
          if (high.isNotEmpty) ...[
            const SizedBox(height: 16),
            _suggestionSection('🔴 High Priority', high, Colors.redAccent),
          ],
          if (medium.isNotEmpty) ...[
            const SizedBox(height: 10),
            _suggestionSection('🟡 Medium Priority', medium, kOrange),
          ],
          if (low.isNotEmpty) ...[
            const SizedBox(height: 10),
            _suggestionSection('🟢 Low Priority', low, kGreen),
          ],
        ],
      ),
    );
  }

  Widget _agentScoreRow(String label, int score) {
    final color = score >= 8
        ? kGreen
        : score >= 6
        ? kOrange
        : Colors.redAccent;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: kTextMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$score/10',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 10,
              backgroundColor: kBorder,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _suggestionSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: kTextMuted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: kTextMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(List<dynamic> recs) {
    if (recs.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [kBlueLight, kPurpleLight],
              ).createShader(b),
              child: const Text(
                'AI Recommendations',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: kBlue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBlue.withOpacity(0.3)),
              ),
              child: Text(
                '${recs.length} matches',
                style: const TextStyle(
                  color: kBlueLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...recs.map((rec) => _recCard(rec as Map<String, dynamic>)),
      ],
    );
  }

  Widget _recCard(Map<String, dynamic> rec) {
    final scholarship = rec['scholarshipId'] as Map<String, dynamic>? ?? {};
    final title = scholarship['title'] ?? 'Scholarship';
    final score = rec['compatibilityScore'] ?? 0;
    final funding = scholarship['fundingType'] ?? '—';
    final degree = (scholarship['degree'] as List?)?.join(', ') ?? '—';
    final deadline = scholarship['deadline']?.toString().substring(0, 10);
    final matchValue = (score is num)
        ? score.toInt()
        : int.tryParse(score.toString()) ?? 0;
    final matchColor = matchValue >= 80
        ? kGreen
        : matchValue >= 60
        ? kBlueLight
        : kPurpleLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: matchColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: matchColor.withOpacity(0.4), width: 2),
            ),
            child: Center(
              child: Text(
                matchValue.toStringAsFixed(0),
                style: TextStyle(
                  color: matchColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _miniTag(funding.toString(), kGreen),
                    const SizedBox(width: 6),
                    _miniTag(degree.toString(), kBlueLight),
                  ],
                ),
                if (deadline != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Deadline: $deadline',
                    style: const TextStyle(color: kTextMuted, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Colors.white.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _miniTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
