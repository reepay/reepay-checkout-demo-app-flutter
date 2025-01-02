//  Based on: https://optimize-docs.billwerk.com/docs/checkoutstate-enum

enum ECheckoutState {
  init('Init'),
  open('Open'),
  accept('Accept'),
  cancel('Cancel'),
  close('Close'),
  error('Error');

  final String value;

  const ECheckoutState(this.value);

  static ECheckoutState fromString(String value) {
    return ECheckoutState.values.firstWhere(
      (state) => state.value == value,
      orElse: () => throw ArgumentError('Invalid value: $value'),
    );
  }
}
