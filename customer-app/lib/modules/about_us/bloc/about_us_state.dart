part of 'about_us_bloc.dart';

enum AboutUsStateStatus {
  initial,
  loading,
  success,
  error,
}

@immutable
class AboutUsState {
  final AboutUsStateStatus status;
  final String? termsContent;
  final ContactDataModel? contactInfo;
  final String? errorMessage;

  const AboutUsState({
    required this.status,
    this.termsContent,
    this.contactInfo,
    this.errorMessage,
  });
  AboutUsState copyWith({
    AboutUsStateStatus? status,
    String? termsContent,
    ContactDataModel? contactInfo,
    String? errorMessage,
    DateTime? lastUpdated,
  }) {
    return AboutUsState(
      status: status ?? this.status,
      termsContent: termsContent ?? this.termsContent,
      contactInfo: contactInfo ?? this.contactInfo,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
