import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter_douga/common/utils.dart';

class BangumiPlayerPage extends StatefulWidget {
  final String _url;

  const BangumiPlayerPage(this._url);
  @override
  BangumiPlayerPageState createState() => BangumiPlayerPageState();
}

class BangumiPlayerPageState extends State<BangumiPlayerPage> {
  String _videoUrl = "";
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;  

  @override
  void initState() {
    super.initState();
    _fetchVideoData();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,      
    ]);
    
    _videoPlayerController?.dispose();
    _chewieController?.removeListener(_fullScreenListener);
    _chewieController?.dispose();
    super.dispose();
  }

  void _fullScreenListener() async {    
    if (_chewieController.isFullScreen) {      
      AutoOrientation.landscapeAutoMode();
    }
    else {
      AutoOrientation.portraitAutoMode();
    }    
  }

  Future _fetchVideoData() async {
    const String spattern = '<script>var \$player = {';
    const String epattern = '};</script>';
    var response = await http.get(widget._url);
    if (response.statusCode == 200) {
      String html = response.body;
      int s = html.indexOf(spattern);
      if (s != -1) {
        int e = html.indexOf(epattern, s);
        String jsonstr = html.substring(s + spattern.length - 1, e + 1);
        Map thedata = json.decode(jsonstr) as Map;
        if (thedata.containsKey('src')) {
          String url2 = thedata['src'];
          if (getFileExt(url2) == ".m3u8") {
            _videoUrl = url2;
          } else {
            const String spattern2 = 'var main = "';
            const String epattern2 = '";';
            var response2 = await http.get(url2);
            String html2 = response2.body;
            int s = html2.indexOf(spattern2);
            if (s != -1) {
              int e = html2.indexOf(epattern2, s);
              var path = html2.substring(s + spattern2.length, e);
              Uri uri = Uri.parse(url2);
              _videoUrl = uri.scheme + '://' + uri.host + path;
            }
          }
          _initializeChewie();
          setState(() {});
        }
      }
    }
  }

  void _initializeChewie() {
    print(_videoUrl);
    _videoPlayerController = VideoPlayerController.network(_videoUrl, formatHint: VideoFormat.hls);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 16 / 9,
      fullScreenByDefault: false,
      allowedScreenSleep: false,
      showControlsOnInitialize: true,
      autoPlay: true,
      looping: false,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
      // Try playing around with some of these other options:
      // showControls: false,
      // materialProgressColors: ChewieProgressColors(
      //   playedColor: Colors.red,
      //   handleColor: Colors.blue,
      //   backgroundColor: Colors.grey,
      //   bufferedColor: Colors.lightGreen,
      // ),
      // placeholder: Container(
      //   color: Colors.grey,
      // ),
      // autoInitialize: true,
    );
    _chewieController.addListener(_fullScreenListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Image.asset('images/icon_arrow_back_white.png'),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.black),
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: _videoUrl.isEmpty ? CupertinoActivityIndicator() : Chewie(controller: _chewieController),
      ),
    );
  }
}
