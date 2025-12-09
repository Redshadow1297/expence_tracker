import 'package:expence_tracker/auth_BLoC/auth_event.dart';
import 'package:expence_tracker/auth_BLoC/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';


class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  LoginBloc() : super(LoginInitial()) {
    
    on<CheckLoginStatus>((event, emit) {
      final user = _auth.currentUser;
      if (user != null) {
        emit(LoginSuccess(user.uid, user.email ?? ""));
      }
    });

    on<LoginButtonPressed>((event, emit) async {
      emit(LoginLoading());
      try {
        UserCredential cred = await _auth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(LoginSuccess(
          cred.user!.uid,
          cred.user!.email ?? "",
        ));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          emit(LoginFailure("Wrong Password"));
        } else if (e.code == 'user-not-found') {
          emit(LoginFailure("User not found"));
        } else {
          emit(LoginFailure("Wrong credentials"));
        }
      } catch (e) {
        emit(LoginFailure("Error: $e"));
      }
    });
  }
}
