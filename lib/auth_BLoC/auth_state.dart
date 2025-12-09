abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String uid;
  final String email;

  LoginSuccess(this.uid, this.email);
}

class LoginFailure extends LoginState {
  final String message;

  LoginFailure(this.message);
}
