import 'package:equatable/equatable.dart';

import '../../../ads/domain/entities/ad_entity.dart';

enum AdminAdsStatus { initial, loading, success, failure }

class AdminAdsState extends Equatable {
  const AdminAdsState({
    this.status = AdminAdsStatus.initial,
    this.ads = const [],
    this.errorMessage,
  });

  final AdminAdsStatus status;
  final List<AdEntity> ads;
  final String? errorMessage;

  AdminAdsState copyWith({
    AdminAdsStatus? status,
    List<AdEntity>? ads,
    String? errorMessage,
  }) {
    return AdminAdsState(
      status: status ?? this.status,
      ads: ads ?? this.ads,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, ads, errorMessage];
}
