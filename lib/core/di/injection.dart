import 'package:get_it/get_it.dart';
import '../../features/auth/domain/usecases/send_otp_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/splash/presentation/bloc/splash_bloc.dart';
import '../../features/auth/data/datasource/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/Login/bloc/login_bloc.dart';
import '../../features/auth/presentation/verifyotp/bloc/otp_bloc.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_user_profile_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  sl.registerFactory(() => SplashBloc());

  sl.registerLazySingleton<AuthRemoteDatasource>(() => AuthRemoteDatasourceImpl());
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(datasource: sl()));

  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SendOtpUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));

  sl.registerFactory(() => LoginBloc(
    loginUseCase: sl(),
    sendOtpUseCase: sl(),
  ));

  sl.registerFactory(() => OtpBloc(
    verifyOtpUseCase: sl(),
    sendOtpUseCase: sl(),
  ));

  sl.registerLazySingleton<ProfileRemoteDatasource>(() => ProfileRemoteDatasourceImpl());
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));

  sl.registerFactory(() => ProfileBloc(sl()));
}