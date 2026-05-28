import 'package:get/get.dart';

import '../controllers/authority/authority_controller.dart';

class AuthorityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthorityController>(
      () => AuthorityController(),
      fenix: true,
    );
  }
}
