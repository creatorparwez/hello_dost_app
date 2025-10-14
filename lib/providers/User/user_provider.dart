import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:zee_goo/models/call_history_model.dart';
import 'package:zee_goo/models/calls_model.dart';
import 'package:zee_goo/models/user_model.dart';
import 'package:zee_goo/repository/auth_repository.dart';
import 'package:zee_goo/repository/users_repository.dart';

// Auth Repository Instance
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// To store Gender
final genderProvider = StateProvider<String?>((ref) {
  return null;
});
// To store Age
final ageProvider = StateProvider<int?>((ref) {
  return null;
});
// Loading
final isLoadingProvider = StateProvider<bool>((ref) => false);

// To store interests
final interestProvider = StateProvider<List<String>>((ref) {
  return [];
});

// To store languages
final languageProvider = StateProvider<List<String>>((ref) {
  return [];
});

// Users Repository Instance
final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository();
});

// To get All Users
final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  final repo = ref.read(usersRepositoryProvider);
  return repo.getAllUsers();
});

// To get userData by Id
final userDataProvider = StreamProvider.family<UserModel, String>((
  ref,
  userId,
) {
  final repo = ref.watch(usersRepositoryProvider);
  return repo.getUserDataById(userId);
});

// To get Admin data
final adminDataProvider = StreamProvider<UserModel?>((ref) {
  final repo = ref.watch(usersRepositoryProvider);
  return repo.getAdminData();
});

// To get All Calls (Entire Calls)
final allCallHistoryProvider = StreamProvider<List<CallHistoryModel>>((ref) {
  final repo = ref.read(usersRepositoryProvider);
  return repo.getAllCalls();
});

// To get Today Calls
final todayCallHistoryProvider = StreamProvider<List<CallHistoryModel>>((ref) {
  final repo = ref.read(usersRepositoryProvider);
  return repo.getTodayCalls();
});

// To get Week Calls
final weekCallHistoryProvider = StreamProvider<List<CallHistoryModel>>((ref) {
  final repo = ref.read(usersRepositoryProvider);
  return repo.getWeekCalls();
});

// To get Month Calls
final monthCallHistoryProvider = StreamProvider<List<CallHistoryModel>>((ref) {
  final repo = ref.read(usersRepositoryProvider);
  return repo.getMonthCalls();
});

// To get User Calls History by their Id (Only calls of particular User)
final callsHistoryProvider = StreamProvider.family<List<CallsModel>, String>((
  ref,
  userId,
) {
  final repo = ref.watch((usersRepositoryProvider));
  return repo.getCallsHistoryByUserId(userId);
});
