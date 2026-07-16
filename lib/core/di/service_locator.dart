import 'package:get_it/get_it.dart';
import 'package:lystra/data/repositories/auth_repository.dart';
import 'package:lystra/data/repositories/category_repository.dart';
import 'package:lystra/data/repositories/household_repository.dart';
import 'package:lystra/data/repositories/item_repository.dart';
import 'package:lystra/data/repositories/list_entry_repository.dart';
import 'package:lystra/data/repositories/purchase_record_repository.dart';
import 'package:lystra/data/repositories/shopping_list_repository.dart';
import 'package:lystra/data/repositories/user_repository.dart';
import 'package:lystra/data/services/fcm_service.dart';
import 'package:lystra/data/services/firebase_auth_service.dart';
import 'package:lystra/data/services/firestore_service.dart';
import 'package:lystra/data/services/list_template_service.dart';
import 'package:lystra/data/services/seed_data_service.dart';
import 'package:lystra/data/services/user_state.dart';
import 'package:lystra/ui/features/auth/view_models/auth_view_model.dart';
import 'package:lystra/ui/features/history/view_models/history_view_model.dart';
import 'package:lystra/ui/features/items/view_models/items_view_model.dart';
import 'package:lystra/ui/features/lists/view_models/lists_view_model.dart';
import 'package:lystra/ui/features/profile/view_models/profile_view_model.dart';

final GetIt sl = GetIt.instance;

void setupServiceLocator() {
  // 1. Services — stateless, singleton
  sl.registerLazySingleton<FirebaseAuthService>(() => FirebaseAuthService());
  sl.registerLazySingleton<FirestoreService>(() => FirestoreService());
  sl.registerLazySingleton<SeedDataService>(
    () => SeedDataService(firestoreService: sl()),
  );
  sl.registerLazySingleton<FcmService>(
    () => FcmService(userRepository: sl()),
  );
  sl.registerLazySingleton<UserState>(
    () => UserState(userRepository: sl()),
  );
  sl.registerLazySingleton<ListTemplateService>(
    () => ListTemplateService(
      categoryRepository: sl(),
      itemRepository: sl(),
      entryRepository: sl(),
    ),
  );

  // 2. Repositories — singleton (maintain in-memory cache)
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(authService: sl()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepository(firestoreService: sl()),
  );
  sl.registerLazySingleton<HouseholdRepository>(
    () => HouseholdRepository(firestoreService: sl()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepository(firestoreService: sl()),
  );
  sl.registerLazySingleton<ItemRepository>(
    () => ItemRepository(firestoreService: sl()),
  );
  sl.registerLazySingleton<ShoppingListRepository>(
    () => ShoppingListRepository(firestoreService: sl()),
  );
  sl.registerLazySingleton<ListEntryRepository>(
    () => ListEntryRepository(firestoreService: sl()),
  );
  sl.registerLazySingleton<PurchaseRecordRepository>(
    () => PurchaseRecordRepository(firestoreService: sl()),
  );

  // 3. ViewModels — factory (new instance per screen, no stale state)
  sl.registerFactory<AuthViewModel>(
    () => AuthViewModel(
      authRepository: sl(),
      seedDataService: sl(),
      userRepository: sl(),
    ),
  );
  sl.registerFactory<ListsViewModel>(
    () => ListsViewModel(
      listRepository: sl(),
      authRepository: sl(),
      entryRepository: sl(),
      userState: sl(),
      templateService: sl(),
    ),
  );
  sl.registerFactory<ItemsViewModel>(
    () => ItemsViewModel(
      itemRepository: sl(),
      categoryRepository: sl(),
      authRepository: sl(),
      listRepository: sl(),
      entryRepository: sl(),
    ),
  );
  sl.registerFactory<HistoryViewModel>(
    () => HistoryViewModel(
      recordRepository: sl(),
      authRepository: sl(),
    ),
  );
  sl.registerFactory<ProfileViewModel>(
    () => ProfileViewModel(
      authRepository: sl(),
      userRepository: sl(),
      userState: sl(),
      householdRepository: sl(),
      seedDataService: sl(),
      categoryRepository: sl(),
      itemRepository: sl(),
      listRepository: sl(),
      entryRepository: sl(),
      recordRepository: sl(),
    ),
  );
}
