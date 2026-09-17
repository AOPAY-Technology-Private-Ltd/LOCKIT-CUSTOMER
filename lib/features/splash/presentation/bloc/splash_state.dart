abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashCompleted extends SplashState {
  SplashCompleted();
}

class SplashNavigateToHome extends SplashState {
  SplashNavigateToHome();
}

class SplashNavigateToGenerateKey extends SplashState {
  SplashNavigateToGenerateKey();
}