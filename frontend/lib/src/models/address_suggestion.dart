class AddressSuggestion {
  AddressSuggestion({
    required this.label,
    required this.fullAddress,
    required this.city,
    required this.state,
    required this.pincode,
  });

  final String label;
  final String fullAddress;
  final String city;
  final String state;
  final String pincode;

  factory AddressSuggestion.fromJson(Map<String, dynamic> json) {
    return AddressSuggestion(
      label: json['label'],
      fullAddress: json['fullAddress'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
    );
  }
}
