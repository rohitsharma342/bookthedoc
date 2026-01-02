import 'package:flutter/foundation.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import '../models/user.dart';

class DataService extends ChangeNotifier {
  List<Doctor> _doctors = [];
  List<Appointment> _appointments = [];
  User? _currentUser;
  List<Doctor> _savedDoctors = [];
  String _searchQuery = '';
  String _selectedSpecialty = '';
  String _sortBy = 'rating';

  List<Doctor> get doctors => _doctors;
  List<Appointment> get appointments => _appointments;
  User? get currentUser => _currentUser;
  List<Doctor> get savedDoctors => _savedDoctors;
  String get searchQuery => _searchQuery;
  String get selectedSpecialty => _selectedSpecialty;
  String get sortBy => _sortBy;

  DataService() {
    _initializeData();
  }

  void _initializeData() {
    _doctors = [
      Doctor(
        id: '1',
        name: 'Dr. Sarah Johnson',
        specialty: 'Cardiology',
        qualification: 'MBBS, MD Cardiology',
        rating: 4.8,
        reviewCount: 156,
        consultationFee: 150.0,
        imageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=300&h=300&fit=crop',
        location: 'New York, NY',
        availableSlots: ['09:00 AM', '10:30 AM', '02:00 PM', '04:30 PM'],
        about: 'Experienced cardiologist with over 15 years of practice.',
        experience: 15,
      ),
      Doctor(
        id: '2',
        name: 'Dr. Michael Chen',
        specialty: 'Dermatology',
        qualification: 'MBBS, MD Dermatology',
        rating: 4.7,
        reviewCount: 89,
        consultationFee: 120.0,
        imageUrl: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=300&h=300&fit=crop',
        location: 'Los Angeles, CA',
        availableSlots: ['11:00 AM', '01:00 PM', '03:30 PM', '05:00 PM'],
        about: 'Specialist in skin conditions and cosmetic dermatology.',
        experience: 12,
      ),
      Doctor(
        id: '3',
        name: 'Dr. Emily Rodriguez',
        specialty: 'Pediatrics',
        qualification: 'MBBS, MD Pediatrics',
        rating: 4.9,
        reviewCount: 234,
        consultationFee: 100.0,
        imageUrl: 'https://images.unsplash.com/photo-1594824371259-91e21a8c7c04?w=300&h=300&fit=crop',
        location: 'Chicago, IL',
        availableSlots: ['08:30 AM', '10:00 AM', '01:30 PM', '03:00 PM'],
        about: 'Dedicated pediatrician with expertise in child healthcare.',
        experience: 10,
      ),
      Doctor(
        id: '4',
        name: 'Dr. David Wilson',
        specialty: 'Neurology',
        qualification: 'MBBS, DM Neurology',
        rating: 4.6,
        reviewCount: 112,
        consultationFee: 200.0,
        imageUrl: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=300&h=300&fit=crop',
        location: 'Houston, TX',
        availableSlots: ['09:30 AM', '11:30 AM', '02:30 PM', '04:00 PM'],
        about: 'Neurologist specializing in brain and nervous system disorders.',
        experience: 18,
      ),
      Doctor(
        id: '5',
        name: 'Dr. Lisa Thompson',
        specialty: 'Orthopedics',
        qualification: 'MBBS, MS Orthopedics',
        rating: 4.5,
        reviewCount: 67,
        consultationFee: 180.0,
        imageUrl: 'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=300&h=300&fit=crop',
        location: 'Miami, FL',
        availableSlots: ['08:00 AM', '10:30 AM', '01:00 PM', '03:30 PM'],
        about: 'Orthopedic surgeon with expertise in joint replacements.',
        experience: 14,
      ),
    ];

    _appointments = [
      Appointment(
        id: 'apt1',
        doctorId: '1',
        doctorName: 'Dr. Sarah Johnson',
        doctorSpecialty: 'Cardiology',
        doctorImage: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=300&h=300&fit=crop',
        dateTime: DateTime.now().add(const Duration(days: 2)),
        status: AppointmentStatus.upcoming,
        fee: 150.0,
        type: 'In-person',
      ),
      Appointment(
        id: 'apt2',
        doctorId: '3',
        doctorName: 'Dr. Emily Rodriguez',
        doctorSpecialty: 'Pediatrics',
        doctorImage: 'https://images.unsplash.com/photo-1594824371259-91e21a8c7c04?w=300&h=300&fit=crop',
        dateTime: DateTime.now().add(const Duration(days: 5)),
        status: AppointmentStatus.upcoming,
        fee: 100.0,
        type: 'Video Call',
      ),
    ];

    _currentUser = User(
      id: 'user1',
      name: 'John Doe',
      email: 'john.doe@email.com',
      phone: '+1-555-0123',
      profileImage: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=300&fit=crop',
      insurance: 'Blue Cross Blue Shield',
      dateOfBirth: DateTime(1990, 5, 15),
    );

    _savedDoctors = [_doctors[0], _doctors[2]];
  }

  List<Doctor> getFilteredDoctors() {
    List<Doctor> filtered = List.from(_doctors);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((doctor) {
        return doctor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               doctor.specialty.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_selectedSpecialty.isNotEmpty && _selectedSpecialty != 'All') {
      filtered = filtered.where((doctor) => doctor.specialty == _selectedSpecialty).toList();
    }

    switch (_sortBy) {
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'price_low':
        filtered.sort((a, b) => a.consultationFee.compareTo(b.consultationFee));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.consultationFee.compareTo(a.consultationFee));
        break;
    }

    return filtered;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSpecialtyFilter(String specialty) {
    _selectedSpecialty = specialty;
    notifyListeners();
  }

  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  void toggleSaveDoctor(Doctor doctor) {
    if (_savedDoctors.any((d) => d.id == doctor.id)) {
      _savedDoctors.removeWhere((d) => d.id == doctor.id);
    } else {
      _savedDoctors.add(doctor);
    }
    notifyListeners();
  }

  bool isDoctorSaved(String doctorId) {
    return _savedDoctors.any((d) => d.id == doctorId);
  }

  Doctor? getDoctorById(String id) {
    try {
      return _doctors.firstWhere((doctor) => doctor.id == id);
    } catch (e) {
      return null;
    }
  }

  void bookAppointment(String doctorId, DateTime dateTime, String type) {
    final doctor = getDoctorById(doctorId);
    if (doctor != null) {
      final appointment = Appointment(
        id: 'apt${_appointments.length + 1}',
        doctorId: doctorId,
        doctorName: doctor.name,
        doctorSpecialty: doctor.specialty,
        doctorImage: doctor.imageUrl,
        dateTime: dateTime,
        status: AppointmentStatus.upcoming,
        fee: doctor.consultationFee,
        type: type,
      );
      _appointments.add(appointment);
      notifyListeners();
    }
  }

  void cancelAppointment(String appointmentId) {
    final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
    if (index != -1) {
      _appointments[index] = Appointment(
        id: _appointments[index].id,
        doctorId: _appointments[index].doctorId,
        doctorName: _appointments[index].doctorName,
        doctorSpecialty: _appointments[index].doctorSpecialty,
        doctorImage: _appointments[index].doctorImage,
        dateTime: _appointments[index].dateTime,
        status: AppointmentStatus.cancelled,
        fee: _appointments[index].fee,
        type: _appointments[index].type,
      );
      notifyListeners();
    }
  }

  void updateUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  List<Appointment> getUpcomingAppointments() {
    return _appointments.where((apt) => apt.status == AppointmentStatus.upcoming).toList();
  }

  List<Appointment> getPastAppointments() {
    return _appointments.where((apt) => apt.status != AppointmentStatus.upcoming).toList();
  }
}