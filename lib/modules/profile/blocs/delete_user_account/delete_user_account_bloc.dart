import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thewasher/modules/profile/data/repo/profile_repo.dart';
import 'package:thewasher/responses/base_response.dart';

part 'delete_user_account_event.dart';
part 'delete_user_account_state.dart';

class DeleteUserAccountBloc
    extends Bloc<DeleteUserAccountEvent, DeleteUserAccountState> {
  DeleteUserAccountBloc() : super(DeleteAccountInitial()) {
    on<DeleteUserAccountEvent>((DeleteUserAccountEvent event,
        Emitter<DeleteUserAccountState> emit) async {
      try {
        emit(DeleteAccountLoading());
        BaseResponse? response = await ProfileRepo.deleteUserAccount();
        if (response.success) {
          emit(DeleteAccountSuccess());
        } else {
          emit(DeleteAccountFailed(error: response.errorMessage!));
        }
      } on DioError catch (e) {
        if (e.message!.contains('SocketException')) {
          emit(DeleteAccountConnectionError());
        } else {
          emit(DeleteAccountFailed(
            error: e.message ?? '',
          ));
        }
      } catch (e) {
        if (e is SocketException) {
          emit(DeleteAccountConnectionError());
        } else {
          emit(DeleteAccountFailed(
            error: e.toString(),
          ));
        }
      }
    });
  }
}
