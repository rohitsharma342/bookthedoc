enum AppointmentStatus {
  upcoming,
  completed,
  cancelled,
  rescheduled
}

class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorImage;
  final DateTime dateTime;
  final AppointmentStatus status;
  final double fee;
  final String type;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorImage,
    required this.dateTime,
    required this.status,
    required this.fee,
    required this.type,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      doctorId: json['doctorId'],
      doctorName: json['doctorName'],
      doctorSpecialty: json['doctorSpecialty'],
      doctorImage: json['doctorImage'],
      dateTime: DateTime.parse(json['dateTime']),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString() == 'AppointmentStatus.${json['status']}'
      ),
      fee: json['fee'].toDouble(),
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'doctorImage': doctorImage,
      'dateTime': dateTime.toIso8601String(),
      'status': status.toString().split('.').last,
      'fee': fee,
      'type': type,
    };
  }
}