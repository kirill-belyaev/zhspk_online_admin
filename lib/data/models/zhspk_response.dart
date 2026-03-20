import 'zhspk_contact.dart';

class ZhspkResponse {
  final int zhspkId;
  final String zhspkName;
  final double totalSquare;
  final String logo;
  final List<ZhspkContact> contacts;

  ZhspkResponse({
    required this.zhspkId,
    required this.zhspkName,
    required this.totalSquare,
    required this.logo,
    required this.contacts,
  });

  factory ZhspkResponse.fromJson(Map<String, dynamic> json) {
    return ZhspkResponse(
      zhspkId: json['zhspk_id'] ?? 0,
      zhspkName: json['zhspk_name'] ?? '',
      totalSquare: (json['total_square'] ?? 0).toDouble(),
      logo: json['logo'] ?? '',
      contacts: (json['contacts'] as List<dynamic>?)
          ?.map((e) => ZhspkContact.fromJson(e))
          .toList() ??
          [],
    );
  }
}