import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantgo/Model/interview_model.dart';
import 'package:grantgo/cubit/interview/cubit/interview_cubit.dart';

class InterviewScreen extends StatefulWidget {
  final Map<String, dynamic> scholarship;
  const InterviewScreen({super.key, required this.scholarship});

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  final TextEditingController _answerCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  FeedbackModel? _pendingFeedback;
  bool _showFeedback = false;

  String _displayedQuestion = '';
  int _displayedQuestionNumber = 1;
  String _currentThreadId = '';

  static const Color _bg = Color(0xFF0A0F1E);
  static const Color _card = Color(0xFF0D1426);
  static const Color _blue = Color(0xFF2563EB);
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _lightBlue = Color(0xFF60A5FA);
  static const Color _lightPurple = Color(0xFFA78BFA);

  @override
  void initState() {
    super.initState();
    _startWithHealthCheck();
  }

  Future<void> _startWithHealthCheck() async {
    final cubit = context.read<InterviewCubit>();
    final healthy = await cubit.checkHealth();
    if (healthy && mounted) {
      cubit.startInterview(scholarship: widget.scholarship);
    }
  }

  @override
  void dispose() {
    _answerCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _submit(String threadId, String question, int qNum) {
    final text = _answerCtrl.text.trim();
    if (text.isEmpty) return;
    _answerCtrl.clear();
    context.read<InterviewCubit>().submitAnswer(
      threadId: threadId,
      answer: text,
      currentQuestion: question,
      currentQuestionNumber: qNum,
    );
  }

  void _goToNextQuestion() {
    final state = context.read<InterviewCubit>().state;
    if (state is InterviewInProgress) {
      setState(() {
        _displayedQuestion = state.question;
        _displayedQuestionNumber = state.questionNumber;
        _showFeedback = false;
        _pendingFeedback = null;
      });
    }
    _scrollCtrl.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [_lightBlue, _lightPurple],
          ).createShader(bounds),
          child: const Text(
            'Mock Interview',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white60),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<InterviewCubit, InterviewState>(
        listener: (context, state) {
          if (state is InterviewInProgress) {
            if (state.lastFeedback != null) {
              setState(() {
                _pendingFeedback = state.lastFeedback;
                _showFeedback = true;
                _currentThreadId = state.threadId;
              });
            } else {
              setState(() {
                _displayedQuestion = state.question;
                _displayedQuestionNumber = state.questionNumber;
                _currentThreadId = state.threadId;
                _showFeedback = false;
                _pendingFeedback = null;
              });
            }
          }
          if (state is InterviewComplete) {
            setState(() {
              _pendingFeedback = null;
              _showFeedback = false;
            });
          }
        },
        builder: (context, state) {
          if (state is InterviewHealthChecking || state is InterviewStarting) {
            return _buildLoading(
              state is InterviewHealthChecking
                  ? 'Waking up interview service...'
                  : 'Preparing your interview...',
            );
          }
          if (state is InterviewHealthError) {
            return _buildError(
              state.message,
              canRetry: true,
              onRetry: _startWithHealthCheck,
            );
          }
          if (state is InterviewError) {
            return _buildError(
              state.message,
              canRetry: state.canRetry,
              onRetry: state.canRetry
                  ? () => context.read<InterviewCubit>().startInterview(
                      scholarship: widget.scholarship,
                    )
                  : null,
            );
          }
          if (state is InterviewInProgress) {
            return _buildQuestionView(
              threadId: _currentThreadId.isEmpty
                  ? state.threadId
                  : _currentThreadId,
              question: _displayedQuestion.isEmpty
                  ? state.question
                  : _displayedQuestion,
              questionNumber:
                  _displayedQuestionNumber == 1 && state.questionNumber == 1
                  ? state.questionNumber
                  : _displayedQuestionNumber,
              isLoading: false,
            );
          }
          if (state is InterviewSubmitting) {
            return _buildQuestionView(
              threadId: _currentThreadId,
              question: _displayedQuestion,
              questionNumber: _displayedQuestionNumber,
              isLoading: true,
            );
          }
          if (state is InterviewComplete) {
            return _buildSummary(state.summary);
          }
          return _buildLoading('Initializing...');
        },
      ),
    );
  }

  // ─── Loading ──────────────────────────────────────────────────
  Widget _buildLoading(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [_blue, _purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _blue.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(color: Colors.white60, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'This may take up to 50 seconds on first load',
            style: TextStyle(color: Colors.white30, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ─── Error ────────────────────────────────────────────────────
  Widget _buildError(
    String message, {
    required bool canRetry,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 52),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            if (canRetry && onRetry != null) ...[
              const SizedBox(height: 24),
              _GradientButton(label: 'Try Again', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Question View ────────────────────────────────────────────
  Widget _buildQuestionView({
    required String threadId,
    required String question,
    required int questionNumber,
    required bool isLoading,
  }) {
    return Column(
      children: [
        _ProgressBar(current: questionNumber, total: 5),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _QuestionCard(
                  questionNumber: questionNumber,
                  question: question,
                ),
                const SizedBox(height: 20),

                if (_showFeedback && _pendingFeedback != null) ...[
                  _FeedbackCard(feedback: _pendingFeedback!),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: _GradientButton(
                      label: questionNumber < 5
                          ? 'Next Question →'
                          : 'See Results →',
                      onPressed: _goToNextQuestion,
                    ),
                  ),
                ],

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        if (!_showFeedback)
          _AnswerInput(
            controller: _answerCtrl,
            isLoading: isLoading,
            onSubmit: isLoading
                ? null
                : () => _submit(threadId, question, questionNumber),
          ),
      ],
    );
  }

  // ─── Summary ──────────────────────────────────────────────────
  Widget _buildSummary(SummaryModel summary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ScoreHeader(score: summary.overallScore),
          const SizedBox(height: 24),
          _SectionTitle(title: 'Performance by Dimension'),
          const SizedBox(height: 12),
          ...summary.dimensionAverages.entries.map(
            (e) => _DimensionBar(name: e.key, score: e.value),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _HighlightCard(
                  icon: Icons.emoji_events,
                  label: 'Strongest',
                  value: summary.strongestDimension,
                  color: _lightBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HighlightCard(
                  icon: Icons.fitness_center,
                  label: 'To Improve',
                  value: summary.weakestDimension,
                  color: _lightPurple,
                ),
              ),
            ],
          ),
          if (summary.totalConfidenceFlags > 0) ...[
            const SizedBox(height: 24),
            _ConfidenceCard(
              flags: summary.totalConfidenceFlags,
              questions: summary.flaggedQuestions,
            ),
          ],
          const SizedBox(height: 24),
          _SectionTitle(title: 'AI Recommendation'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _blue.withOpacity(0.3)),
            ),
            child: Text(
              summary.recommendation,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: _GradientButton(
              label: 'Finish Interview',
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: const Color(0xFF0D1426),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question $current of $total',
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              Text(
                '${((current / total) * 100).round()}%',
                style: const TextStyle(color: Color(0xFF60A5FA), fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: current / total,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF2563EB),
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int questionNumber;
  final String question;
  const _QuestionCard({required this.questionNumber, required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1426),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Q$questionNumber',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final FeedbackModel feedback;
  const _FeedbackCard({required this.feedback});

  Color _scoreColor(double score) {
    if (score >= 8) return const Color(0xFF34D399);
    if (score >= 6) return const Color(0xFFFBBF24);
    return const Color(0xFFF87171);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1426),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics_outlined,
                color: Color(0xFFA78BFA),
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Your Answer Feedback',
                style: TextStyle(
                  color: Color(0xFFA78BFA),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _scoreColor(feedback.average).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _scoreColor(feedback.average).withOpacity(0.5),
                  ),
                ),
                child: Text(
                  feedback.average.toStringAsFixed(1),
                  style: TextStyle(
                    color: _scoreColor(feedback.average),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...feedback.dimensions.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Text(
                    e.key[0].toUpperCase() + e.key.substring(1),
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    '${e.value}/10',
                    style: TextStyle(
                      color: _scoreColor((e.value as num).toDouble()),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (feedback.confidenceFlag) ...[
            const Divider(color: Colors.white12, height: 20),
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFFBBF24),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hedging language detected: "${feedback.confidenceNote}"',
                    style: const TextStyle(
                      color: Color(0xFFFBBF24),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (feedback.feedbackAnswer != null && feedback.average < 8) ...[
            const Divider(color: Colors.white12, height: 20),
            const Text(
              'Suggested improvement:',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              feedback.feedbackAnswer!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnswerInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback? onSubmit;

  const _AnswerInput({
    required this.controller,
    required this.isLoading,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1426),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 4,
              minLines: 2,
              enabled: !isLoading,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Type your answer here...',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: const Color(0xFF0A0F1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2563EB)),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onSubmit,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: isLoading
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: isLoading ? Colors.white12 : null,
                borderRadius: BorderRadius.circular(14),
              ),
              child: isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white54,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreHeader extends StatelessWidget {
  final double score;
  const _ScoreHeader({required this.score});

  Color get _color {
    if (score >= 8) return const Color(0xFF34D399);
    if (score >= 6) return const Color(0xFFFBBF24);
    return const Color(0xFFF87171);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2563EB).withOpacity(0.2),
            const Color(0xFF7C3AED).withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF60A5FA),
            size: 36,
          ),
          const SizedBox(height: 12),
          const Text(
            'Interview Complete!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            score.toStringAsFixed(1),
            style: TextStyle(
              color: _color,
              fontSize: 56,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Overall Score / 10',
            style: TextStyle(color: _color.withOpacity(0.7), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _DimensionBar extends StatelessWidget {
  final String name;
  final double score;
  const _DimensionBar({required this.name, required this.score});

  Color get _color {
    if (score >= 8) return const Color(0xFF34D399);
    if (score >= 6) return const Color(0xFFFBBF24);
    return const Color(0xFFF87171);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name[0].toUpperCase() + name.substring(1).replaceAll('_', ' '),
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              Text(
                score.toStringAsFixed(1),
                style: TextStyle(
                  color: _color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 10,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(_color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _HighlightCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1426),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value[0].toUpperCase() + value.substring(1).replaceAll('_', ' '),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfidenceCard extends StatelessWidget {
  final int flags;
  final List<int> questions;
  const _ConfidenceCard({required this.flags, required this.questions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBBF24).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFFBBF24),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Hedging language detected in $flags question${flags > 1 ? 's' : ''} '
              '(Q${questions.join(', Q')}). Work on expressing confidence.',
              style: const TextStyle(
                color: Color(0xFFFBBF24),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _GradientButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
