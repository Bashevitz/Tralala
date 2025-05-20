import 'package:flutter/material.dart';

class OnboardingProvider extends ChangeNotifier {
  String? _phoneNumber;
  String? _firstName;
  String? _lastName;

  String? get phoneNumber => _phoneNumber;
  String? get firstName => _firstName;
  String? get lastName => _lastName;

  void setPhoneNumber(String phone) {
    _phoneNumber = phone;
    notifyListeners();
  }

  void setProfileData(String firstName, String lastName) {
    _firstName = firstName;
    _lastName = lastName;
    notifyListeners();
  }

  void clearData() {
    _phoneNumber = null;
    _firstName = null;
    _lastName = null;
    notifyListeners();
  }
}
