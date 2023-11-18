import 'package:clean_cubit_reactor_example/src/domain/entities/items_response.dart';

abstract class Error {
  final String repoError;

  const Error(this.repoError);
}

class LoadError extends Error {
  const LoadError(super.repoError);

  static LoadError? getError(String? repoError) {
    if (repoError == null) {
      return null;
    }

    return LoadError(repoError);
  }
}

class UpdateError extends Error {
  final RequestUpdateType type;

  const UpdateError(super.repoError, this.type);

  static UpdateError? getError(String? repoError, RequestUpdateType type) {
    if (repoError == null) {
      return null;
    }

    return UpdateError(repoError, type);
  }
}
