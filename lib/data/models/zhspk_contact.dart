class ZhspkContact {
  final int zhspkContactsId;
  final String position;
  final String fullName;
  final String phoneNumber;

  ZhspkContact({
    required this.zhspkContactsId,
    required this.position,
    required this.fullName,
    required this.phoneNumber,
  });

  factory ZhspkContact.fromJson(Map<String, dynamic> json) {
    return ZhspkContact(
      zhspkContactsId: json['zhspk_contacts_id'] ?? 0,
      position: json['position'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
    );
  }
}