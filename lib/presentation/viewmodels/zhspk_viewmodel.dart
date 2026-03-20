import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/zhspk_response.dart';
import '../../domain/repositories/zhspk_repository.dart';
import 'login_viewmodel.dart';

class ZhspkState {
  final List<ZhspkResponse> items;
  final bool isLoading;
  final String? error;

  ZhspkState({this.items = const [], this.isLoading = false, this.error});

  ZhspkState copyWith({
    List<ZhspkResponse>? items,
    bool? isLoading,
    String? error,
  }) {
    return ZhspkState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ZhspkViewModel extends StateNotifier<ZhspkState> {
  final ZhspkRepository _repository;

  ZhspkViewModel(this._repository) : super(ZhspkState());

  Future<void> loadZhspk() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final items = await _repository.getZhspkList();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<String> createZhspk(String name) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final String zhspkId = await _repository.createZhspk(name);
      state = state.copyWith(isLoading: false); // <-- Добавь сброс загрузки
      return zhspkId;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      throw e; // <-- Бросай ошибку, а не возвращай пустую строку
    }
  }

  Future<Map<String, String>> createChairPerson(
      String zhspkId,
      String lastName,
      String firstName,) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final credentials = await _repository.createChairPerson(
        zhspkId,
        lastName,
        firstName,
        //patronymic,
      );

      // Reload list to show new ZHSPK with chairman
      //await loadZhspk();
      state = state.copyWith(isLoading: false); // <-- Добавь сброс загрузки
      return credentials; // Return the map with login/password
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      throw e;
    }
  }
}

final zhspkViewModelProvider =
    StateNotifierProvider<ZhspkViewModel, ZhspkState>((ref) {
      return ZhspkViewModel(ref.watch(zhspkRepositoryProvider));
    });
