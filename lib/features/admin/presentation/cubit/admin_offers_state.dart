import 'package:equatable/equatable.dart';
import '../../../offers/domain/entities/offer_entity.dart';

enum AdminOffersStatus { initial, loading, success, failure }

class AdminOffersState extends Equatable {
  const AdminOffersState({
    this.status = AdminOffersStatus.initial,
    this.offers = const [],
    this.errorMessage,
  });

  final AdminOffersStatus status;
  final List<OfferEntity> offers;
  final String? errorMessage;

  AdminOffersState copyWith({
    AdminOffersStatus? status,
    List<OfferEntity>? offers,
    String? errorMessage,
  }) {
    return AdminOffersState(
      status: status ?? this.status,
      offers: offers ?? this.offers,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, offers, errorMessage];
}
