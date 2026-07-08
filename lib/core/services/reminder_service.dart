import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Aviso local diario ("un aviso por día, nada más"). El cuerpo es la
/// misión de la semana, así el recordatorio siempre propone algo concreto.
class ReminderService {
  ReminderService._();

  static final ReminderService instance = ReminderService._();

  /// Hora local del aviso diario.
  static const reminderHour = 19;

  static const _notificationId = 1;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Notificaciones locales solo en Android, iOS y macOS. En web y en
  /// escritorio Windows/Linux el switch avisa que no está disponible.
  bool get isSupported =>
      !kIsWeb &&
      const [TargetPlatform.android, TargetPlatform.iOS, TargetPlatform.macOS]
          .contains(defaultTargetPlatform);

  Future<bool> _ensureInitialized() async {
    if (!isSupported) return false;
    if (_initialized) return true;

    tzdata.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (_) {
      // Sin zona local queda UTC: el aviso sale igual, a otra hora.
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    _initialized = await _plugin.initialize(settings: settings) ?? true;
    return _initialized;
  }

  Future<bool> _requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, sound: true) ?? false;
    }
    final macos = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    if (macos != null) {
      return await macos.requestPermissions(alert: true, sound: true) ?? false;
    }
    return false;
  }

  tz.TZDateTime _nextInstance() {
    final now = tz.TZDateTime.now(tz.local);
    var next =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, reminderHour);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    return next;
  }

  /// Programa (o reprograma) el aviso diario. Devuelve false si la
  /// plataforma no lo soporta o el sistema negó el permiso.
  Future<bool> scheduleDaily({required String body}) async {
    if (!await _ensureInitialized()) return false;
    if (!await _requestPermission()) return false;

    await _plugin.cancel(id: _notificationId);
    await _plugin.zonedSchedule(
      id: _notificationId,
      title: 'Vinko',
      body: body,
      scheduledDate: _nextInstance(),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Recordatorio diario',
          channelDescription: 'Un aviso por día, nada más',
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      // Inexacto: para un recordatorio diario da igual el minuto y evita
      // pedir el permiso de alarmas exactas.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    return true;
  }

  Future<void> cancel() async {
    if (!await _ensureInitialized()) return;
    await _plugin.cancel(id: _notificationId);
  }
}
