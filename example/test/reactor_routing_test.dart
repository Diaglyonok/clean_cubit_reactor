import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:clean_cubit_reactor/clean_cubit_reactor.dart';

// ---------------- Test doubles ----------------

enum TestListenersType { load, update }

abstract class TestBaseResponse extends ReactorResponse<TestListenersType> {}

class TestLoadResponse extends TestBaseResponse {
  final List<int>? data;
  final Object? error;
  TestLoadResponse({this.data, this.error});
  @override
  TestListenersType get type => TestListenersType.load;
}

class TestUpdateResponse extends TestBaseResponse {
  final int? updatedId;
  final Object? error;
  TestUpdateResponse({this.updatedId, this.error});
  @override
  TestListenersType get type => TestListenersType.update;
}

class TestReactor with Reactor<TestListenersType, TestBaseResponse> {
  void emitLoad(List<int> data) {
    provideDataToListeners(TestLoadResponse(data: data));
  }

  void emitLoadError(Object error) {
    provideDataToListeners(TestLoadResponse(error: error));
  }

  void emitUpdate({int? id, Object? error}) {
    provideDataToListeners(TestUpdateResponse(updatedId: id, error: error));
  }

  void setLoadLoadingSnapshot({List<int>? last}) {
    setLoading(currentData: TestLoadResponse(data: last));
  }
}

// States for load cubit
sealed class LoadCubitState {
  const LoadCubitState();
}

class LoadCubitInit extends LoadCubitState {
  const LoadCubitInit();
}

class LoadCubitShimmer extends LoadCubitState {
  final List<int>? lastData;
  const LoadCubitShimmer({this.lastData});
}

class LoadCubitHasData extends LoadCubitState {
  final List<int> data;
  const LoadCubitHasData(this.data);
}

class LoadCubitError extends LoadCubitState {
  final Object error;
  const LoadCubitError(this.error);
}

// Listens only to TestLoadResponse
class LoadCubit extends CubitListener<TestListenersType, TestLoadResponse, LoadCubitState> {
  LoadCubit(TestReactor reactor) : super(const LoadCubitInit(), reactor, TestListenersType.load);

  @override
  void emitOnResponse(TestLoadResponse response) {
    if (response.error != null || response.data == null) {
      emit(LoadCubitError(response.error ?? StateError('unknown')));
      return;
    }
    emit(LoadCubitHasData(response.data!));
  }

  @override
  void setLoading({required TestLoadResponse data}) {
    emit(LoadCubitShimmer(lastData: data.data));
  }
}

// States for update cubit
sealed class UpdateCubitState {
  const UpdateCubitState();
}

class UpdateCubitInit extends UpdateCubitState {
  const UpdateCubitInit();
}

class UpdateCubitShimmer extends UpdateCubitState {
  final int? updatingId;
  const UpdateCubitShimmer(this.updatingId);
}

class UpdateCubitSuccess extends UpdateCubitState {
  final int id;
  const UpdateCubitSuccess(this.id);
}

class UpdateCubitError extends UpdateCubitState {
  final Object error;
  const UpdateCubitError(this.error);
}

// Listens only to TestUpdateResponse
class UpdateCubit extends CubitListener<TestListenersType, TestUpdateResponse, UpdateCubitState> {
  UpdateCubit(TestReactor reactor)
      : super(const UpdateCubitInit(), reactor, TestListenersType.update);

  @override
  void emitOnResponse(TestUpdateResponse response) {
    if (response.error != null || response.updatedId == null) {
      emit(UpdateCubitError(response.error ?? StateError('unknown')));
      return;
    }
    emit(UpdateCubitSuccess(response.updatedId!));
  }

  @override
  void setLoading({required TestUpdateResponse data}) {
    emit(UpdateCubitShimmer(data.updatedId));
  }
}

// ---------------- Tests ----------------

void main() {
  group('Reactor routing', () {
    late TestReactor reactor;
    late LoadCubit loadCubit;
    late UpdateCubit updateCubit;
    final emittedLoad = <LoadCubitState>[];
    final emittedUpdate = <UpdateCubitState>[];
    StreamSubscription? subLoad;
    StreamSubscription? subUpdate;

    setUp(() {
      reactor = TestReactor();
      loadCubit = LoadCubit(reactor);
      updateCubit = UpdateCubit(reactor);
      emittedLoad.clear();
      emittedUpdate.clear();
      subLoad = loadCubit.stream.listen(emittedLoad.add);
      subUpdate = updateCubit.stream.listen(emittedUpdate.add);
    });

    tearDown(() async {
      await subLoad?.cancel();
      await subUpdate?.cancel();
      await loadCubit.close();
      await updateCubit.close();
    });

    test('only LoadCubit reacts to TestLoadResponse', () async {
      // act
      reactor.emitLoad([1, 2, 3]);

      // assert
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(emittedLoad.any((e) => e is LoadCubitHasData), isTrue);
      expect(emittedUpdate.any((e) => e is UpdateCubitSuccess), isFalse);
    });

    test('only UpdateCubit reacts to TestUpdateResponse', () async {
      reactor.emitUpdate(id: 42);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(emittedUpdate.any((e) => e is UpdateCubitSuccess && e.id == 42), isTrue);
      expect(emittedLoad.any((e) => e is LoadCubitHasData), isFalse);
    });

    test('setLoading broadcasts loading state only to matching type', () async {
      // Load snapshot
      reactor.setLoadLoadingSnapshot(last: [9, 9, 9]);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      final shimmer = emittedLoad.whereType<LoadCubitShimmer>().toList();
      expect(shimmer.length, 1);
      expect(shimmer.first.lastData, [9, 9, 9]);

      // UpdateCubit shouldn't receive load loading
      expect(emittedUpdate.whereType<UpdateCubitShimmer>(), isEmpty);
    });

    test('close() unsubscribes listener from reactor (doesn\'t receive events anymore)', () async {
      // before closing both are subscribed
      reactor.emitLoad([1]);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final beforeCloseCount = emittedLoad.length;

      // close loadCubit -> it should call reactor.removeListener(this)
      await loadCubit.close();

      reactor.emitLoad([2, 3]);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // LoadCubit event count didn't increase after closing
      expect(emittedLoad.length, beforeCloseCount);
    });
  });
}
