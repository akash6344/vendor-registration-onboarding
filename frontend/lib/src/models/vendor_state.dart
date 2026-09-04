import 'service_detail.dart';

class VendorState {
  VendorState({
    required this.accountStatus,
    required this.mainCategoryId,
    required this.vendorType,
    required this.subcategoryIds,
    required this.serviceIds,
    required this.serviceDetails,
    required this.personalInfo,
    required this.address,
    required this.workingHours,
    required this.businessInfo,
    required this.documents,
    required this.verificationStatus,
    required this.selectedPlanId,
    required this.currentStep,
  });

  final String accountStatus;
  final String? mainCategoryId;
  final String? vendorType;
  final List<String> subcategoryIds;
  final List<String> serviceIds;
  final Map<String, ServiceDetail> serviceDetails;
  final Map<String, String> personalInfo;
  final Map<String, String> address;
  final Map<String, dynamic> workingHours;
  final Map<String, String> businessInfo;
  final Map<String, List<String>> documents;
  final String verificationStatus;
  final String? selectedPlanId;
  final String currentStep;

  bool get isActive => accountStatus == 'ACTIVE';

  factory VendorState.empty() {
    return VendorState(
      accountStatus: 'DRAFT',
      mainCategoryId: null,
      vendorType: null,
      subcategoryIds: [],
      serviceIds: [],
      serviceDetails: {},
      personalInfo: {},
      address: {},
      workingHours: {'startTime': '09:00', 'endTime': '18:00', 'available': true},
      businessInfo: {},
      documents: {},
      verificationStatus: 'PENDING',
      selectedPlanId: null,
      currentStep: 'WELCOME',
    );
  }

  factory VendorState.fromJson(Map<String, dynamic> json) {
    final verification = Map<String, dynamic>.from(json['verification'] ?? {});
    return VendorState(
      accountStatus: json['accountStatus'] ?? 'DRAFT',
      mainCategoryId: json['mainCategoryId'],
      vendorType: json['vendorType'],
      subcategoryIds: List<String>.from(json['subcategoryIds'] ?? []),
      serviceIds: List<String>.from(json['serviceIds'] ?? []),
      serviceDetails: (json['serviceDetails'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, ServiceDetail.fromJson(Map<String, dynamic>.from(value))),
      ),
      personalInfo: Map<String, String>.from(json['personalInfo'] ?? {}),
      address: Map<String, String>.from(json['address'] ?? {}),
      workingHours: Map<String, dynamic>.from(json['workingHours'] ?? {'startTime': '09:00', 'endTime': '18:00', 'available': true}),
      businessInfo: Map<String, String>.from(verification['businessInfo'] ?? {}),
      documents: (verification['documents'] as Map<String, dynamic>? ?? {}).map((key, value) => MapEntry(key, List<String>.from(value))),
      verificationStatus: verification['status'] ?? 'PENDING',
      selectedPlanId: json['subscription']?['planId'],
      currentStep: json['currentStep'] ?? 'WELCOME',
    );
  }

  VendorState copyWith({
    String? accountStatus,
    String? mainCategoryId,
    String? vendorType,
    List<String>? subcategoryIds,
    List<String>? serviceIds,
    Map<String, ServiceDetail>? serviceDetails,
    Map<String, String>? personalInfo,
    Map<String, String>? address,
    Map<String, dynamic>? workingHours,
    Map<String, String>? businessInfo,
    Map<String, List<String>>? documents,
    String? verificationStatus,
    String? selectedPlanId,
    String? currentStep,
  }) {
    return VendorState(
      accountStatus: accountStatus ?? this.accountStatus,
      mainCategoryId: mainCategoryId ?? this.mainCategoryId,
      vendorType: vendorType ?? this.vendorType,
      subcategoryIds: subcategoryIds ?? this.subcategoryIds,
      serviceIds: serviceIds ?? this.serviceIds,
      serviceDetails: serviceDetails ?? this.serviceDetails,
      personalInfo: personalInfo ?? this.personalInfo,
      address: address ?? this.address,
      workingHours: workingHours ?? this.workingHours,
      businessInfo: businessInfo ?? this.businessInfo,
      documents: documents ?? this.documents,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      selectedPlanId: selectedPlanId ?? this.selectedPlanId,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountStatus': accountStatus,
      'mainCategoryId': mainCategoryId,
      'vendorType': vendorType,
      'subcategoryIds': subcategoryIds,
      'serviceIds': serviceIds,
      'serviceDetails': serviceDetails.map((key, value) => MapEntry(key, value.toJson())),
      'personalInfo': personalInfo,
      'address': address,
      'workingHours': workingHours,
      'verification': {
        'status': verificationStatus,
        'businessInfo': businessInfo,
        'documents': documents,
      },
      'subscription': selectedPlanId == null ? null : {'planId': selectedPlanId},
      'currentStep': currentStep,
    };
  }
}
