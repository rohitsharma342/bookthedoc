import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../utils/constants.dart';
import '../widgets/doctor_card.dart';
import 'doctor_profile_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSpecialty = 'All';
  String _selectedSortBy = 'rating';

  @override
  void initState() {
    super.initState();
    final dataService = context.read<DataService>();
    _searchController.text = dataService.searchQuery;
    _selectedSpecialty = dataService.selectedSpecialty.isEmpty 
        ? 'All' 
        : dataService.selectedSpecialty;
    _selectedSortBy = dataService.sortBy;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Doctors'),
        elevation: 1,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppConstants.textSecondary.withOpacity(0.3),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search doctors, specialties...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppConstants.textSecondary,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                context.read<DataService>().setSearchQuery('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      context.read<DataService>().setSearchQuery(value);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showFiltersModal,
                        icon: const Icon(Icons.tune, size: 18),
                        label: Text(
                          _selectedSpecialty == 'All' 
                              ? 'Filters' 
                              : _selectedSpecialty,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedSpecialty != 'All'
                              ? AppConstants.primaryColor
                              : AppConstants.backgroundColor,
                          foregroundColor: _selectedSpecialty != 'All'
                              ? Colors.white
                              : AppConstants.textPrimary,
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSortBy,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'rating',
                            child: Text('Highest Rated'),
                          ),
                          DropdownMenuItem(
                            value: 'price_low',
                            child: Text('Price: Low to High'),
                          ),
                          DropdownMenuItem(
                            value: 'price_high',
                            child: Text('Price: High to Low'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedSortBy = value;
                            });
                            context.read<DataService>().setSortBy(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<DataService>(
              builder: (context, dataService, child) {
                return FutureBuilder(
                  future: dataService.getFilteredDoctors(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    
                    final filteredDoctors = snapshot.data ?? [];

                    if (filteredDoctors.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: AppConstants.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No doctors found',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppConstants.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search filters',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredDoctors.length,
                      itemBuilder: (context, index) {
                        final doctor = filteredDoctors[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DoctorCard(
                            doctor: doctor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DoctorProfileScreen(
                                    doctorId: doctor.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFiltersModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filters',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedSpecialty = 'All';
                          });
                          context.read<DataService>().setSpecialtyFilter('');
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Specialty',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['All', ...AppConstants.specialties].map(
                      (specialty) => FilterChip(
                        label: Text(specialty),
                        selected: _selectedSpecialty == specialty,
                        onSelected: (selected) {
                          setModalState(() {
                            _selectedSpecialty = specialty;
                          });
                        },
                        selectedColor: AppConstants.primaryColor.withOpacity(0.2),
                        checkmarkColor: AppConstants.primaryColor,
                      ),
                    ).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Consultation Type',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.consultationTypes.map(
                      (type) => FilterChip(
                        label: Text(type),
                        selected: false,
                        onSelected: (selected) {},
                      ),
                    ).toList(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        context.read<DataService>().setSpecialtyFilter(
                          _selectedSpecialty == 'All' ? '' : _selectedSpecialty,
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).viewInsets.bottom,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}