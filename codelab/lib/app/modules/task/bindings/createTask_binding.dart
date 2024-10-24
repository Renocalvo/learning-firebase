import 'package:get/get.dart';

import '../controllers/createTask_controller.dart';

class CreatetaskBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreatetaskController>(
      () => CreatetaskController(),
    );
  }
}
