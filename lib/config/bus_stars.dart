import 'package:spr0ut/spr0ut.dart';

import 'db_stars.dart';

class BusStars extends DbStars {
  BusStars._() : super('bus_stars', 'BusStars');
  static final instance = BusStars._();

  @override
  List<String> fromUser(Spr0utUser u) => u.starredBuses;

  @override
  Future<List<String>> addRemote(String uid, String key) =>
      Spr0ut.starBus(uid, key);

  @override
  Future<List<String>> removeRemote(String uid, String key) =>
      Spr0ut.unstarBus(uid, key);
}
