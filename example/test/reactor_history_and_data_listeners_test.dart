import 'package:flutter_test/flutter_test.dart';
import 'package:clean_cubit_reactor/clean_cubit_reactor.dart';

// Same test doubles as in the previous file (for independence)

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

  void emitUpdate({int? id, Object? error}) {
    provideDataToListeners(TestUpdateResponse(updatedId: id, error: error));
  }
}

void main() {
  group('Reactor history & dataListeners', () {
    test('history: last<T>() returns last emitted of type T', () {
      final reactor = TestReactor();

      reactor.emitLoad([1, 2]);
      reactor.emitUpdate(id: 7);
      reactor.emitLoad([3, 4, 5]);

      final lastLoad = reactor.getLastData<TestLoadResponse>();
      final lastUpdate = reactor.getLastData<TestUpdateResponse>();

      expect(lastLoad, isNotNull);
      expect(lastLoad!.data, [3, 4, 5]);
      expect(lastUpdate, isNotNull);
      expect(lastUpdate!.updatedId, 7);
    });

    test('history: last<TestBaseResponse>() returns last of base type', () {
      final reactor = TestReactor();

      reactor.emitLoad([10]);
      reactor.emitUpdate(id: 11);

      final lastAny = reactor.getLastData<TestBaseResponse>();
      expect(lastAny, isA<TestUpdateResponse>()); // last one is update
      expect((lastAny as TestUpdateResponse).updatedId, 11);
    });

    test('dataListeners receive every response regardless of type', () {
      final reactor = TestReactor();
      final received = <TestBaseResponse>[];

      listener(TestBaseResponse r) => received.add(r);
      reactor.addDataListener(listener);

      reactor.emitLoad([1]);
      reactor.emitUpdate(id: 2);

      expect(received.length, 2);
      expect(received[0], isA<TestLoadResponse>());
      expect(received[1], isA<TestUpdateResponse>());

      // remove
      reactor.removeDataListener(listener);
      reactor.emitLoad([999]);

      // after removal listener doesn't receive events
      expect(received.length, 2);
    });
  });
}
