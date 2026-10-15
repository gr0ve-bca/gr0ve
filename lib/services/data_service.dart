import 'package:f0rest/f0rest.dart';
import 'package:gr0ve/services/auth_service.dart';
import 'package:http/http.dart' as http;

const _proxy = String.fromEnvironment('PROXY');
const _scheduleUrl = String.fromEnvironment('SCHEDULE_URL');

class DataService {
  DataService._() {
    reset();
  }
  static final instance = DataService._();

  final _client = http.Client();

  late Absences absences;
  late Bus buses;
  late Lunch lunch;
  late News news;
  Schedule? _schedule;

  void reset() {
    final proxy = _proxy.isEmpty
        ? null
        : Proxy(
            Uri.parse(_proxy),
            token: () => AuthService.instance.accessToken,
          );

    absences = Absences(HttpAbsenceSource(proxy: proxy));
    lunch = Lunch(NutrisliceSource(proxy: proxy));
    buses = Bus(source: GoogleSheetBusSource(client: _client));
    news = News(AcademyChronicleSource(client: _client));
    _schedule = null;
  }

  Future<Map<String, SchedulePeriod>> scheduleOn(DateTime day) async {
    final url = _scheduleUrl.isEmpty
        ? Uri.base.resolve('assets/assets/schedules.json')
        : Uri.parse(_scheduleUrl);
    return (_schedule ??= Schedule(url, client: _client)).on(day);
  }
}
