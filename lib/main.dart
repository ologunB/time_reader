import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

void main() {
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

class _MyHomePageState extends State<MyHomePage> {
  TextStyle style =
      const TextStyle(color: Color(0xff03fc0f), fontFamily: 'Schyler');
  DateTime now = DateTime.now();
  DateTime startDate = DateTime.now();
  int diff = 0;
  Timer? mTimer;

  @override
  void initState() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      now = DateTime.now();
      setState(() {});
    });
    super.initState();
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
                Text(
                  DateFormat('EEE MMMM dd, yyy').format(now),
                  style: style.copyWith(fontSize: 30.sp),
                ),
                SizedBox(height: 15.h),
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                          alignment: Alignment.topLeft,
                          child: timeAM(DateFormat('a').format(now))),
                      Container(
                          color: Colors.black,
                          child: timeHR(DateFormat('hh:mm').format(now))),
                      Align(
                          alignment: Alignment.bottomRight,
                          child: timeSEC(DateFormat(':ss').format(now))),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                InkWell(
                  onTap: () {
                    chooseStart(context);
                  },
                  child: Text(
                    formatCounter(),
                    style: style.copyWith(fontSize: 80.sp),
                  ),
                ),
                SizedBox(height: 30.h),
                Visibility(
                  visible: diff == 0,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.play_circle_outline, color: style.color)
                    ],
                  ),
                )
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
    return '$hr$min:$sec';
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
        diff = startDate.difference(now).inSeconds;
        if (diff > 0) startCounter();
        setState(() {});
      });
    });
  }

  startCounter() {
    if (mTimer?.isActive ?? false) {
      mTimer?.cancel();
      setState(() {});
    } else {
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
    return Padding(
      padding: EdgeInsets.only(top: 8.h, right: 4.h),
      child: Text(
        a,
        style: style.copyWith(fontSize: 50.sp, height: 1),
      ),
    );
  }

  Widget timeHR(String a) {
    return Text(
      a,
      style: style.copyWith(fontSize: 100.sp, height: 1),
    );
  }

  Widget timeSEC(String a) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        a,
        style: style.copyWith(fontSize: 80.sp, height: 1),
      ),
    );
  }
}
