import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_douga/details/bangumi_details_page.dart';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:palette_generator/palette_generator.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter_douga/public.dart';

class ActorDetailsPage extends StatefulWidget {
  final String _actorName;
  final String _actorUrl;
  const ActorDetailsPage(this._actorName, this._actorUrl);
  @override
  ActorDetailsPageState createState() => ActorDetailsPageState();
}

class ActorDetailsPageState extends State<ActorDetailsPage> {
  static const String _baseBaikeUrl = "https://baike.baidu.com/item/";
  var _actorData = {};
  List<Map> _actorWorkList = [];
  double _navAlpha = 0;
  ScrollController _scrollController = new ScrollController();
  Color _pageColor = Colors.white;
  bool _isDescUnfold = false;

  static const int _flutterDefaultTransitionTime = 1000; // 1 second
  int _startTimeStamp = 0;

  @override
  void initState() {
    super.initState();

    _startTimeStamp = DateTime.now().millisecondsSinceEpoch;

    _fetchActorData();
    _fetchActorWorksData();

    storageAddToIdList(parseActorId(widget._actorUrl), KEY_ACTORS);

    _scrollController.addListener(() {
      var offset = _scrollController.offset;
      if (offset < 0) {
        if (_navAlpha != 0) {
          setState(() {
            _navAlpha = 0;
          });
        }
      } else if (offset < 50) {
        setState(() {
          _navAlpha = 1 - (50 - offset) / 50;
        });
      } else if (_navAlpha != 1) {
        setState(() {
          _navAlpha = 1;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Screen.updateStatusBarStyle(SystemUiOverlayStyle.light);

    if (_actorData.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Image.asset('images/icon_arrow_back_black.png'),
          ),
        ),
        body: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            color: _pageColor,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: EdgeInsets.only(top: 0),
                    children: <Widget>[
                      _buildActorPageHeader(),
                      _buildActorDescription(),
                      _buildActorWorkSection(),
                    ],
                  ),
                )
              ],
            ),
          ),
          _buildNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Stack(
      children: <Widget>[
        Container(
          width: 44,
          height: Screen.navigationBarHeight,
          padding: EdgeInsets.fromLTRB(5, Screen.topSafeHeight, 0, 0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Image.asset('images/icon_arrow_back_white.png'),
          ),
        ),
        Opacity(
          opacity: _navAlpha,
          child: Container(
            decoration: BoxDecoration(color: _pageColor),
            padding: EdgeInsets.fromLTRB(5, Screen.topSafeHeight, 0, 0),
            height: Screen.navigationBarHeight,
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset('images/icon_arrow_back_white.png'),
                  ),
                ),
                Expanded(
                  child: Text(
                    widget._actorName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(width: 44),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildActorPageHeader() {
    var width = Screen.width;
    var height = 218.0 + Screen.topSafeHeight;
    return Container(
      width: width,
      height: height,
      child: Stack(
        children: <Widget>[
          Image(
            image: CachedNetworkImageProvider(_actorData['image'] ?? ""),
            fit: BoxFit.cover,
            width: width,
            height: height,
          ),
          Opacity(
            opacity: 0.7,
            child: Container(color: _pageColor, width: width, height: height),
          ),
          Container(
            width: width,
            height: height,
            padding: EdgeInsets.fromLTRB(30, 54 + Screen.topSafeHeight, 30, 20),
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(_actorData['image'] ?? ""),
                  radius: 50.0,
                ),
                SizedBox(height: 10),
                Text(
                  widget._actorName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActorDescription() {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '简介',
            style: TextStyle(fontSize: fixedFontSize(16), fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 15),
          Text(
            _actorData['desc'],
            style: TextStyle(
              fontSize: fixedFontSize(14),
              color: Colors.white,
            ),
            maxLines: _isDescUnfold ? null : 5,
            overflow: TextOverflow.clip,
          ),
          SizedBox(height: 5),
          GestureDetector(
            onTap: () => setState(() {
              _isDescUnfold = !_isDescUnfold;
            }),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  _isDescUnfold ? '收起' : '显示全部',
                  style: TextStyle(fontSize: fixedFontSize(14), color: Colors.white),
                ),
                Icon(
                  _isDescUnfold ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActorWorkSection() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              '参演作品',
              style: TextStyle(fontSize: fixedFontSize(16), fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          SizedBox(height: 20),
          SizedBox.fromSize(
            size: Size.fromHeight(180),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _actorWorkList.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildWorkItem(index);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWorkItem(int index) {
    double width = 90;
    var data = _actorWorkList[index];
    double paddingRight = 0;
    if (index == _actorWorkList.length - 1) {
      paddingRight = 15;
    }
    return GestureDetector(
      onTap: () {
        pushPage(context, BangumiDetailsPage(data['id'], data['image']));
      },
      child: Container(
        margin: EdgeInsets.only(left: 15, right: paddingRight),
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AnimeCoverImage(data['image'], width, width / 0.75),
            SizedBox(height: 5),
            Text(
              data['name'],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: Colors.white),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Future _fetchActorData() async {
    var response = await http.get(_baseBaikeUrl + widget._actorName);
    if (response.statusCode != 200) {
      _pageColor = Color(DEFAULT_THEME_COLOR);
      setState(() {
        _actorData['desc'] = "";
      });
      return;
    }

    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - _startTimeStamp < _flutterDefaultTransitionTime) {
      await Future.delayed(Duration(milliseconds: _flutterDefaultTransitionTime - (now - _startTimeStamp)));
    }

    var document = parse(Utf8Decoder().convert(response.bodyBytes));
    var actorData = {};
    var ele = document.querySelector('div.lemma-summary');
    if (ele != null) {
      var supEles = ele.querySelectorAll('sup.sup--normal');
      for (var e in supEles) e.remove();
      var supAnchorEles = ele.querySelectorAll('a.sup-anchor');
      for (var e in supAnchorEles) e.remove();
    }
    actorData['desc'] = ele != null ? ele.text.trim() : "";
    ele = document.querySelector('div.summary-pic > a > img');
    if (ele != null) {
      actorData['image'] = ele.attributes['src'];
      await PaletteGenerator.fromImageProvider(CachedNetworkImageProvider(actorData['image']), timeout: Duration(seconds: 4)).then((value) {
        PaletteGenerator palette = value;
        _pageColor = palette.darkVibrantColor != null ? palette.darkVibrantColor.color : Color(DEFAULT_THEME_COLOR);
      }).catchError((e) {
        _pageColor = Color(DEFAULT_THEME_COLOR);
      });
    } else {
      _pageColor = Color(DEFAULT_THEME_COLOR);
    }
    setState(() {
      _actorData = actorData;
    });
  }

  Future _fetchActorWorksData() async {
    var response = await http.get(widget._actorUrl);
    if (response.statusCode == 200) {
      var document = parse(response.body);
      var mediaListEle = document.querySelector('ul.media-list');
      var animeEles = mediaListEle != null ? mediaListEle.querySelectorAll('li.media') : [];
      for (var animeEle in animeEles) {
        var ele = animeEle.querySelector('a.media-object');
        var id = parseMediaId(ele.attributes['href']);
        var image = ele.querySelector('img').attributes['data-src'];
        ele = animeEle.querySelector('div.media-body');
        var title = ele.querySelector('h4.media-heading > a').text.trim();
        _actorWorkList.add({
          'name': title,
          'id': id,
          'image': image,
        });
      }
      setState(() {});
    }
  }
}
