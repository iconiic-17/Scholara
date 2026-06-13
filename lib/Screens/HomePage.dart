import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grantgo/Model/scholarship_model.dart';
import 'package:grantgo/Screens/RecommendationScreen.dart';
import 'package:grantgo/Screens/SavedScreen.dart';
import 'package:grantgo/Screens/ProfileScreen.dart';
import 'package:grantgo/Screens/aboutScholarshipScreen.dart';
import 'package:grantgo/Screens/chatbotScreen.dart';
import 'package:grantgo/Screens/cvScreenState.dart';
import 'package:grantgo/cubit/chat/cubit/chat_cubit.dart';
import 'package:grantgo/cubit/scholarship/cubit/saved_scholarship_state.dart';
import 'package:grantgo/cubit/scholarship/cubit/scholarship_cubit.dart';
import 'package:grantgo/cubit/scholarship/cubit/scholarship_state.dart';
import 'package:grantgo/cubit/scholarship/cubit/saved_scholarship_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _currentIndex = 0;

  static const Color kBgColor = Color(0xFF0A0F1D);
  static const Color kCardColor = Color(0xFF141C2F);
  static const Color kPrimaryColor = Color(0xFF6366F1);
  static const Color kBorderColor = Color(0xFF222F4A);
  static const Color kTextMuted = Color(0xFF64748B);
  static const Color kSecondaryColor = Color(0xFF38BDF8);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _navItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    bool isCenter = false,
  }) {
    final bool isActive = _currentIndex == index;

    if (isCenter) {
      return GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF38BDF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFF222F4A), Color(0xFF222F4A)],
                  ),
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Icon(
            isActive ? activeIcon : icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? kPrimaryColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive
                ? kPrimaryColor.withOpacity(0.4)
                : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? kPrimaryColor : kTextMuted,
              size: 20,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isActive
                  ? Row(
                      children: [
                        const SizedBox(width: 7),
                        Text(
                          label,
                          style: const TextStyle(
                            color: kPrimaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _ExplorePage(),
          SavedPage(),
          CvScreen(),
          RecommendationsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: kCardColor,
          border: Border(top: BorderSide(color: kBorderColor, width: 1.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore_rounded,
                  label: 'Explore',
                  index: 0,
                ),
                _navItem(
                  icon: Icons.bookmark_border_rounded,
                  activeIcon: Icons.bookmark_rounded,
                  label: 'Saved',
                  index: 1,
                ),
                _navItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                  index: 4,
                ),
                _navItem(
                  icon: Icons.description_outlined,
                  activeIcon: Icons.description_rounded,
                  label: 'CV',
                  index: 2,
                  isCenter: true,
                ),
                _navItem(
                  icon: Icons.auto_awesome_outlined,
                  activeIcon: Icons.auto_awesome_rounded,
                  label: 'Matches',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExplorePage extends StatefulWidget {
  const _ExplorePage();

  @override
  State<_ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<_ExplorePage> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  String? selectedDegree;
  String? selectedFunding;
  String? selectedGender;
  String? selectedLocation;
  String? selectedDeadline;

  final List<String> degrees = ['Bachelor', 'Master', 'PhD'];
  final List<String> fundingTypes = [
    'Fully',
    'Partial',
    'Fully / Partial',
    'Unknown',
  ];
  final List<String> genders = ['Male', 'Female', 'Both'];
  final List<String> deadlines = ['1month', '3months', '6months'];

  ScholarshipsCubit cubit = ScholarshipsCubit();
  bool isFetchingMore = false;
  final Set<String> savedScholarshipIds = {};

  static const Color kBgColor = Color(0xFF0A0F1D);
  static const Color kCardColor = Color(0xFF141C2F);
  static const Color kPrimaryColor = Color(0xFF6366F1);
  static const Color kSecondaryColor = Color(0xFF38BDF8);
  static const Color kBorderColor = Color(0xFF222F4A);
  static const Color kTextMuted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    cubit.getScholarships();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final savedCubit = context.read<SavedScholarshipsCubit>();
      await savedCubit.fetchSavedScholarships();
      final state = savedCubit.state;
      if (state is SavedScholarshipsSuccess) {
        setState(() {
          savedScholarshipIds.addAll(
            state.savedScholarships.map((s) => s.id.toString()),
          );
        });
      }
    });

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _loadMore() {
    if (isFetchingMore) return;
    if (cubit.currentPage >= cubit.totalPages) return;
    setState(() => isFetchingMore = true);
    cubit.getScholarships(
      search: searchController.text,
      fundingType: selectedFunding,
      degree: selectedDegree,
      gender: selectedGender,
      location: selectedLocation,
      deadlineWithin: selectedDeadline,
      page: cubit.currentPage + 1,
    );
  }

  void _applyFilters() {
    setState(() => isFetchingMore = false); // ✅ reset عند أي فلتر جديد
    cubit.getScholarships(
      search: searchController.text,
      fundingType: selectedFunding,
      degree: selectedDegree,
      gender: selectedGender,
      location: selectedLocation,
      deadlineWithin: selectedDeadline,
      page: 1,
    );
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

  void _toggleSave(ScholarshipModel scholarship) {
    final String id = scholarship.id.toString();
    final savedCubit = context.read<SavedScholarshipsCubit>();
    setState(() {
      if (savedScholarshipIds.contains(id)) {
        savedScholarshipIds.remove(id);
        savedCubit.removeSavedScholarship(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from Saved'),
            backgroundColor: Color(0xFFEF4444),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        savedScholarshipIds.add(id);
        savedCubit.saveScholarship(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scholarship saved!'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 1),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => cubit,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildFilters(),
            const SizedBox(height: 12),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
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
                'Explore\nOpportunities',
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
          // ── Chat Button (replaces notification icon) ──
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => ChatCubit(),
                    child: const ChatScreen(),
                  ),
                ),
              );
            },
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kPrimaryColor, Color(0xFF38BDF8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorderColor, width: 1.2),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kBorderColor, width: 1.2),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.search_rounded, color: kTextMuted, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Search scholarships, fields...',
                  hintStyle: TextStyle(color: kTextMuted, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: (val) => _applyFilters(),
                onSubmitted: (_) => _applyFilters(),
              ),
            ),
            GestureDetector(
              onTap: _applyFilters,
              child: Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kPrimaryColor, Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text(
                  'Search',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          if (selectedDegree != null ||
              selectedFunding != null ||
              selectedGender != null ||
              selectedLocation != null ||
              selectedDeadline != null)
            _clearChip(),
          _filterChip(
            label: selectedDegree ?? 'Degree',
            icon: Icons.school_rounded,
            isActive: selectedDegree != null,
            items: degrees,
            onSelected: (val) {
              setState(() {
                selectedDegree = val == selectedDegree ? null : val;
              });
              _applyFilters();
            },
          ),
          const SizedBox(width: 8),
          _filterChip(
            label: selectedFunding ?? 'Funding',
            icon: Icons.account_balance_wallet_rounded,
            isActive: selectedFunding != null,
            items: fundingTypes,
            onSelected: (val) {
              setState(() {
                selectedFunding = val == selectedFunding ? null : val;
              });
              _applyFilters();
            },
          ),
          const SizedBox(width: 8),
          _filterChip(
            label: selectedGender ?? 'Gender',
            icon: Icons.wc_rounded,
            isActive: selectedGender != null,
            items: genders,
            onSelected: (val) {
              setState(() {
                selectedGender = val == selectedGender ? null : val;
              });
              _applyFilters();
            },
          ),
          const SizedBox(width: 8),
          _filterChip(
            label: selectedLocation ?? 'Location',
            icon: Icons.location_on_rounded,
            isActive: selectedLocation != null,
            items: [
              'Germany',
              'USA',
              'Canada',
              'UK',
              'Australia',
              'France',
              'Italy',
            ],
            onSelected: (val) {
              setState(() {
                selectedLocation = val == selectedLocation ? null : val;
              });
              _applyFilters();
            },
          ),
          const SizedBox(width: 8),
          _filterChip(
            label: selectedDeadline ?? 'Deadline',
            icon: Icons.calendar_month_rounded,
            isActive: selectedDeadline != null,
            items: deadlines,
            onSelected: (val) {
              setState(() {
                selectedDeadline = val == selectedDeadline ? null : val;
              });
              _applyFilters();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return BlocBuilder<ScholarshipsCubit, ScholarshipsState>(
      builder: (context, state) {
        if (state is ScholarshipsLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: kPrimaryColor,
              strokeWidth: 2.5,
            ),
          );
        }
        if (state is ScholarshipsFailure) {
          // ✅ reset flag on error
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => isFetchingMore = false);
          });
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
                  style: const TextStyle(color: kTextMuted, fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _applyFilters,
                  style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }
        if (state is ScholarshipsSuccess) {
          // ✅ reset flag on success
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => isFetchingMore = false);
          });

          if (state.scholarships.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.hourglass_empty_rounded,
                    color: kTextMuted.withOpacity(0.5),
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No scholarships found',
                    style: TextStyle(color: kTextMuted, fontSize: 14),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            itemCount: state.scholarships.length + (isFetchingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == state.scholarships.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      color: kPrimaryColor,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }
              final s = state.scholarships[index];
              return _AnimatedCard(index: index, child: _scholarshipCard(s));
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _scholarshipCard(ScholarshipModel s) {
    final bool isSaved = savedScholarshipIds.contains(s.id.toString());
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kBorderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
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
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header Row ──
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
                          GestureDetector(
                            onTap: () => _toggleSave(s),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isSaved
                                    ? kPrimaryColor.withOpacity(0.15)
                                    : kBgColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSaved ? kPrimaryColor : kBorderColor,
                                  width: 1.2,
                                ),
                              ),
                              child: Icon(
                                isSaved
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                size: 16,
                                color: isSaved ? kPrimaryColor : kTextMuted,
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
                  children: s.degree
                      .map(
                        (d) => ConstrainedBox(
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
                        ),
                      )
                      .toList(),
                ),
                // ── Deadline ──
                if (s.deadline.isNotEmpty) ...[
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
                // ── Fields of Study ──
                if (s.fieldsOfStudy.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: s.fieldsOfStudy
                        .take(3)
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

  Widget _filterChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required List<String> items,
    required void Function(String) onSelected,
  }) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      color: kCardColor,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: kBorderColor),
      ),
      itemBuilder: (_) => items
          .map(
            (item) => PopupMenuItem(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? kPrimaryColor : kCardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? kPrimaryColor : kBorderColor,
            width: 1.2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: kPrimaryColor.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isActive ? Colors.white : kTextMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more_rounded,
              size: 14,
              color: isActive ? Colors.white : kTextMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _clearChip() {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDegree = null;
          selectedFunding = null;
          selectedGender = null;
          selectedLocation = null;
          selectedDeadline = null;
          searchController.clear();
        });
        _applyFilters();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.backspace_rounded, size: 13, color: Color(0xFFF87171)),
            SizedBox(width: 5),
            Text(
              'Reset',
              style: TextStyle(
                color: Color(0xFFF87171),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedCard extends StatefulWidget {
  final int index;
  final Widget child;
  const _AnimatedCard({required this.index, required this.child});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.index * 45), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(position: _slideAnim, child: widget.child),
    );
  }
}
