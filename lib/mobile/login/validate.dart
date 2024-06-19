import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';


class CheckValidate {


  String? validateEmail(FocusNode focusNode, String? value, List<String> emailList) {
    if (value == null || value.isEmpty) {
      focusNode.requestFocus();
      return '이메일을 입력하세요.';
    } else {
      if (!EmailValidator.validate(value)) {
        focusNode.requestFocus(); //포커스를 해당 textformfield에 맞춘다.
        return '잘못된 이메일 형식입니다.';
      } else if (emailList.indexOf(value) != -1) {
        focusNode.requestFocus(); // 포커스를 해당 TextFormField에 맞춘다.
        return '이미 존재하는 이메일입니다.';
      } else {
        return null;
      }
    }
  }

  String? validatePassword(FocusNode focusNode, String? value) {
    if (value == null || value.isEmpty) {
      focusNode.requestFocus();
      return '비밀번호를 입력하세요.';
    } else {
      String pattern =
          r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?~^<>,.&+=])[A-Za-z\d$@$!%*#?~^<>,.&+=]{8,}$';
      RegExp regExp = new RegExp(pattern);
      if (!regExp.hasMatch(value)) {
        focusNode.requestFocus();
        return '문자, 대소문자, 숫자 포함 8자리 이상 입력하세요.';
      }
      return null;
    }
  }
}
