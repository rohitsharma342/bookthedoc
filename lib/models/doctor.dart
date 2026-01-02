class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String qualification;
  final double rating;
  final int reviewCount;
  final double consultationFee;
  final String imageUrl;
  final String location;
  final List<String> availableSlots;
  final String about;
  final int experience;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.qualification,
    required this.rating,
    required this.reviewCount,
    required this.consultationFee,
    required this.imageUrl,
    required this.location,
    required this.availableSlots,
    required this.about,
    required this.experience,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'],
      specialty: json['specialty'],
      qualification: json['qualification'],
      rating: json['rating'].toDouble(),
      reviewCount: json['reviewCount'],
      consultationFee: json['consultationFee'].toDouble(),
      imageUrl: json['imageUrl'],
      location: json['location'],
      availableSlots: List<String>.from(json['availableSlots']),
      about: json['about'],
      experience: json['experience'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'qualification': qualification,
      'rating': rating,
      'reviewCount': reviewCount,
      'consultationFee': consultationFee,
      'imageUrl': imageUrl,
      'location': location,
      'availableSlots': availableSlots,
      'about': about,
      'experience': experience,
    };
  }
}