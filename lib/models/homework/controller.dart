import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ynotes/classes.dart';
import 'package:ynotes/models/agenda/controller.dart';
import 'package:ynotes/models/homework/utils.dart';
import 'package:ynotes/usefulMethods.dart';
import 'package:stack/stack.dart' as stack;

HomeworkController hwcontroller;

class HomeworkController extends ChangeNotifier {
  final api;
  List<Homework> _old = List();
  List<Homework> unloadedHW = List<Homework>();
  API _api;
  bool isFetching = false;
  int examsCount = 0;
  List<Homework> get getHomework => _old;

  Future<void> refresh({bool force = false, refreshFromOffline = false}) async {
    isFetching = true;
    notifyListeners();
    //ED
    if (refreshFromOffline) {
      _old = await HomeworkUtils.getReducedListHomework();
      _old.sort((a, b) => a.date.compareTo(b.date));
      notifyListeners();
    } else {
      _old = await HomeworkUtils.getReducedListHomework(forceReload: true);
      _old.sort((a, b) => a.date.compareTo(b.date));
      notifyListeners();
    }
    await prepareOld(_old);
    isFetching = false;
    notifyListeners();
  }

  //Load all events
  void loadAll() async {
    try {
      isFetching = true;
      notifyListeners();
      await Future.forEach(unloadedHW, (Homework hw) async {
        await _api.getHomeworkFor(hw.date);
        try {
          unloadedHW.remove(hw);
        } catch (e) {}
        await refresh(refreshFromOffline: true);

        notifyListeners();
      });
      prepareExamsCount();
      isFetching = false;
      notifyListeners();
    } catch (e) {
      prepareExamsCount();
      isFetching = false;
      notifyListeners();
    }
  }

  void prepareOld(List<Homework> oldHW) async {
    oldHW.forEach((element) {
      //remove duplicates
      if (!element.loaded &&
          !unloadedHW.any((unloadedelement) =>
              unloadedelement.rawContent == element.rawContent &&
              unloadedelement.disciplineCode == element.disciplineCode)) {
        //Add element at the end of the task
        try {
          unloadedHW.add(element);
        } catch (e) {}
      }
    });
    await loadAll();
  }

  void prepareExamsCount() {
    List<Homework> hwList = getHomework;
    if (hwList != null) {
      examsCount = hwList.where((element) => element.isATest).length;
      notifyListeners();
    } else {
      examsCount = 0;
      notifyListeners();
    }
  }

  HomeworkController(this.api) {
    _api = api;
    refresh();
  }
}
