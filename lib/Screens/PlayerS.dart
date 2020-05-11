import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/src/foundation/constants.dart';

// import 'player_widget.dart';

typedef void OnError(Exception exception);

const kUrl1 = 'https://luan.xyz/files/audio/ambient_c_motion.mp3';
const kUrl2 = 'https://luan.xyz/files/audio/nasa_on_a_mission.mp3';
const kUrl3 = 'http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio1xtra_mf_p';

// void main() {
//   runApp(MaterialApp(home: ExampleApp()));
// }

class ExampleApp extends StatefulWidget {
  final String url1;
  ExampleApp({
    Key key,
    this.url1,
  }) : super(key: key);
  @override
  _ExampleAppState createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  AudioCache audioCache = AudioCache();
  AudioPlayer advancedPlayer = AudioPlayer();
  String localFilePath;

  @override
  void initState() {
    super.initState();
    advancedPlayer.play(widget.url1);
    if (kIsWeb) {
      // Calls to Platform.isIOS fails on web
      return;
    }
    if (Platform.isIOS) {
      if (audioCache.fixedPlayer != null) {
        audioCache.fixedPlayer.startHeadlessService();
      }
      advancedPlayer.startHeadlessService();
    }
  }

  Future _loadFile() async {
    final bytes = await readBytes(kUrl1);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/audio.mp3');
    print(file.toString());

    await file.writeAsBytes(bytes);
    if (await file.exists()) {
      setState(() {
        localFilePath = file.path;
      });
    }
  }

  // Widget remoteUrl() {
  //   return SingleChildScrollView(
  //     child: _Tab(children: [
  //       Text(
  //         'Sample 1 ($kUrl1)',
  //         key: Key('url1'),
  //         style: TextStyle(fontWeight: FontWeight.bold),
  //       ),
  //       PlayerWidget(url: kUrl1),
  //       Text(
  //         'Sample 2 ($kUrl2)',
  //         style: TextStyle(fontWeight: FontWeight.bold),
  //       ),
  //       PlayerWidget(url: kUrl2),
  //       Text(
  //         'Sample 3 ($kUrl3)',
  //         style: TextStyle(fontWeight: FontWeight.bold),
  //       ),
  //       PlayerWidget(url: kUrl3),
  //       Text(
  //         'Sample 4 (Low Latency mode) ($kUrl1)',
  //         style: TextStyle(fontWeight: FontWeight.bold),
  //       ),
  //       PlayerWidget(url: kUrl1, mode: PlayerMode.LOW_LATENCY),
  //     ]),
  //   );
  // }

  Widget localFile() {
    return _Tab(children: [
      Text('File: $kUrl1'),
      _Btn(txt: 'Download File to your Device', onPressed: () => _loadFile()),
      Text('Current local file path: $localFilePath'),
      RaisedButton(
          child: Text("resume"),
          onPressed: () {
            advancedPlayer.resume();
          }),
      RaisedButton(
          child: Text("pause"),
          onPressed: () {
            advancedPlayer.pause();
          }),
      RaisedButton(
          child: Text("stop"),
          onPressed: () {
            advancedPlayer.stop();
            advancedPlayer.play(widget.url1);
            advancedPlayer.release();
          }),

    ]);
  }

  // Widget localAsset() {
  //   return SingleChildScrollView(
  //     child: _Tab(children: [
  //       Text('Play Local Asset \'audio.mp3\':'),
  //       _Btn(txt: 'Play', onPressed: () => audioCache.play('audio.mp3')),
  //       Text('Loop Local Asset \'audio.mp3\':'),
  //       _Btn(txt: 'Loop', onPressed: () => audioCache.loop('audio.mp3')),
  //       Text('Play Local Asset \'audio2.mp3\':'),
  //       _Btn(txt: 'Play', onPressed: () => audioCache.play('audio2.mp3')),
  //       Text('Play Local Asset In Low Latency \'audio.mp3\':'),
  //       _Btn(
  //           txt: 'Play',
  //           onPressed: () =>
  //               audioCache.play('audio.mp3', mode: PlayerMode.LOW_LATENCY)),
  //       Text('Play Local Asset Concurrently In Low Latency \'audio.mp3\':'),
  //       _Btn(
  //           txt: 'Play',
  //           onPressed: () async {
  //             await audioCache.play('audio.mp3', mode: PlayerMode.LOW_LATENCY);
  //             await audioCache.play('audio2.mp3', mode: PlayerMode.LOW_LATENCY);
  //           }),
  //       Text('Play Local Asset In Low Latency \'audio2.mp3\':'),
  //       _Btn(
  //           txt: 'Play',
  //           onPressed: () =>
  //               audioCache.play('audio2.mp3', mode: PlayerMode.LOW_LATENCY)),
  //       getLocalFileDuration(),
  //     ]),
  //   );
  // }

  Future<int> _getDuration() async {
    File audiofile = await audioCache.load('audio2.mp3');
    await advancedPlayer.setUrl(
      audiofile.path,
    );
    int duration = await Future.delayed(
        Duration(seconds: 2), () => advancedPlayer.getDuration());
    return duration;
  }

  getLocalFileDuration() {
    return FutureBuilder<int>(
      future: _getDuration(),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('No Connection...');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Text('Awaiting result...');
          case ConnectionState.done:
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            return Text(
                'audio2.mp3 duration is: ${Duration(milliseconds: snapshot.data)}');
        }
        return null; // unreachable
      },
    );
  }

  Widget notification() {
    return _Tab(children: [
      Text('Play notification sound: \'messenger.mp3\':'),
      _Btn(
          txt: 'Play',
          onPressed: () =>
              audioCache.play('messenger.mp3', isNotification: true)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<Duration>.value(
            initialData: Duration(),
            value: advancedPlayer.onAudioPositionChanged),
      ],
      child: DefaultTabController(
        length: 1,
        child: Scaffold(
            appBar: AppBar(
              // bottom: TabBar(
              //   tabs: [
              //     // Tab(text: 'Remote Url'),
              //     Tab(text: 'Local File'),
              //     // Tab(text: 'Local Asset'),
              //     // Tab(text: 'Notification'),
              //     // Tab(text: 'Advanced'),
              //   ],
              // ),
              title: Text('audioplayers Example'),
            ),
            body: Container(
              child: Column(
                children: <Widget>[
                  localFile(),
  notification()
                ],
              ),
            )),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final List<Widget> children;

  const _Tab({Key key, this.children}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: children
                .map((w) => Container(child: w, padding: EdgeInsets.all(6.0)))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String txt;
  final VoidCallback onPressed;

  const _Btn({Key key, this.txt, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
        minWidth: 48.0,
        child: RaisedButton(child: Text(txt), onPressed: onPressed));
  }
}
