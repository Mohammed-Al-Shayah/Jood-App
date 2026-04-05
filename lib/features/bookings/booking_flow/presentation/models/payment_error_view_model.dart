import 'package:jood/core/utils/app_strings.dart';

class PaymentErrorViewModel {
  const PaymentErrorViewModel({required this.code, required this.message});

  final String? code;
  final String? message;

  factory PaymentErrorViewModel.fromStatus(Map status) {
    final data = status['data'];
    final nestedMessage = data is Map
        ? (data['message'] ?? data['description'] ?? data['error'])
        : null;
    final code = status['code'] ?? status['status'];
    final directMessage =
        status['message'] ?? status['error'] ?? status['detail'];
    final parsedMessage = (nestedMessage ?? directMessage)?.toString().trim();
    return PaymentErrorViewModel(
      code: code?.toString(),
      message: parsedMessage == null || parsedMessage.isEmpty
          ? null
          : parsedMessage,
    );
  }

  String toDisplayMessage() {
    if (message != null) {
      return code == null
          ? AppStrings.paymentFailedWithMessage(message!)
          : AppStrings.paymentFailedWithCodeAndMessage(code!, message!);
    }
    return code == null
        ? AppStrings.paymentFailedCheckThawaniKeys
        : AppStrings.paymentFailedCheckThawaniKeysWithCode(code!);
  }
}
