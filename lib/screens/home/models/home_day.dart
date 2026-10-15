import 'package:f0rest/f0rest.dart';

typedef HomeDay = ({
  DateTime day,
  bool today,
  Map<String, SchedulePeriod> periods,
});
