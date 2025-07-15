// Based on: https://docs.frisbii.com/docs/useraction-enum

enum EUserAction {
  cardInputChange('card_input_change');

  final String value;

  const EUserAction(this.value);

  static EUserAction fromString(String value) {
    return EUserAction.values.firstWhere(
      (state) => state.value == value,
      orElse: () => throw ArgumentError('Invalid value: $value'),
    );
  }
}
