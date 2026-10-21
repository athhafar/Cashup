import 'dart:async';

import 'package:cash_up/utilities/api_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../routes/route_name.dart';
import '../services/api_service.dart';
import '../utilities/enum/snackbar_status.dart';
import '../utilities/helper.dart';

class LoginController extends GetxController {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final isLoading = false.obs;

  final box = GetStorage();

  Future<void> login() async {
    // isLoading.value = true;
    Get.toNamed(RouteName.home);

    var requestBody = {"email": emailC.text};

    // var data = await ApiServices.api(
    //   endPoint: APIEndpoint.authCode,
    //   type: APIMethod.post,
    //   requestBodyMap: requestBody,
    //   withToken: false,
    // );

    // if (data == null) {
    //   isLoading.value = false;
    //   Helper.setSnackBar(
    //     type: SnackBarType.error,
    //     message: "Terjadi kesalahan pada server",
    //   );
    //   return;
    // }

    // if (data['success'] == true) {
    // Simpan email ke box
    //   await box.write('email', emailC.text);

    //   // TODO: simpan token jika API mengembalikannya
    //   // await box.write('token', data['data']['token']);

    //   // TODO: simpan status login
    //   // await box.write('isLogin', true);

    //   // TODO: jika flow-nya pakai kode verifikasi (authCode),
    //   // arahkan ke halaman input kode OTP terlebih dahulu
    //   // Get.toNamed(RouteName.verifyCode);

    //   Helper.setSnackBar(type: SnackBarType.success, message: data['message']);
    //   isLoading.value = false;
    //   Get.toNamed(RouteName.home);
    // } else {
    //   isLoading.value = false;
    //   Helper.setSnackBar(type: SnackBarType.error, message: data['message']);
    // }
  }

  // TODO: fungsi logout (hapus data dari box)
  // Future<void> logout() async {
  //   await box.erase();
  //   Get.offAllNamed(RouteName.login);
  // }

  @override
  void onClose() {
    emailC.dispose();
    passC.dispose();
    super.onClose();
  }
}
