import 'package:reading_club/utils/format.dart';

sealed class Countdown {
  const Countdown();

  static const meetingLength = Duration(hours: 2);

  factory Countdown.at(DateTime start, DateTime now) {
    if (now.isBefore(start)) return Upcoming(start.difference(now));
    final elapsed = now.difference(start);
    if (elapsed < meetingLength) return Started(elapsed);
    return const Ended();
  }
}

final class Upcoming extends Countdown {
  const Upcoming(this.left);

  final Duration left;
}

final class Started extends Countdown {
  const Started(this.elapsed);

  final Duration elapsed;
}

final class Ended extends Countdown {
  const Ended();
}

String describeCountdown(Countdown countdown) => switch (countdown) {
  Upcoming(:final left) => 'In ${formatDuration(left)}',
  Started() => 'Meeting now',
  Ended() => 'Ended',
};
