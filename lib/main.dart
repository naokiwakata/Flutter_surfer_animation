import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      MaterialApp(theme: ThemeData(), home: const WavePage());
}

class WavePage extends StatefulWidget {
  const WavePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WaveState createState() => _WaveState();
}

/// vsync:毎フレームごとに更新を伝えるものmixin
/// SingleTickerProviderStateMixinを適用すれば良い
class _WaveState extends State<WavePage> with SingleTickerProviderStateMixin {
  // アニメーションを制御する
  late AnimationController _animationController;
  double y = 0;

  @override
  void initState() {
    super.initState();
    //初期化
    _animationController = AnimationController(
      vsync: this, //お決まり
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.repeat(); //リピート設定
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // サーファーの動きを制御する関数　いわゆる三角関数で上下させる
  double f(double b) {
    final height = MediaQuery.of(context).size.height; // 画面の高さ
    final y = math.sin(b * 2 * math.pi) * 30 + height * 0.4;
    return y;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => Stack(
          children: <Widget>[
            ClipPath(
              clipper: WaveClipper(
                  context: context,
                  waveControllerValue: _animationController.value,
                  offset: 0),
              // 青色をClipPathでくり抜いている
              child: Container(color: Colors.blue),
            ),
            ClipPath(
              clipper: WaveClipper(
                  context: context,
                  waveControllerValue: _animationController.value,
                  offset: 0.3),
              // うすい青色をClipPathでくり抜いている
              child: Container(color: Colors.blueAccent.withOpacity(0.3)),
            ),
            ClipPath(
              clipper: WaveClipper(
                  context: context,
                  waveControllerValue: _animationController.value,
                  offset: 0.7),
              // 良い感じの青色をClipPathでくり抜いている
              child: Container(color: Colors.lightBlue.withOpacity(0.3)),
            ),
            // サーファーのアニメーション
            Positioned(
                left: MediaQuery.of(context).size.width / 2,
                top: f(_animationController.value), // 高さが sin関数に従って変化する
                width: 100,
                child: Surfer(
                  waveControllerValue: _animationController.value,
                )),
          ],
        ),
      ),
    );
  }
}

// 波の形に切り抜く
class WaveClipper extends CustomClipper<Path> {
  WaveClipper({
    required this.context,
    required this.waveControllerValue,
    required this.offset,
  }) {
    //コンストラクター
    final width = MediaQuery.of(context).size.width; // 画面の横幅
    final height = MediaQuery.of(context).size.height; // 画面の高さ

    // coordinateListに波の座標を追加
    // 結局は関数を作って、そのx、y座標のリストを作成して表示させてるだけ
    for (var i = 0; i <= width / 3; i++) {
      // 毎回違うwaveControllerValueが入ってくる
      // 0 < waveControllerValue < 1 なので i/widthでそれに合わせる
      final step = (i / width) - waveControllerValue;

      // x,y座標を定義
      final x = i.toDouble() * 3;
      //final y = math.sin(step * 2 * math.pi - offset) * 45 + height * 0.5;
      final y = f(step, height, offset);
      coordinateList.add(
        Offset(x, y),
      );
    }
  }

  double f(double x, double b, double offset) {
    // math.pi は円周率
    // offset は位相のズレ
    // y = sin(aπ-b) + c
    final y = math.cos(x * 2 * math.pi - offset) * 55 + b * 0.5;
    return y;
  }

  final BuildContext context;
  final double waveControllerValue; // waveController.valueの値
  final double offset; // 波のずれ
  final List<Offset> coordinateList = []; // 波の座標のリスト

  //切り抜く形
  @override
  Path getClip(Size size) {
    final path = Path()
      //             false -> 最後に始点に戻らない
      ..addPolygon(coordinateList, false) //リストの座標を直線で繋ぐ
      ..lineTo(size.width, size.height) // 画面右下へ
      ..lineTo(0, size.height) // 画面左下へ
      ..close(); // 始点に戻る
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) =>
      waveControllerValue != oldClipper.waveControllerValue;
}

class Surfer extends StatefulWidget {
  const Surfer({
    Key? key,
    required this.waveControllerValue,
  }) : super(key: key);

  final double waveControllerValue;

  @override
  SurferState createState() => SurferState();
}

class SurferState extends State<Surfer> {
  double top = 10;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: top,
      child: Image.asset(
        'images/surfing_woman.png',
      ),
    );
  }
}
