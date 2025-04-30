class WorkerProfile {
  final String uid;
  final String username;
  final String role;
  final String personalInfo;
  final String skills;
  final String workHistory;
  final String experience;
  final String location;
  final String availability;

  WorkerProfile({
    required this.uid,
    required this.username,
    required this.role,
    required this.personalInfo,
    required this.skills,
    required this.workHistory,
    required this.experience,
    required this.location,
    required this.availability,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'role': role,
      'personalInfo': personalInfo,
      'skills': skills,
      'workHistory': workHistory,
      'experience': experience,
      'location': location,
      'availability': availability,
    };
  }

  factory WorkerProfile.fromMap(Map<String, dynamic> map) {
    return WorkerProfile(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      role: map['role'] ?? '',
      personalInfo: map['personalInfo'] ?? '',
      skills: map['skills'] ?? '',
      workHistory: map['workHistory'] ?? '',
      experience: map['experience'] ?? '',
      location: map['location'] ?? '',
      availability: map['availability'] ?? '',
    );
  }
}
