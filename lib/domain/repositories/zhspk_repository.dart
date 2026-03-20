import '../../data/models/zhspk_response.dart';
import '../../data/services/zhspk_service.dart';

class ZhspkRepository {
  final ZhspkService _service;

  ZhspkRepository(this._service);

  Future<List<ZhspkResponse>> getZhspkList() async {
    return await _service.getZhspkList();
  }

  Future<String> createZhspk(String name) async {
    return await _service.createZhspk(name);
  }

  Future<Map<String, String>> createChairPerson(
    String zhspkId,
    String lastName,
    String firstName,
  ) async {
    return await _service.createChairperson(zhspkId, lastName, firstName);
  }
}
