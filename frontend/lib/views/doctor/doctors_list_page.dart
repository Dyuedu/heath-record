import 'package:flutter/material.dart';
import 'package:frontend/data/models/doctor/doctor_model.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:frontend/utils/doctor_ui_helpers.dart';
import 'package:frontend/viewmodels/doctor_viewmodel.dart';
import 'package:frontend/views/doctor/doctor_info.dart';
import 'package:frontend/widgets/bottom_nav.dart';
import 'package:provider/provider.dart';

class DoctorsListPage extends StatefulWidget {
  const DoctorsListPage({super.key});

  @override
  State<DoctorsListPage> createState() => _DoctorsListPageState();
}

class _DoctorsListPageState extends State<DoctorsListPage> {
  late final TextEditingController _searchController;
  VoidCallback? _searchListener;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<DoctorViewModel>();
      vm.fetchDoctors();
      _searchListener = () => vm.updateSearchQuery(_searchController.text);
      _searchController.addListener(_searchListener!);
    });
  }

  @override
  void dispose() {
    if (_searchListener != null) {
      _searchController.removeListener(_searchListener!);
    }
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DoctorViewModel>();
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildSearchBar(vm),
          _buildFilterBar(vm),
          Expanded(child: _buildDoctorList(vm)),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          color: AppTheme.primaryColor,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Doctors',
        style: TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(DoctorViewModel vm) {
    final dropdownItems = [
      const DropdownMenuItem(value: '', child: Text('Tất cả khoa')),
      ...vm.departments.map(
        (dept) => DropdownMenuItem(value: dept, child: Text(dept)),
      ),
    ];
    final dropdownValue = vm.selectedDepartment ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (_, value, __) {
              return TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo tên bác sĩ',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.primaryColor,
                  ),
                  suffixIcon: value.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppTheme.captionTextColor,
                          ),
                          onPressed: () => _searchController.clear(),
                        ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: dropdownValue,
            items: dropdownItems,
            onChanged: vm.departments.isEmpty
                ? null
                : (value) => vm.setDepartmentFilter(
                    value == null || value.isEmpty ? null : value,
                  ),
            decoration: InputDecoration(
              labelText: 'Lọc theo khoa',
              prefixIcon: const Icon(
                Icons.local_hospital_outlined,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(DoctorViewModel vm) {
    return SizedBox(
      height: 70,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        children: [
          Center(
            child: Text(
              'Sort',
              style: TextStyle(
                color: AppTheme.captionTextColor.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _filterChip(
            label: vm.isAscending ? 'A → Z' : 'Z → A',
            isActive: vm.currentFilter == 'AZ',
            onSelected: (_) => vm.sortByName(),
          ),
          _iconFilterChip(
            tooltip: 'Top Rated',
            icon: Icons.star_rate_rounded,
            isActive: vm.currentFilter == 'Rating',
            onTap: vm.filterByRating,
          ),
          _iconFilterChip(
            tooltip: 'Most Favorite',
            icon: Icons.favorite,
            isActive: vm.currentFilter == 'Favorite',
            onTap: vm.filterByFavorite,
          ),
          _iconFilterChip(
            tooltip: 'Female Doctors',
            icon: Icons.female,
            isActive: vm.currentFilter == 'Female',
            onTap: () => vm.filterByGender(Gender.female),
          ),
          _iconFilterChip(
            tooltip: 'Male Doctors',
            icon: Icons.male,
            isActive: vm.currentFilter == 'Male',
            onTap: () => vm.filterByGender(Gender.male),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool isActive,
    required ValueChanged<bool> onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: isActive,
        onSelected: onSelected,
        selectedColor: AppTheme.primaryColor,
        backgroundColor: AppTheme.primaryLight,
        labelStyle: TextStyle(
          color: isActive ? Colors.white : AppTheme.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _iconFilterChip({
    required String tooltip,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryColor : AppTheme.primaryLight,
              shape: BoxShape.circle,
              boxShadow: isActive ? DoctorUIHelpers.softShadow(blur: 12) : null,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : AppTheme.primaryColor,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorList(DoctorViewModel vm) {
    if (vm.isLoading) {
      return _buildLoadingState();
    }
    if (vm.doctors.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: vm.doctors.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final doctor = vm.doctors[index];
        return _DoctorCard(
          doctor: doctor,
          onViewProfile: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => DoctorInfoPage(doctor: doctor)),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: 3,
      itemBuilder: (context, index) => const _ShimmerCard(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppTheme.captionTextColor,
            ),
            SizedBox(height: 12),
            Text(
              'No doctors match your filters right now.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.captionTextColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback onViewProfile;
  const _DoctorCard({required this.doctor, required this.onViewProfile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: DoctorUIHelpers.softShadow(blur: 18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryLight, width: 3),
            ),
            child: CircleAvatar(
              radius: 42,
              backgroundImage: NetworkImage(doctor.imageUrl),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.bodyTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    doctor.specialty,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      final filled = doctor.rating >= index + 1;
                      final halfFilled =
                          doctor.rating > index && doctor.rating < index + 1;
                      return Icon(
                        filled
                            ? Icons.star_rounded
                            : halfFilled
                            ? Icons.star_half_rounded
                            : Icons.star_outline_rounded,
                        size: 18,
                        color: AppTheme.primaryColor,
                      );
                    }),
                    const SizedBox(width: 6),
                    Text(
                      '${doctor.rating.toStringAsFixed(1)} • ${doctor.reviewCount}+ reviews',
                      style: const TextStyle(color: AppTheme.captionTextColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onViewProfile,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text('View Profile'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.favorite_border,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard();

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 0.9).animate(_controller),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: DoctorUIHelpers.softShadow(blur: 14),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: _placeholderDecoration(),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 12,
                    width: MediaQuery.of(context).size.width * 0.4,
                    decoration: _placeholderDecoration(),
                  ),
                  const SizedBox(height: 16),
                  Container(height: 36, decoration: _placeholderDecoration()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _placeholderDecoration() {
    return BoxDecoration(
      color: AppTheme.primaryLight,
      borderRadius: BorderRadius.circular(12),
    );
  }
}
