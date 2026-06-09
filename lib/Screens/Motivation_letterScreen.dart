import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantgo/cubit/Motivation/cubit/motivation_cubit.dart';

class MotivationView extends StatelessWidget {
  const MotivationView({super.key});

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
    return BlocConsumer<MotivationCubit, MotivationState>(
      listener: (context, state) {
        if (state is MotivationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade800,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<MotivationCubit>();
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildUploadCard(state, cubit),
              if (state is MotivationAnalyzing) ...[
                const SizedBox(height: 20),
                _buildAnalyzingIndicator(state.fileName),
              ],
              if (state is MotivationAnalyzed) ...[
                const SizedBox(height: 20),
                _buildResult(context, state, cubit),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: kPurple.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kPurple.withOpacity(0.3)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_note_rounded, size: 14, color: kPurpleLight),
              SizedBox(width: 6),
              Text(
                'AI-POWERED REVIEW',
                style: TextStyle(
                  fontSize: 11,
                  color: kPurpleLight,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [kPurpleLight, kBlueLight],
          ).createShader(b),
          child: const Text(
            'Motivation Letter',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Upload your motivation letter and get an AI score out of 10',
          style: TextStyle(color: kTextMuted, fontSize: 13, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildUploadCard(MotivationState state, MotivationCubit cubit) {
    final isBusy = state is MotivationPicking || state is MotivationAnalyzing;
    final isDone = state is MotivationAnalyzed;
    final fileName = state is MotivationAnalyzing ? state.fileName : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: kPurple.withOpacity(0.06),
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
                colors: [kPurple.withOpacity(0.2), kBlue.withOpacity(0.2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kPurple.withOpacity(0.3)),
            ),
            child: isBusy
                ? const Padding(
                    padding: EdgeInsets.all(18),
                    child: CircularProgressIndicator(
                      color: kPurpleLight,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    isDone
                        ? Icons.check_circle_rounded
                        : Icons.description_rounded,
                    color: isDone ? kGreen : kPurpleLight,
                    size: 34,
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            isBusy
                ? (fileName ?? 'Processing...')
                : isDone
                ? 'Analysis Complete ✓'
                : 'Upload Motivation Letter',
            style: TextStyle(
              color: isBusy
                  ? kPurpleLight
                  : isDone
                  ? kGreen
                  : Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            isDone
                ? 'Tap below to analyze another letter'
                : 'Upload a PDF (max 5MB) to get your score',
            style: const TextStyle(
              color: kTextMuted,
              fontSize: 13,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: isBusy ? null : cubit.pickAndAnalyze,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: isBusy
                    ? null
                    : const LinearGradient(
                        colors: [kPurple, kBlue],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                color: isBusy ? kBorder : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isBusy
                    ? []
                    : [
                        BoxShadow(
                          color: kPurple.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isBusy)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: kPurpleLight,
                        strokeWidth: 2,
                      ),
                    )
                  else
                    const Icon(
                      Icons.upload_file_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    isBusy
                        ? 'Analyzing...'
                        : isDone
                        ? 'Analyze Another Letter'
                        : 'Choose PDF File',
                    style: TextStyle(
                      color: isBusy ? kTextMuted : Colors.white,
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

  Widget _buildAnalyzingIndicator(String fileName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kPurple.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(color: kPurple.withOpacity(0.3)),
            ),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(
                color: kPurpleLight,
                strokeWidth: 2,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI is reviewing your letter...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'This can take up to 2 minutes',
                  style: TextStyle(color: Color(0x73FFFFFF), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(
    BuildContext context,
    MotivationAnalyzed state,
    MotivationCubit cubit,
  ) {
    return Column(
      children: [
        _buildScoreCard(state),
        if (state.problems.isNotEmpty) ...[
          const SizedBox(height: 14),
          _buildListCard(
            title: 'Problems Found',
            icon: Icons.warning_amber_rounded,
            color: kOrange,
            items: state.problems,
          ),
        ],
        if (state.missingElements.isNotEmpty) ...[
          const SizedBox(height: 14),
          _buildListCard(
            title: 'Missing Elements',
            icon: Icons.playlist_remove_rounded,
            color: Colors.redAccent,
            items: state.missingElements,
          ),
        ],
        if (state.rewrittenLetter != null) ...[
          const SizedBox(height: 14),
          _buildRewrittenCard(context, state.rewrittenLetter!),
        ],
      ],
    );
  }

  Widget _buildScoreCard(MotivationAnalyzed state) {
    final score = state.score;
    final color = score >= 8
        ? kGreen
        : score >= 5
        ? kOrange
        : Colors.redAccent;
    final isGreat = score >= 8;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
              border: Border.all(color: color.withOpacity(0.5), width: 3),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$score',
                  style: TextStyle(
                    color: color,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                Text(
                  '/ 10',
                  style: TextStyle(
                    color: color.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              state.verdict,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isGreat
                ? 'Your letter is well-written — no rewrite needed!'
                : 'See the issues below and use the improved version.',
            style: const TextStyle(
              color: kTextMuted,
              fontSize: 13,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: score / 10,
              backgroundColor: kBorder,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${items.length}',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: kTextMuted,
                        fontSize: 13,
                        height: 1.5,
                      ),
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

  Widget _buildRewrittenCard(BuildContext context, String letter) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBlue.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: kBlue.withOpacity(0.06),
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
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: kBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kBlue.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.auto_fix_high_rounded,
                  color: kBlueLight,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'AI Rewritten Letter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: letter));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Letter copied to clipboard!'),
                      backgroundColor: Color(0xFF34D399),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: kBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kBlue.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.copy_rounded, color: kBlueLight, size: 14),
                      SizedBox(width: 5),
                      Text(
                        'Copy',
                        style: TextStyle(
                          color: kBlueLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: Text(
              letter,
              style: const TextStyle(
                color: kTextMuted,
                fontSize: 13,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
