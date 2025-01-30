import 'package:reepay_checkout_flutter_example/checkout/domain/models/checkout_state_enum.dart';
import 'package:reepay_checkout_flutter_example/checkout/domain/models/user_action_enum.dart';

class EventParser {
  static Enum? parseEvent(String event) {
    for (var state in ECheckoutState.values) {
      if (state.value == event) {
        return state;
      }
    }

    for (var action in EUserAction.values) {
      if (action.value == event) {
        return action;
      }
    }

    return null;
  }
}
