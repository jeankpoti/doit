/*
TodoRepo is an abstract class that defines the methods that the TodoRepository class must implement.

Here we define what the app can do
*/

// import '../../data/models/isar_todo.dart';

import '../models/stats.dart';

abstract class StatsRepo {
  Future<void> addStats(Stats stats);
  Future<void> deleteStats(Stats stats);
  Stream<List<Stats>> watchStats();
  Future<List<Stats>> getStats();
  Future<void> updateStats(Stats stats);
}

/*

The repo in domain layer outlines what operations the app can do, bu
it doesn't worry about the specific implementation details. That's for the data layer.

- Everything in the domain layer should be technology-agnostic, which means it 
should not depend on any specific libraries or frameworks.

*/
