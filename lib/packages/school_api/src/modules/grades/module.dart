part of school_api;

abstract class GradesModule<R extends Repository> extends Module<R, OfflineGrades> {
  GradesModule({required bool isSupported, required bool isAvailable, required R repository, required SchoolApi api})
      : super(
            isSupported: isSupported,
            isAvailable: isAvailable,
            repository: repository,
            api: api,
            offline: OfflineGrades());

  @protected
  Response<double> calculateAverage();

  List<Grade> get grades => _grades;

  @protected
  // ignore: prefer_final_fields
  List<Grade> _grades = [];
}

/* 
Things to do:
- current period. Saved to offline or KVS
- handle simulation. basically a boolean in a grade
- handle custom grades.
- handle custom subjects.
- handle filters
- handle sorting
- handle averages calculations
- handle offline
*/