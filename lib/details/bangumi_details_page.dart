import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;
import 'package:palette_generator/palette_generator.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter_douga/details/actor_details_page.dart';
import 'package:flutter_douga/details/bangumi_player_page.dart';
import 'package:flutter_douga/public.dart';

class BangumiDetailsPage extends StatefulWidget {
  final String _mediaId;
  final String _imageUrl;
  const BangumiDetailsPage(this._mediaId, this._imageUrl);
  @override
  BangumiDetailsPageState createState() => BangumiDetailsPageState();
}

class BangumiDetailsPageState extends State<BangumiDetailsPage> {
  static const _baseUrl = "http://www.dilidili3.com/media/";
  var _bangumiData = {};
  double _navAlpha = 0;
  ScrollController _scrollController = ScrollController();
  Color _pageColor = Colors.white;
  bool _isDescUnfold = false;
  bool _isCoverBroken = false;

  @override
  void initState() {
    super.initState();
    _fetchBangumiData();

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

  Future _fetchBangumiData() async {
    String mediaId = widget._mediaId;
    if (Storage.hasKey(mediaId)) {
      var cacheData = Storage.getObject(mediaId);
      int cacheTime = cacheData['_cacheTime'];
      if (DateTime.now().millisecondsSinceEpoch - cacheTime < BANGUMI_REFRESH_INTERVAL) {
        setState(() {
          int themeColor = cacheData['_themeColor'];
          _pageColor = Color(themeColor == 0 ? DEFAULT_THEME_COLOR : themeColor);
          _isCoverBroken = themeColor == 0;
          _bangumiData = cacheData;
        });
        return;
      }
    }

    var response = await http.get(_baseUrl + mediaId);
    if (response.statusCode == 200) {
      _bangumiData = {};
      await _parseBangumiData(response.body);
      await _generateThemeColor();
    }
    _bangumiData['_cacheTime'] = DateTime.now().millisecondsSinceEpoch;
    _bangumiData['_themeColor'] = _isCoverBroken ? 0 : _pageColor.value;
    Storage.putObject(mediaId, _bangumiData);

    if (mounted) setState(() {});
  }

  Future _generateThemeColor() async {
    await PaletteGenerator.fromImageProvider(CachedNetworkImageProvider(widget._imageUrl), timeout: Duration(seconds: 4)).then((value) {
      PaletteGenerator palette = value;
      _pageColor = palette.darkVibrantColor != null ? palette.darkVibrantColor.color : Color(DEFAULT_THEME_COLOR);
    }).catchError((e) {
      _pageColor = Color(DEFAULT_THEME_COLOR);
      _isCoverBroken = true;
    });
  }

  Future _parseBangumiData(String html) async {
    var document = await Future(() => parse(html));
    var root = document.querySelector('div.srch-result-wrap');
    var ele = root.querySelector('a#thumb_img > img');
    _bangumiData['name'] = ele.attributes['title'].trim();
    _bangumiData['image'] = ele.attributes['src'];
    _bangumiData['year'] = root.querySelector('div.result-tit-sub > span.tit-info').text.trim();
    ele = root.querySelector('dl.srch-result-info');
    var dts = ele.querySelectorAll('dt');
    var dds = ele.querySelectorAll('dd');
    String shortdesc = "";
    String desc = "";
    for (int i = 0; i < dts.length; ++i) {
      var dt = dts[i].text.trim();
      if (dt == '简\u00A0介：') {
        dds[i].querySelector('a').remove();
        desc = dds[i].text.trim();
        break;
      }
      if (i > 0) shortdesc += ' / ';
      shortdesc += dt + dds[i].text.trim();
    }
    _bangumiData['shortdesc'] = shortdesc;
    _bangumiData['desc'] = desc;

    var eleTagLinks = ele.querySelectorAll('a.tag_link');
    List<Map> actorList = [];
    for (var ele in eleTagLinks) {
      var url = ele.attributes['href'];
      if (url.indexOf('/cv/') != -1) {
        var name = ele.text.trim();
        if (isValidActor(name)) {
          actorList.add({
            'name': name,
            'url': url,
          });
        }
      }
    }
    _bangumiData['actors'] = actorList;
    var sourceEles = document.querySelectorAll('ul.source-lst');    
    var calcSourceScore = (dom.Element element) {
      int score = element.children.length;
      var id = element.attributes['id'];
      // perfer to use m3u8 sources
      if (id.indexOf("m3u8") != -1) return score + 100;
      return score;
    };
    var sourceEle;
    int maxscore = 0;
    for (var ele in sourceEles) {
      int score = calcSourceScore(ele);
      if (score > maxscore) {
        sourceEle = ele;
        maxscore = score;
      }
    }
    List<Map> videoList = [];
    Map nametbl = {};
    if (sourceEle != null) {
      var videoEles = sourceEle.querySelectorAll('li > a.source-lst-tab');
      for (var ele in videoEles) {
        String url = ele.attributes['href'];
        if (!url.startsWith("http")) continue;
        var name = ele.text.trim();
        if (nametbl.containsKey(name)) continue;
        nametbl[name] = true;
        videoList.add({'name': name, 'url': url});
      }
      videoList.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    }
    _bangumiData['episodes'] = videoList;
  }

  @override
  Widget build(BuildContext context) {
    Screen.updateStatusBarStyle(SystemUiOverlayStyle.light);
    if (_bangumiData.isEmpty) {
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
                      _buildBangumiHeader(),
                      _buildActorSection(),
                      _buildDescSection(),
                      _buildEpisodeSection(),
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
                    _bangumiData['name'],
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

  Widget _buildBangumiHeader() {
    var width = Screen.width;
    var height = 218.0 + Screen.topSafeHeight;
    return Container(
      width: width,
      height: height,
      child: Stack(
        children: <Widget>[
          Image(
            image: CachedNetworkImageProvider(_bangumiData['image']),
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
            padding: EdgeInsets.fromLTRB(15, 54 + Screen.topSafeHeight, 10, 0),
            color: Colors.transparent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  decoration: _isCoverBroken
                      ? null
                      : BoxDecoration(
                          boxShadow: [BoxShadow(color: Color(0x66000000), offset: Offset(1.0, 1.0), blurRadius: 5.0, spreadRadius: 2)],
                        ),
                  child: AnimeCoverImage(_bangumiData['image'], 100, 133),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _bangumiData['name'],
                        style: TextStyle(fontSize: fixedFontSize(20), color: Colors.white, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5),
                      Text(
                        formatShortTitle(_bangumiData['name']) + ' ' + _bangumiData['year'],
                        style: TextStyle(fontSize: fixedFontSize(16), color: Colors.white, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 10),
                      Text(
                        _bangumiData['shortdesc'],
                        style: TextStyle(color: Colors.white, fontSize: fixedFontSize(12)),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActorSection() {
    if ((_bangumiData['actors'] as List).isEmpty) {
      return Container();
    }
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 15),
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              '声优',
              style: TextStyle(fontSize: fixedFontSize(16), fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          SizedBox(height: 10),
          SizedBox.fromSize(
            size: Size.fromHeight(30.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: (_bangumiData['actors'] as List).length,
              itemBuilder: (BuildContext context, int index) {
                return _buildActorItem(context, index);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActorItem(BuildContext context, int index) {
    var data = (_bangumiData['actors'] as List)[index];
    double paddingRight = index == (_bangumiData['actors'] as List).length - 1 ? 15 : 6;
    double paddingLeft = index == 0 ? 15 : 6;
    return GestureDetector(
      onTap: () {
        pushPage(context, ActorDetailsPage(data['name'], data['url']));
      },
      child: Container(
        padding: EdgeInsets.only(left: 12, right: 8),
        margin: EdgeInsets.only(left: paddingLeft, right: paddingRight),
        decoration: BoxDecoration(
          color: Color(0x60000000),
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              data['name'],
              style: TextStyle(fontSize: fixedFontSize(12), color: Colors.white),
            ),
            Icon(
              Icons.keyboard_arrow_right,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescSection() {
    return Container(
      padding: EdgeInsets.only(top: 15, left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '简介',
            style: TextStyle(fontSize: fixedFontSize(16), fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 10),
          Text(
            _bangumiData['desc'],
            style: TextStyle(
              fontSize: fixedFontSize(14),
              color: Colors.white,
            ),
            maxLines: _isDescUnfold ? null : 3,
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

  Widget _buildEpisodeSection() {
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 20, left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '剧集',
            style: TextStyle(fontSize: fixedFontSize(16), fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 10),
          Wrap(
            children: _buildEpisodeItems(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildEpisodeItems() {
    var datas = _bangumiData['episodes'] as List;
    List<Widget> widgets = [];
    for (var data in datas) {
      widgets.add(Container(
        margin: const EdgeInsets.only(left: 15.0),
        child: FlatButton(
          color: Color(0x66000000),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
          onPressed: () {
            storageAddToIdList(widget._mediaId, KEY_HISTORY);
            pushPage(context, BangumiPlayerPage(data['url']));
          },
          child: Text(
            data['name'],
            style: TextStyle(color: Colors.white),
          ),
        ),
      ));
    }
    return widgets;
  }
}
