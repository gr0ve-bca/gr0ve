import 'package:spr0ut/spr0ut.dart';

import 'db_stars.dart';

class TeacherStars extends DbStars {
  TeacherStars._() : super('teacher_stars', 'TeacherStars');
  static final instance = TeacherStars._();

  @override
  List<String> fromUser(Spr0utUser u) => u.starredTeachers;

  @override
  Future<List<String>> addRemote(String uid, String key) =>
      Spr0ut.starTeacher(uid, key);

  @override
  Future<List<String>> removeRemote(String uid, String key) =>
      Spr0ut.unstarTeacher(uid, key);
}
