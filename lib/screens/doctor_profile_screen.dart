import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/data_service.dart';
import '../models/doctor.dart';
import '../utils/constants.dart';
import 'package:intl/intl.dart';

class DoctorProfileScreen extends StatefulWidget {
  final String doctorId;

  const DoctorProfileScreen({Key? key, required this.doctorId}) : super(key: key);

  @override
  _DoctorProfileScreenState createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  DateTime _selectedDay = DateTime.now();
  String? _selectedTimeSlot;
  String _selectedConsultationType = 'In-person';

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        final doctor = dataService.getDoctorById(widget.doctorId);

        if (doctor == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Doctor Not Found')),
            body: const Center(
              child: Text('Doctor not found'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Doctor Profile'),
            actions: [
              IconButton(
                icon: Icon(
                  dataService.isDoctorSaved(doctor.id)
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: dataService.isDoctorSaved(doctor.id)
                      ? AppConstants.primaryColor
                      : null,
                ),
                onPressed: () {
                  dataService.toggleSaveDoctor(doctor);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDoctorHeader(doctor),
                      _buildDoctorDetails(doctor),
                      _buildAppointmentBooking(doctor),
                      _buildReviewsSection(),
                    ],
                  ),
                ),
              ),
              _buildBookingButton(doctor, dataService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDoctorHeader(Doctor doctor) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: doctor.imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 100,
                height: 100,
                color: AppConstants.backgroundColor,
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: AppConstants.textSecondary,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 100,
                height: 100,
                color: AppConstants.backgroundColor,
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: AppConstants.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialty,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.qualification,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    RatingBar.builder(
                      initialRating: doctor.rating,
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 16,
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {},
                      ignoreGestures: true,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${doctor.rating} (${doctor.reviewCount} reviews)',
                      style: Theme.of(context).textTheme.bodySmall,
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

  Widget _buildDoctorDetails(Doctor doctor) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About Dr. ${doctor.name}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(
                doctor.about,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Experience',
                      '${doctor.experience} years',
                      Icons.work_outline,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Location',
                      doctor.location,
                      Icons.location_on_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Consultation Fee',
                      '\$${doctor.consultationFee.toStringAsFixed(0)}',
                      Icons.payments_outlined,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Patients',
                      '${doctor.reviewCount * 5}+',
                      Icons.people_outline,
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

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppConstants.primaryColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }

  Widget _buildAppointmentBooking(Doctor doctor) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Book Appointment',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Consultation Type',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: AppConstants.consultationTypes.map(
                  (type) => FilterChip(
                    label: Text(type),
                    selected: _selectedConsultationType == type,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedConsultationType = type;
                        });
                      }
                    },
                    selectedColor: AppConstants.primaryColor.withOpacity(0.2),
                    checkmarkColor: AppConstants.primaryColor,
                  ),
                ).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                'Select Date',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 30)),
                focusedDay: _selectedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _selectedTimeSlot = null;
                  });
                },
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Available Time Slots',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: doctor.availableSlots.map(
                  (slot) => FilterChip(
                    label: Text(slot),
                    selected: _selectedTimeSlot == slot,
                    onSelected: (selected) {
                      setState(() {
                        _selectedTimeSlot = selected ? slot : null;
                      });
                    },
                    selectedColor: AppConstants.primaryColor.withOpacity(0.2),
                    checkmarkColor: AppConstants.primaryColor,
                  ),
                ).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Patient Reviews',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildReviewItem(
                'Sarah Williams',
                'Excellent doctor! Very professional and caring.',
                5.0,
                '2 days ago',
              ),
              const Divider(),
              _buildReviewItem(
                'Michael Johnson',
                'Great consultation, highly recommended.',
                4.0,
                '1 week ago',
              ),
              const Divider(),
              _buildReviewItem(
                'Emily Davis',
                'Very knowledgeable and patient with questions.',
                5.0,
                '2 weeks ago',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewItem(String name, String review, double rating, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                child: Text(
                  name[0],
                  style: const TextStyle(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const Spacer(),
                        Text(
                          date,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        RatingBar.builder(
                          initialRating: rating,
                          minRating: 0,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemSize: 12,
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {},
                          ignoreGestures: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingButton(Doctor doctor, DataService dataService) {
    final isSlotSelected = _selectedTimeSlot != null;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Consultation Fee',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '\$${doctor.consultationFee.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSlotSelected ? () => _bookAppointment(doctor, dataService) : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: isSlotSelected
                    ? AppConstants.primaryColor
                    : AppConstants.textSecondary,
              ),
              child: Text(
                isSlotSelected
                    ? 'Book Appointment'
                    : 'Select Time Slot',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _bookAppointment(Doctor doctor, DataService dataService) {
    if (_selectedTimeSlot == null) return;

    final appointmentDateTime = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      int.parse(_selectedTimeSlot!.split(':')[0]),
      int.parse(_selectedTimeSlot!.split(':')[1].split(' ')[0]),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Doctor: ${doctor.name}'),
            Text('Date: ${DateFormat('MMM dd, yyyy').format(_selectedDay)}'),
            Text('Time: $_selectedTimeSlot'),
            Text('Type: $_selectedConsultationType'),
            Text('Fee: \$${doctor.consultationFee.toStringAsFixed(0)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              dataService.bookAppointment(
                doctor.id,
                appointmentDateTime,
                _selectedConsultationType,
              );
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment booked successfully!'),
                  backgroundColor: AppConstants.successColor,
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}