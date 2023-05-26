import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:wakelock/wakelock.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) await Wakelock.enable();
  await Hive.initFlutter();
  await Hive.openBox<dynamic>('kUserBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Reader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Schyler'),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  TextStyle style =
      const TextStyle(color: Color(0xff03fc0f), fontFamily: 'Schyler');
  DateTime now = DateTime.now();
  DateTime startDate = DateTime.now();
  int diff = 0;
  Timer? mTimer;

  static Box<dynamic> get _userBox => Hive.box<dynamic>('kUserBox');

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    Timer.periodic(const Duration(seconds: 1), (timer) {
      now = DateTime.now();
      setState(() {});
    });
    doCalc();

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  doCalc() {
    int time = _userBox.get('time', defaultValue: now.millisecondsSinceEpoch);
    diff = (time - now.millisecondsSinceEpoch) ~/ 1000;
    if (diff > 0) {
      startCounter();
    } else {
      diff = 0;
    }
    setState(() {});
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    doCalc();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(428, 926),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => Scaffold(
          backgroundColor: Colors.black,
          body: Padding(
            padding: EdgeInsets.all(20.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 4),
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: Text(
                      DateFormat('EEE MMMM dd, yyy')
                          .format(now)
                          .replaceAll('1', ' 1'),
                      style: style.copyWith(fontSize: 4430.sp),
                    ),
                  ),
                ),
                SizedBox(height: 15.h),
                FittedBox(
                  fit: BoxFit.fitHeight,
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Align(
                            alignment: Alignment.topLeft,
                            child: timeAM(DateFormat('a').format(now))),
                        Container(
                            color: Colors.black,
                            child: timeHR(DateFormat('hh:mm')
                                .format(now)
                                .replaceAll('1', ' 1')
                                .trim())),
                        Align(
                            alignment: Alignment.bottomRight,
                            child: timeSEC(DateFormat(':ss')
                                .format(now)
                                .replaceAll('1', ' 1'))),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 4),
                  child: InkWell(
                    onTap: () {
                      chooseStart(context);
                    },
                    child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: Text(
                        formatCounter(),
                        style: style.copyWith(fontSize: 34232.sp),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          )),
    );
  }

  String formatCounter() {
    Duration a = Duration(seconds: diff);
    String hr = a.inHours == 0 ? '' : '${a.inHours}:';
    String min = (a.inMinutes % 60).toString().length == 1
        ? '0${a.inMinutes % 60}'
        : '${a.inMinutes % 60}';
    String sec = (a.inSeconds % 60).toString().length == 1
        ? '0${a.inSeconds % 60}'
        : '${a.inSeconds % 60}';
    return '$hr$min:$sec'.replaceAll('1', ' 1');
  }

  Future<void> chooseStart(BuildContext context) async {
    final DateTime initialDate = DateTime.now();

    await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate,
      lastDate: DateTime(2030),
      helpText: 'STARTING BY',
    ).then((DateTime? date) async {
      if (date == null) {
        return;
      }
      startDate = date;
      final TimeOfDay initial = TimeOfDay.now();

      await showTimePicker(
        context: context,
        helpText: 'STARTING BY',
        initialTime: initial,
      ).then((TimeOfDay? time) {
        if (time == null) {
          return;
        }
        startDate =
            startDate.add(Duration(hours: time.hour, minutes: time.minute));
        _userBox.put('time', startDate.millisecondsSinceEpoch);
        diff = startDate.difference(now).inSeconds;
        print('diff: $diff');
        if (diff > 0) {
          startCounter();
        } else {
          diff = 0;
        }
        setState(() {});
      });
    });
  }

  startCounter() {
    if (diff == 0) {
      mTimer?.cancel();
      setState(() {});
    } else {
      if (mTimer?.isActive ?? false) mTimer?.cancel();
      mTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (diff == 0) {
          mTimer?.cancel();
        } else {
          diff--;
        }
        setState(() {});
      });
    }
  }

  Widget timeAM(String a) {
    return Container(
      padding: EdgeInsets.only(top: 8.h, right: 4.h),
      child: Text(
        a,
        style: style.copyWith(fontSize: 440.sp, height: 1),
      ),
    );
  }

  Widget timeHR(String a) {
    return Container(
      child: Text(
        a,
        style: style.copyWith(fontSize: 1000.sp, height: .9),
      ),
    );
  }

  Widget timeSEC(String a) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        a,
        style: style.copyWith(fontSize: 840.sp, height: 1),
      ),
    );
  }
}
