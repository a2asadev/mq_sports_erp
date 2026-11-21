import 'package:a2_stocks/models/branch_model.dart';
import 'package:a2_stocks/online/api_client.dart';

/// Adding and changing branches (`/v1/branches`, admin only, needs a connection). They come back through the sync.
class BranchesService {
  BranchesService(this._api);

  final ApiClient _api;

  Map<String, dynamic> _body({required String name, String code = '', String address = '', String phone = ''}) =>
      <String, dynamic>{'name': name.trim(), 'code': code.trim(), 'address': address.trim(), 'phone': phone.trim()};

  Future<BranchModel> create({required String name, String code = '', String address = '', String phone = ''}) async =>
      BranchModel.fromMap((await _api.post('/v1/branches', body: _body(name: name, code: code, address: address, phone: phone))).asMap);

  Future<BranchModel> update(String id, {required String name, String code = '', String address = '', String phone = ''}) async =>
      BranchModel.fromMap((await _api.patch('/v1/branches/$id', body: _body(name: name, code: code, address: address, phone: phone))).asMap);

  Future<BranchModel> setActive(String id, bool on) async => BranchModel.fromMap((await _api.patch('/v1/branches/$id', body: <String, dynamic>{'isActive': on})).asMap);

  /// Switches the business's use of branches on or off (`PUT /v1/business`).
  Future<void> setUsesBranches(bool on) async {
    await _api.put('/v1/business', body: <String, dynamic>{'usesBranches': on});
  }
}
