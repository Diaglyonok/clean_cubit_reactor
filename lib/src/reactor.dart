import './cubit_listener.dart';
import 'reactor_base_response.dart';

mixin Reactor<LST, ResponseType extends ReactorResponse<LST>> {
  final List<CubitListener> listeners = [];
  final List<void Function(ResponseType)> dataListeners = [];

  final List<ResponseType> _sessionHistory = [];

  void addDataListener(void Function(ResponseType) listener) {
    dataListeners.add(listener);
  }

  void removeDataListener(void Function(ResponseType) listener) {
    dataListeners.remove(listener);
  }

  void addListener(CubitListener listener) {
    listeners.add(listener);
  }

  void removeListener(CubitListener listener) {
    listeners.remove(listener);
  }

  void setLoading({required ResponseType currentData}) {
    for (var listener in List.from(listeners)) {
      if (listener.type == currentData.type || currentData.type == null) {
        listener.typedEmit(currentData, isLoading: true);
      }
    }
  }

  void provideDataToListeners(ResponseType data) {
    _sessionHistory.add(data);

    for (var listener in List.from(listeners)) {
      if (listener.type == data.type) {
        listener.typedEmit(data);
      }
    }

    for (var listener in List.from(dataListeners)) {
      listener.call(data);
    }
  }

  T? getLastData<T extends ResponseType>() {
    if (_sessionHistory.isEmpty) {
      return null;
    }

    if (T == ResponseType) {
      return _sessionHistory.last as T;
    }

    final result = _sessionHistory.whereType<T>().toList();

    if (result.isEmpty) {
      return null;
    }

    return result.toList().last;
  }
}
