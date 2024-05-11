import 'package:flutter/cupertino.dart';

class UserState extends InheritedWidget {
  final bool isGuestUser;

  const UserState({
    Key? key,
    required this.isGuestUser,
    required Widget child,
  }) : super(key: key, child: child);

  static UserState of(BuildContext context) {
    final UserState? result = context.dependOnInheritedWidgetOfExactType<UserState>();
    assert(result != null, 'No UserState found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(UserState old) => isGuestUser != old.isGuestUser;
}
