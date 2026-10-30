import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thewasher/modules/profile/data/repo/profile_repo.dart';
import 'package:thewasher/responses/base_response.dart';

part 'update_phone_event.dart';
part 'update_phone_state.dart';

class UpdatePhoneBloc extends Bloc<UpdatePhoneEvent, UpdatePhoneState> {
  UpdatePhoneBloc() : super(UpdatePhoneInitial()) {
    on<UpdatePhoneEvent>((UpdatePhoneEvent event, Emitter<UpdatePhoneState> emit) async {
      try {
        emit(UpdatePhoneLoading());

        final BaseResponse response = await ProfileRepo.updatePhoneNumber(
            phone: event.phoneNumber);

        if (response.success) {
          emit(UpdatePhoneSuccess());
        } else {
          emit(UpdatePhoneFailed(
            error: response.errorModel,
          ));
        }
      } catch (e) {
        emit(UpdatePhoneFailed());
      }
    });
  }
}
