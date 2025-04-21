import './cubit_listener.dart';
import 'reactor_base_response.dart';

mixin Reactor<LST, ResponseType extends ReactorResponse<LST>> {
  final List<CubitListener> listeners = [];
  final List<void Function(ResponseType)> dataListeners = [];

  final List<ResponseType> _sessionlHistory = [];

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
    for (var listener in listeners) {
      if (listener.type == currentData.type || currentData.type == null) {
        listener.typedEmit(currentData, isLoading: true);
      }
    }
  }

  void provideDataToListeners(ResponseType data) {
    _sessionlHistory.add(data);

    for (var listener in listeners) {
      if (listener.type == data.type) {
        listener.typedEmit(data);
      }
    }

    for (var listener in dataListeners) {
      listener.call(data);
    }
  }

  T? getLastData<T extends ResponseType>() {
    if (_sessionlHistory.isEmpty) {
      return null;
    }

    if (T == ResponseType) {
      return _sessionlHistory.last as T;
    }

    final result = _sessionlHistory.whereType<T>().toList();

    if (result.isEmpty) {
      return null;
    }

    return result.toList().last;
  }
}
