import 'dart:io';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ynotes/core/apis/model.dart';
import 'package:ynotes/core/apis/utils.dart';
import 'package:ynotes/core/logic/grades/controller.dart';
import 'package:ynotes/core/logic/homework/controller.dart';
import 'package:ynotes/core/logic/shared/loginController.dart';
import 'package:ynotes/core/offline/offline.dart';
import 'package:ynotes/core/services/background.dart';
import 'package:ynotes/core/utils/settingsUtils.dart';
import 'package:ynotes/core/utils/themeUtils.dart';
import 'package:ynotes/ui/themes/themesList.dart';

class Test {
  Map? settings;
  Test() {
    settings = SettingsUtils.getAppSettings();
  }
}

///Top level application sytem class
class ApplicationSystem extends ChangeNotifier {
  Map? settings;

  updateSetting(Map path, String key, var value) {
    path[key] = value;
    SettingsUtils.setSetting(settings);
    notifyListeners();
  }

  ///A boolean representing the use of the application
  bool? isFirstUse;

  ///The color theme used in the application
  ThemeData? theme;

  String? themeName;

  ///The chosen API
  API? api;

  ///The chosen API
  Offline? offline;

  ///All the app controllers

  LoginController? loginController;
  GradesController? gradesController;
  HomeworkController? homeworkController;

  ///The most important function
  ///It will intialize Offline, APIs and background fetch
  initApp() async {
    //set settings
    await _initSettings();
    //Set theme to default
    updateTheme(settings!["user"]["global"]["theme"]);
    //Set offline
    await _initOffline();

    //Set api
    this.api = APIManager(this.offline);
    //Set background fetch
    await _initBackgroundFetch();
    //Set controllers
    await initControllers();
  }

  updateTheme(String themeName) {
    print("Updating theme to " + themeName);
    theme = appThemes[themeName];
    this.themeName = themeName;
    updateSetting(this.settings!["user"]["global"], "theme", themeName);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: ThemeUtils.isThemeDark ? theme!.primaryColorLight : theme!.primaryColorDark,
        statusBarColor: Colors.transparent // navigation bar color
        // status bar color
        ));
    notifyListeners();
  }

  _initSettings() async {
    settings = await SettingsUtils.getSettings();
    notifyListeners();
  }

//Leave app
  exitApp() async {
    try {
      await this.offline!.clearAll();
      //Delete sharedPref
      SharedPreferences preferences = await (SharedPreferences.getInstance() as Future<SharedPreferences>);
      await preferences.clear();
      //delte local setings and init them
      this.settings!.clear();
      this._initSettings();
      //Import secureStorage
      final storage = new FlutterSecureStorage();
      //Delete all
      await storage.deleteAll();
      this.updateTheme("clair");
      //delete hive files
      this._initOffline();
      this.gradesController = GradesController(api);
      this.homeworkController = HomeworkController(api);
    } catch (e) {
      print(e);
    }
  }

  _initBackgroundFetch() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await BackgroundFetch.configure(
          BackgroundFetchConfig(
              minimumFetchInterval: 15,
              stopOnTerminate: false,
              startOnBoot: true,
              enableHeadless: true,
              requiresBatteryNotLow: false,
              requiresCharging: false,
              requiresStorageNotLow: false,
              requiresDeviceIdle: false,
              requiredNetworkType: NetworkType.ANY), (taskId) async {
        await BackgroundService.backgroundFetchHeadlessTask(taskId);
        BackgroundFetch.finish(taskId);
      });
    }
  }

  _initOffline() async {
    //Initiate an unlocked offline controller
    offline = Offline(false);
    await offline!.init();
  }

  initControllers() {
    loginController = LoginController();
    gradesController = GradesController(this.api);
    homeworkController = HomeworkController(this.api);
  }
}
