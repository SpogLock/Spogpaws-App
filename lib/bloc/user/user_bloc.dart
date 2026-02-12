import 'package:flutter/foundation.dart';
import 'package:spogpaws/models/user_profile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spogpaws/repositories/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum UserStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  success,
  blocked,
  failure,
}

@immutable
class UserState {
  const UserState({
    this.status = UserStatus.initial,
    this.user,
    this.session,
    this.profile,
    this.accountStatus = AccountStatus.unknown,
    this.role = 'user',
    this.message,
  });

  final UserStatus status;
  final User? user;
  final Session? session;
  final UserProfile? profile;
  final AccountStatus accountStatus;
  final String role;
  final String? message;

  UserState copyWith({
    UserStatus? status,
    User? user,
    Session? session,
    UserProfile? profile,
    AccountStatus? accountStatus,
    String? role,
    String? message,
    bool clearUser = false,
    bool clearSession = false,
    bool clearProfile = false,
    bool clearMessage = false,
  }) {
    return UserState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      session: clearSession ? null : (session ?? this.session),
      profile: clearProfile ? null : (profile ?? this.profile),
      accountStatus: accountStatus ?? this.accountStatus,
      role: role ?? this.role,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

@immutable
sealed class UserEvent {
  const UserEvent();
}

class UserSignUpRequested extends UserEvent {
  const UserSignUpRequested({
    required this.email,
    required this.password,
    this.fullName,
    this.username,
  });

  final String email;
  final String password;
  final String? fullName;
  final String? username;
}

class UserLoginRequested extends UserEvent {
  const UserLoginRequested({required this.email, required this.password});

  final String email;
  final String password;
}

class UserUpdateRequested extends UserEvent {
  const UserUpdateRequested({
    this.email,
    this.password,
    this.fullName,
    this.username,
  });

  final String? email;
  final String? password;
  final String? fullName;
  final String? username;
}

class UserDeleteRequested extends UserEvent {
  const UserDeleteRequested();
}

class UserProfileRequested extends UserEvent {
  const UserProfileRequested();
}

class UserStatusUpdateRequested extends UserEvent {
  const UserStatusUpdateRequested({required this.userId, required this.status});

  final String userId;
  final AccountStatus status;
}

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(const UserState()) {
    on<UserSignUpRequested>(_onSignUpRequested);
    on<UserLoginRequested>(_onLoginRequested);
    on<UserUpdateRequested>(_onUpdateRequested);
    on<UserDeleteRequested>(_onDeleteRequested);
    on<UserProfileRequested>(_onProfileRequested);
    on<UserStatusUpdateRequested>(_onStatusUpdateRequested);
  }

  final UserRepository _userRepository;

  Future<void> _onSignUpRequested(
    UserSignUpRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserStatus.loading, clearMessage: true));
    try {
      final response = await _userRepository.signUp(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        username: event.username,
      );
      if (response.session == null || response.user == null) {
        emit(
          state.copyWith(
            status: UserStatus.success,
            message:
                'Signup successful. Check your email to verify your account before logging in.',
          ),
        );
        return;
      }

      final profile = await _userRepository.getCurrentProfile();

      emit(
        state.copyWith(
          status: UserStatus.authenticated,
          user: response.user,
          session: response.session,
          profile: profile,
          accountStatus: profile.accountStatus,
          role: profile.role,
          message: 'Signup successful.',
        ),
      );
    } on UserRepositoryException catch (e) {
      emit(state.copyWith(status: UserStatus.failure, message: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: UserStatus.failure,
          message: 'Unexpected error during signup.',
        ),
      );
    }
  }

  Future<void> _onLoginRequested(
    UserLoginRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserStatus.loading, clearMessage: true));
    try {
      final response = await _userRepository.login(
        email: event.email,
        password: event.password,
      );
      final profile = await _userRepository.getCurrentProfile();

      if (profile.accountStatus != AccountStatus.active) {
        await Supabase.instance.client.auth.signOut();
        emit(
          state.copyWith(
            status: UserStatus.blocked,
            clearUser: true,
            clearSession: true,
            clearProfile: true,
            accountStatus: profile.accountStatus,
            role: profile.role,
            message: _blockedMessage(profile.accountStatus),
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: UserStatus.authenticated,
          user: response.user,
          session: response.session,
          profile: profile,
          accountStatus: profile.accountStatus,
          role: profile.role,
          message: 'Login successful.',
        ),
      );
    } on UserRepositoryException catch (e) {
      emit(state.copyWith(status: UserStatus.failure, message: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: UserStatus.failure,
          message: 'Unexpected error during login.',
        ),
      );
    }
  }

  Future<void> _onUpdateRequested(
    UserUpdateRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserStatus.loading, clearMessage: true));
    try {
      final response = await _userRepository.editCurrentUser(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        username: event.username,
      );
      final profile = await _userRepository.getCurrentProfile();

      emit(
        state.copyWith(
          status: UserStatus.success,
          user: response.user,
          profile: profile,
          accountStatus: profile.accountStatus,
          role: profile.role,
          message: 'User updated successfully.',
        ),
      );
    } on UserRepositoryException catch (e) {
      emit(state.copyWith(status: UserStatus.failure, message: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: UserStatus.failure,
          message: 'Unexpected error during user update.',
        ),
      );
    }
  }

  Future<void> _onDeleteRequested(
    UserDeleteRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserStatus.loading, clearMessage: true));
    try {
      await _userRepository.deleteCurrentUser();
      emit(
        state.copyWith(
          status: UserStatus.unauthenticated,
          clearUser: true,
          clearSession: true,
          clearProfile: true,
          accountStatus: AccountStatus.unknown,
          role: 'user',
          message: 'User deleted successfully.',
        ),
      );
    } on UserRepositoryException catch (e) {
      emit(state.copyWith(status: UserStatus.failure, message: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: UserStatus.failure,
          message: 'Unexpected error during user deletion.',
        ),
      );
    }
  }

  Future<void> _onProfileRequested(
    UserProfileRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserStatus.loading, clearMessage: true));
    try {
      final profile = await _userRepository.getCurrentProfile();
      emit(
        state.copyWith(
          status: UserStatus.success,
          profile: profile,
          accountStatus: profile.accountStatus,
          role: profile.role,
          message: 'Profile loaded.',
        ),
      );
    } on UserRepositoryException catch (e) {
      emit(state.copyWith(status: UserStatus.failure, message: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: UserStatus.failure,
          message: 'Unexpected error while loading profile.',
        ),
      );
    }
  }

  Future<void> _onStatusUpdateRequested(
    UserStatusUpdateRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserStatus.loading, clearMessage: true));
    try {
      await _userRepository.updateUserStatus(
        userId: event.userId,
        status: event.status,
      );
      emit(
        state.copyWith(
          status: UserStatus.success,
          accountStatus: event.status,
          message: 'User status updated.',
        ),
      );
    } on UserRepositoryException catch (e) {
      emit(state.copyWith(status: UserStatus.failure, message: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: UserStatus.failure,
          message: 'Unexpected error while updating user status.',
        ),
      );
    }
  }

  String _blockedMessage(AccountStatus status) {
    switch (status) {
      case AccountStatus.pending:
        return 'Your account is pending approval.';
      case AccountStatus.suspended:
        return 'Your account is suspended. Contact support.';
      case AccountStatus.banned:
        return 'Your account is banned.';
      case AccountStatus.active:
        return 'Your account is active.';
      case AccountStatus.unknown:
        return 'Unable to verify account status.';
    }
  }
}
