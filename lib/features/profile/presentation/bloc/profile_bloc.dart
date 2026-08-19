import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;

  ProfileBloc(this.getUserProfileUseCase) : super(ProfileInitial()) {
    on<LoadProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await getUserProfileUseCase();
        emit(ProfileLoaded(profile));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
  }
}