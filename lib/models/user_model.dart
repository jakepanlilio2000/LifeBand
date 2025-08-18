class UserModel {
  final bool fallAlertActive;
  final String fallLastUpdated;
  final String emergencyContactName;
  final int emergencyContactPhone;
  final String latitude;
  final String longitude;
  final String address; // Add the new address property
  final bool fallDetected;
  final String motionLastUpdated;
  final int currentHeartRate;
  final String heartRateLastUpdated;
  final bool sosActive;
  final String sosLastUpdated;
  final String profileName;
  final int profileAge;
  final String profileSex;

  UserModel({
    required this.fallAlertActive,
    required this.fallLastUpdated,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.latitude,
    required this.longitude,
    required this.address, // Add to the constructor
    required this.fallDetected,
    required this.motionLastUpdated,
    required this.currentHeartRate,
    required this.heartRateLastUpdated,
    required this.sosActive,
    required this.sosLastUpdated,
    required this.profileName,
    required this.profileAge,
    required this.profileSex,
  });

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    final userMap = map['user'];
    return UserModel(
      fallAlertActive: userMap['alerts']['fall']['active'] ?? ['Inactive'],
      fallLastUpdated: userMap['alerts']['fall']['lastUpdated'] ?? 'N/A',
      emergencyContactName: userMap['emergencyContact']['contact']['name'] ?? 'N/A',
      emergencyContactPhone: userMap['emergencyContact']['contact']['phone'] ?? 0,
      latitude: userMap['location']['latitude'] ?? 'N/A',
      longitude: userMap['location']['longitude'] ?? 'N/A',
      address: userMap['location']['address'] ?? 'N/A', // Parse the new address key
      fallDetected: userMap['motion']['fallDetected'] ?? false,
      motionLastUpdated: userMap['motion']['lastUpdated'] ?? 'N/A',
      currentHeartRate: userMap['sensor']['heartrate']['current'] ?? 0,
      heartRateLastUpdated: userMap['sensor']['heartrate']['lastUpdated'] ?? 'N/A',
      sosActive: userMap['sos']['active'] ?? false,
      sosLastUpdated: userMap['sos']['lastUpdated'] ?? 'N/A',
      profileName: userMap['profile']['name'] ?? 'N/A',
      profileAge: userMap['profile']['age'] ?? 0,
      profileSex: userMap['profile']['sex'] ?? 'N/A',
    );
  }
}