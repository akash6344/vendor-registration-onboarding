class Dashboard {
  Dashboard({
    required this.accountStatus,
    required this.verificationStatus,
    required this.serviceCount,
    required this.availability,
    this.planName,
    this.validUntil,
  });

  final String accountStatus;
  final String verificationStatus;
  final int serviceCount;
  final bool availability;
  final String? planName;
  final String? validUntil;

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      accountStatus: json['accountStatus'],
      verificationStatus: json['verificationStatus'],
      serviceCount: json['serviceCount'],
      availability: json['availability'],
      planName: json['plan']?['name'],
      validUntil: json['validUntil'],
    );
  }
}
