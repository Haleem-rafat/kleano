part of 'banner_bloc.dart';

enum BannerStatus {
  initial,
  loading,
  success,
  error,
}

@immutable
class BannerState {
  final BannerStatus status;
  final List<BannerModel>? banners;
  final String? errorMessage;

  const BannerState({
    required this.status,
    this.banners,
    this.errorMessage,
  });
  BannerState copyWith({
    BannerStatus? status,
    final List<BannerModel>? banners,
    String? errorMessage,
  }) {
    return BannerState(
      status: status ?? this.status,
      banners: banners ?? this.banners,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
