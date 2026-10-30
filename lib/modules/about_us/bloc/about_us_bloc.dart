import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:thewasher/modules/about_us/data/models/contact_model.dart';
import 'package:thewasher/modules/about_us/data/repo/about_us_repo.dart';

part 'about_us_event.dart';
part 'about_us_state.dart';

class AboutUsBloc extends Bloc<AboutUsEvent, AboutUsState> {
  AboutUsBloc()
      : super(const AboutUsState(status: AboutUsStateStatus.initial)) {
    on<GetTermsAndCondition>(_onLoadTermsContent);
    on<GetContactInfo>(_onLoadContactInfo);
  }

  Future<void> _onLoadTermsContent(
    GetTermsAndCondition event,
    Emitter<AboutUsState> emit,
  ) async {
    emit(state.copyWith(status: AboutUsStateStatus.loading));
    try {
      final termsContent = await AboutUsRepo.getTermsAndConditions();
      emit(state.copyWith(
        status: AboutUsStateStatus.success,
        termsContent: termsContent, // This can be null for 404 errors
      ));
    } catch (error) {
      emit(state.copyWith(
        status: AboutUsStateStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }

  Future<void> _onLoadContactInfo(
    GetContactInfo event,
    Emitter<AboutUsState> emit,
  ) async {
    emit(state.copyWith(status: AboutUsStateStatus.loading));
    try {
      final contactInfo = await AboutUsRepo.getContactDataInfo();
      emit(state.copyWith(
        status: AboutUsStateStatus.success,
        contactInfo: contactInfo.results,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: AboutUsStateStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }
}
