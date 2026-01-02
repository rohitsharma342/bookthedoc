import 'package:flutter/foundation.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import '../models/user.dart';
import 'supabase_service.dart';

class DataService extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  List<Doctor> _doctors = [];
  List<Appointment> _appointments = [];
  User? _currentUser;
  List<Doctor> _savedDoctors = [];
  String _searchQuery = '';
  String _selectedSpecialty = '';
  String _sortBy = 'rating';
  bool _isLoading = false;
  String _error = '';

  List<Doctor> get doctors => _doctors;
  List<Appointment> get appointments => _appointments;
  User? get currentUser => _currentUser;
  List<Doctor> get savedDoctors => _savedDoctors;
  String get searchQuery => _searchQuery;
  String get selectedSpecialty => _selectedSpecialty;
  String get sortBy => _sortBy;
  bool get isLoading => _isLoading;
  String get error => _error;

  DataService() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchDoctors();
    await fetchCurrentUser();
    if (_currentUser != null) {
      await fetchUserAppointments();
      await fetchSavedDoctors();
    }
  }

  Future<void> fetchDoctors() async {
    try {
      _setLoading(true);
      _setError('');
      
      final response = await _supabaseService.fetchData('doctors', orderBy: 'rating', ascending: false);
      _doctors = response.map((json) => Doctor.fromJson(json)).toList();
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch doctors: $e');
      print('Error fetching doctors: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      final currentUser = _supabaseService.getCurrentUser();
      if (currentUser != null) {
        final userProfile = await _supabaseService.fetchById('user_profiles', currentUser.id);
        if (userProfile != null) {
          _currentUser = User.fromJson(userProfile);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error fetching current user: $e');
    }
  }

  Future<void> fetchUserAppointments() async {
    if (_currentUser == null) return;
    
    try {
      final response = await _supabaseService.fetchUserAppointments(_currentUser!.id);
      _appointments = response.map((json) => Appointment.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching appointments: $e');
    }
  }

  Future<void> fetchSavedDoctors() async {
    if (_currentUser == null) return;
    
    try {
      final response = await _supabaseService.fetchUserSavedDoctors(_currentUser!.id);
      _savedDoctors = response
          .map((json) => Doctor.fromJson(json['doctors']))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching saved doctors: $e');
    }
  }

  Future<List<Doctor>> getFilteredDoctors() async {
    try {
      final response = await _supabaseService.searchDoctors(
        query: _searchQuery,
        specialty: _selectedSpecialty,
        sortBy: _sortBy,
      );
      
      return response.map((json) => Doctor.fromJson(json)).toList();
    } catch (e) {
      print('Error filtering doctors: $e');
      return [];
    }
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

  Future<void> toggleSaveDoctor(Doctor doctor) async {
    if (_currentUser == null) return;
    
    try {
      final isCurrentlySaved = _savedDoctors.any((d) => d.id == doctor.id);
      
      if (isCurrentlySaved) {
        // Remove from saved
        await _supabaseService.client
            .from('saved_doctors')
            .delete()
            .eq('user_id', _currentUser!.id)
            .eq('doctor_id', doctor.id);
        
        _savedDoctors.removeWhere((d) => d.id == doctor.id);
      } else {
        // Add to saved
        await _supabaseService.insertData('saved_doctors', {
          'user_id': _currentUser!.id,
          'doctor_id': doctor.id,
        });
        
        _savedDoctors.add(doctor);
      }
      
      notifyListeners();
    } catch (e) {
      print('Error toggling saved doctor: $e');
    }
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

  Future<void> bookAppointment(String doctorId, DateTime dateTime, String type) async {
    if (_currentUser == null) return;
    
    try {
      final doctor = getDoctorById(doctorId);
      if (doctor == null) return;
      
      final appointmentData = {
        'user_id': _currentUser!.id,
        'doctor_id': doctorId,
        'doctor_name': doctor.name,
        'doctor_specialty': doctor.specialty,
        'doctor_image': doctor.imageUrl,
        'date_time': dateTime.toIso8601String(),
        'status': 'upcoming',
        'fee': doctor.consultationFee,
        'appointment_type': type,
      };
      
      await _supabaseService.insertData('appointments', appointmentData);
      await fetchUserAppointments();
    } catch (e) {
      print('Error booking appointment: $e');
      rethrow;
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _supabaseService.updateData('appointments', appointmentId, {
        'status': 'cancelled',
      });
      
      await fetchUserAppointments();
    } catch (e) {
      print('Error cancelling appointment: $e');
      rethrow;
    }
  }

  Future<void> updateUser(User user) async {
    try {
      await _supabaseService.updateData('user_profiles', user.id, user.toJson());
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  List<Appointment> getUpcomingAppointments() {
    return _appointments.where((apt) => apt.status == AppointmentStatus.upcoming).toList();
  }

  List<Appointment> getPastAppointments() {
    return _appointments.where((apt) => apt.status != AppointmentStatus.upcoming).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await _initializeData();
  }
}