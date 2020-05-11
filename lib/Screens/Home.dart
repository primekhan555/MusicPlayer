import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:player/Screens/PlayerS.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();

  Future _getAllSongs() async {
    List<SongInfo> songsList = await audioQuery.getSongs();
    List<String> conSongsList = [];
    songsList.map((song) {
      Map<String, dynamic> objects() => {
            "displayName": song.displayName,
            "duration": song.duration,
            "path": song.filePath,
            "fileSize": song.fileSize,
            "title": song.title,
            "artist": song.artist,
            "year": song.year
          };
      String encoded = jsonEncode(objects());
      conSongsList.add(encoded);
    }).toString();
    return json.decode(conSongsList.toString());
  }

  Future _getAlbum() async {
    List<SongInfo> songs = await audioQuery.getSongs();
    List<String> item = [];
    songs.map((t) {
      Map<String, dynamic> map() => {
            'name': t.displayName,
            'email': t.duration,
          };
      String encoding = jsonEncode(map());

      item.add(encoding);
    }).toString();
    print("${json.decode(item.toString())}");
    // print("${item.toString()}");
  }

  @override
  void initState() {
    // _getAlbum();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Home"),
          leading: InkWell(
              onTap: () {
                _getAlbum();
              },
              child: Icon(Icons.timeline)),
        ),
        body: Container(
          child: FutureBuilder(
            future: _getAllSongs(),
            // initialData: Initi/alData,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Container(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  // return Container(child: Text(snapshot.data[0]["name"])
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      var data = snapshot.data[index];
                      int size = int.parse(data["fileSize"]);
                      return InkWell(
                        onTap: () {
                          var route = MaterialPageRoute(
                              builder: (context) =>
                                  ExampleApp(url1: data["path"]));
                          Navigator.of(context).push(route);
                        },
                        child: Container(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("Title ${data["title"]}"),
                            Text("duration ${data["duration"]}"),
                            Text("path ${data["path"]}"),
                            Text("file size ${size / 1000} kB"),
                            Text("display Name ${data["displayName"]}"),
                            Text("artist ${data["artist"]}"),
                            Text("year ${data["year"]}"),
                            Divider()
                          ],
                        )
                            // child: Text("${snapshot.data['SongInfo'][index]["_display_name"]}"),
                            ),
                      );
                    },
                  );
                }
              }
              return Center(
                  child: Container(child: CircularProgressIndicator()));
            },
          ),
        ),
      ),
    );
  }
}
