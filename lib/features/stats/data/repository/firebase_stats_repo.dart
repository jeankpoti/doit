import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_it/features/stats/domain/models/stats.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../common_widget/error_message_widget.dart';
import '../../domain/repository/stats_repo.dart';

class FirebaseStatsRepo implements StatsRepo {
  @override
  Future<void> addStats(Stats stats) {
    // TODO: implement addStats
    throw UnimplementedError();
  }

  @override
  Future<void> deleteStats(Stats stats) {
    // TODO: implement deleteStats
    throw UnimplementedError();
  }

  @override
  Future<List<Stats>> getStats() {
    // TODO: implement getStats
    throw UnimplementedError();
  }

  @override
  Future<void> updateStats(Stats stats) {
    // TODO: implement updateStats
    throw UnimplementedError();
  }

  @override
  Stream<List<Stats>> watchStats() {
    // TODO: implement watchStats
    throw UnimplementedError();
  }
}
