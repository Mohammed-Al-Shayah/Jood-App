import 'package:equatable/equatable.dart';

import 'package:jood/features/attractions/domain/entities/attraction_entity.dart';

enum AdminAttractionsStatus { initial, loading, success, failure }

class AdminAttractionsState extends Equatable {
  const AdminAttractionsState({
    this.status = AdminAttractionsStatus.initial,
    this.attractions = const [],
    this.errorMessage,
  });

  final AdminAttractionsStatus status;
  final List<AttractionEntity> attractions;
  final String? errorMessage;

  AdminAttractionsState copyWith({
    AdminAttractionsStatus? status,
    List<AttractionEntity>? attractions,
    String? errorMessage,
  }) {
    return AdminAttractionsState(
      status: status ?? this.status,
      attractions: attractions ?? this.attractions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, attractions, errorMessage];
}
