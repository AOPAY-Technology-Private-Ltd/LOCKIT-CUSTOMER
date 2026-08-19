abstract class LoginState {}



class LoginInitial extends LoginState {}



class LoginLoading extends LoginState {}



class LoginSuccess extends LoginState {


  final String mobile;

  final String message;



  LoginSuccess({

    required this.mobile,

    required this.message,

  });


}



class LoginFailure extends LoginState {


  final String error;



  LoginFailure({

    required this.error,

  });


}