import 'dart:async';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
  var indexOfZero = 0;
  var numTap;
  static int countTime = 0;
  static int countMoves = 0;
  var point = 0;
  var isZero = true;
  bool isNewGame = true;
  late Timer _timer = Timer.periodic(Duration.zero, (_) {});
  bool _isRunning = false;

//เรียกใช้เป็นที่แรกหลังจากสร้างState
  @override
  void initState() {
    super.initState();
    setState(() {
      resetGame();
    });
  }

//ถูกเรียกใช้หลังทำ initState()เสร็จ
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(top: 180, bottom: 20),
        color: const Color.fromARGB(255, 27, 63, 141),
        child: Column(
          children: [
            Row(
              children: [
                newGame(), //methodไว้ใช้newGame
                _time(countTime), //methodไว้ใช้จับเวลา
                _moveCounter(countMoves), //methodไว้ใช้นับจำนวนการกดปุ่ม
                // _pointCount(point)
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: boardGame(),
              //Ui บอร์ดตารางของเกม
            ),
          ],
        ),
      ),
    );
  }

//newGame Button UI
  Widget newGame() {
    return Row(
      children: [
        const Padding(padding: EdgeInsets.only(left: 20)),
        ElevatedButton(
          onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('New Game ?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    resetGame();
                    Navigator.pop(context, 'Ok');
                  },
                  child: const Text('Ok'),
                ),
              ],
            ),
          ),
          child: const Text(
            'New Game',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }

//บอร์ดเกม UI
  Widget boardGame() {
    return Container(
      color: const Color.fromARGB(255, 27, 63, 141),
      child: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        itemCount: numbers.length,
        itemBuilder: (BuildContext context, int index) {
          //เอาไวตรวจสอบตำแหน่งที่ถูกของตัวเลขในarray ว่าindex อยู่ถูกตำแหน่งไหม
          bool isCorrectPosition = numbers[index] == index + 1;

          //หาเลข 0 เอาไปทำui เพื่อแยกการแสดงผล ui ของปุ่ม
          isZero = numbers[index] == 0;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            // แสดงผลui ปุ่มกด
            child: isZero
                ? Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 5, 26, 71),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  )
                : IgnorePointer(
                    ignoring: !isButtonEnabled(index),
                    child: TextButton(
                      onPressed: () {
                        if (!_isRunning) {
                          _startTimer();
                          _isRunning = true;
                        }
                        onTap(index);
                      },
                      style: (() {
                        if (isCorrectPosition) {
                          //เช็คว่าปุ่มถูกตำแหน่งไหม ถ้าถูกให้return สีส้ม,
                          return raisedCheckButtonStyle;
                        } else if (!isCorrectPosition) {
                          //เช็คว่าปุ่มถูกตำแหน่งไหม ถ้าไม่ถูกให้return สีฟ้า,
                          return raisedButtonStyle;
                        }
                      })(),
                      child: Text(
                        '${numbers[index]}', //ตัวเลขทั้งหมดในarray
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

//ตรวจสอบว่าปุ่มไหนอยู่ใกล้ 0 ให้สามารถกดปุ่มนั้นสลับกับ 0
  bool isButtonEnabled(index) {
    return
        //เช็คเลขข้างหน้าเป็น 0 หรือไม่
        index - 1 >= 0 && numbers[index - 1] == 0 && index % 4 != 0 ||
            //เช็คเลขข้างหลังเป็น 0 หรือไม่
            index + 1 < 16 && numbers[index + 1] == 0 && (index + 1) % 4 != 0 ||
            //เช็คเลขข้างบนเป็น 0 หรือไม่
            index - 4 >= 0 && numbers[index - 4] == 0 ||
            //เช็คเลขข้างล่างเป็น 0 หรือไม่
            index + 4 < 16 && numbers[index + 4] == 0;
  }

  void onTap(index) {
    setState(() {
      //ตั้งค่าnumTap = ปุ่มตัวเลขที่กด
      numTap = numbers[index];
      //หาเลข 0
      indexOfZero = numbers.indexOf(0);
      // เอาnumTap=0 เป็นการสลับที่กับตัวเลขที่กด
      numbers[numbers.indexOf(numTap)] = 0;
      //เปลี่ยน 0 เป็นตัวเลขที่กดnumTap
      numbers[indexOfZero] = numTap;

      bool numBefore = numTap == index + 1; //ค่าของตำแหน่ง index ก่อนสลับ
      bool numAfter = numTap == indexOfZero + 1; //ค่าของตำแหน่งหลังสลับ

      // ถ้าตำแหน่งของตัวเลขก่อนสลับ ไม่ถูก และ ตำแหน่งของตัวเลขหลังสลับ ถูก point+1
      if (numBefore == false && numAfter == true) {
        point++;
        // ถ้าตำแหน่งของตัวเลขก่อนสลับ ถูก และ ตำแหน่งของตัวเลขหลังสลับ ไม่ถูก point-1
      } else if (numBefore == true && numAfter == false) {
        point--;
      } else if ((numBefore == false && numAfter == false) ||
          (numBefore == true && numAfter == true)) {}
    });

    _moves();

    _checkWin();
  }

//method เช็คการจบเกม
  void _checkWin() {
    if (point == 15) {
      _stopTimer();
      showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('You Win'),
          actions: [
            TextButton(
              onPressed: () {
                resetGame();
                Navigator.pop(context, 'New Game');
              },
              child: const Text('New Game'),
            ),
          ],
        ),
      );
    }
  }

// method ให้จับเวลา
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        countTime++;
      });
    });
  }

//method ให้เวาลาที่เดินอยู่ หยุด
  void _stopTimer() {
    _timer.cancel();
    _isRunning = false;
  }

//method เริ่มเกมใหม่
  void resetGame() {
    setState(() {
      point = 0;
      _stopTimer();
      numbers.shuffle();
      countTime = 0;
      countMoves = 0;
      _isRunning = false;

      numbers.asMap().forEach((index, valueBT) {
        if (valueBT == index + 1) {
          point++;
        }
      });
    });
  }

//นับจำนวนการเดิน
  void _moves() {
    return setState(() {
      countMoves++;
    });
  }
}

// ui แสดงเวลา
Widget _time(countTime) {
  return Container(
    padding: EdgeInsets.only(left: 10),
    child: Text(
      ' Time ${countTime} s',
      style: TextStyle(fontSize: 20, color: Colors.white),
    ),
  );
}

//ui แสดงการนับการกดปุ่ม การเดิน
Widget _moveCounter(countMoves) {
  return Row(
    children: [
      const Padding(padding: EdgeInsets.only(left: 10)),
      Text(
        'Move ${countMoves}',
        style: const TextStyle(fontSize: 20, color: Colors.white),
      ),
    ],
  );
}

final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
  onPrimary: Colors.black87,
  primary: const Color.fromARGB(255, 94, 160, 225),
  minimumSize: const Size(88, 36),
  padding: const EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(15)),
  ),
);

final ButtonStyle raisedCheckButtonStyle = ElevatedButton.styleFrom(
  onPrimary: Colors.black87,
  primary: const Color.fromARGB(255, 248, 123, 91),
  minimumSize: const Size(88, 36),
  padding: const EdgeInsets.symmetric(horizontal: 16),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(15)),
  ),
);
