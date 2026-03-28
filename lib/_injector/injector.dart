import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ping/_ping.dart';
import 'package:ping/_routing/_routing.dart';
import 'package:ping/_shared/_shared.dart';
import 'package:ping/features/auth/manager/auth_manager.dart';
import 'package:ping/features/auth/services/auth_service.dart';

void configureCoreDependencies() {
  di.pushNewScope(scopeName: 'root');
  di.registerLazySingleton<ImageCropper>(ImageCropper.new);
  di.registerLazySingleton<ImagePicker>(ImagePicker.new);
  di.registerLazySingleton<MediaService>(() {
    return MediaService(
      imageCropper: di<ImageCropper>(),
      imagePicker: di<ImagePicker>(),
    );
  });
  di.registerSingleton<ToastManager>(ToastManager());
  di.registerSingletonAsync<DatabaseService>(DatabaseService.initialize);
  di.registerSingletonAsync<AuthService>(() async {
    return AuthService(di<DatabaseService>());
  }, dependsOn: [DatabaseService]);
  di.registerSingletonAsync<AuthManager>(() async {
    final manager = AuthManager(
      service: di<AuthService>(),
      toast: di<ToastManager>(),
    );
    await manager.initialize();
    return manager;
  }, dependsOn: [AuthService]);
  di.registerSingletonWithDependencies<PingRouter>(() {
    return PingRouter.create(di<AuthManager>());
  }, dependsOn: [AuthManager]);
}
