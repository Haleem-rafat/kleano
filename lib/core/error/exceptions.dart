// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:thewasher/core/error/failure.dart';
import 'package:thewasher/core/network/error_message_model.dart';

class ServerExceptions implements Exception {
  final ErrorMessageModel errorMessageModel;
  ServerExceptions({
    required this.errorMessageModel,
  });
}

// if worke with local data source
class LocalDataBaseException implements Exception {
  final ErrorMessageModel errorMessageModel;
  LocalDataBaseException({
    required this.errorMessageModel,
  });
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class DataBaseFailure extends Failure {
  const DataBaseFailure(super.message);
}
