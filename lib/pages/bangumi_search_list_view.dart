import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_douga/details/bangumi_details_page.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

import 'package:flutter_douga/public.dart';

class BangumiSearchListView extends StatefulWidget {
  final String _keyword;
  BangumiSearchListView(this._keyword);

  @override
  BangumiSearchListViewState createState() => new BangumiSearchListViewState();
}

class BangumiSearchListViewState extends State<BangumiSearchListView> {
  static const _baseUrl = 'http://www.dilidili3.com/public/api.php?app=search&q=';
  List<Map> _bangumiList = [];
  int _page = 1;
  bool _isNoMore = false;
  ScrollController _scrollController = new ScrollController();

  BangumiSearchListViewState();

  @override
  void initState() {
    super.initState();
    _fetchListData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _fetchListData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  Widget _buildBody() {
    if (_bangumiList.isEmpty) {
      return Center(
        child: CupertinoActivityIndicator(),
      );
    }
    return Container(
      child: ListView.builder(
        itemCount: _bangumiList.length,
        itemBuilder: (BuildContext context, int index) {
          if (index + 1 == _bangumiList.length) {
            return Container(
              padding: EdgeInsets.all(10),
              child: Center(
                child: Offstage(
                  offstage: _isNoMore,
                  child: CupertinoActivityIndicator(),
                ),
              ),
            );
          }
          return _buildBangumiItem(index);
        },
        controller: _scrollController,
      ),
    );
  }

  Map _parseAnimeData(var element) {
    var ele = element.querySelector('a.media-object');
    var id = parseMediaId(ele.attributes['href']);
    var image = ele.querySelector('img').attributes['data-src'];
    ele = element.querySelector('div.media-body');
    var title = ele.querySelector('h4.media-heading > a').text.trim();
    var eleDescMore = ele.querySelector("p.media-text > a");
    if (eleDescMore != null) eleDescMore.remove();
    var desc = ele.querySelector("p.media-text").text.trim();
    var date = ele.querySelector("div.media-info > span.date").text.trim();
    return {
      'name': title,
      'id': id,
      'image': image,
      'shortdesc': desc,
      'date': date,
    };
  }

  Future<void> _fetchListData() async {
    if (_isNoMore) return;

    String url = _baseUrl + widget._keyword + '&page=' + _page.toString();

    var response = await http.get(url);
    if (!mounted) return;
    if (response.statusCode == 200) {
      var document = parse(response.body);
      var mediaListEle = document.querySelector('ul.media-list');
      var animeEles = mediaListEle != null ? mediaListEle.querySelectorAll('li.media') : [];
      if (animeEles.isEmpty) {
        _isNoMore = true;
      } else {
        for (var ele in animeEles) {
          _bangumiList.add(_parseAnimeData(ele));
        }
        _page++;
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  Widget _buildBangumiItem(int index) {
    const double imgWidth = 100;
    const double height = imgWidth / 0.7;
    const double spaceWidth = 10;
    const double actionWidth = 50;
    var data = _bangumiList[index];
    return GestureDetector(
      onTap: () {
        pushPage(context, BangumiDetailsPage(data['id'], data['image']));
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(spaceWidth * 2, spaceWidth, 0, spaceWidth),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColor.lightGrey, width: 0.5),
          ),
          color: Colors.white,
        ),
        child: Row(
          children: <Widget>[
            AnimeCoverImage(data['image'], imgWidth, height),
            Container(
              padding: EdgeInsets.fromLTRB(spaceWidth, 0, spaceWidth, 0),
              height: height,
              width: Screen.width - imgWidth - spaceWidth * 3 - actionWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    data['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Text(
                    data['shortdesc'],
                    style: TextStyle(color: AppColor.grey, fontSize: 14),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Icon(
                        Icons.access_time,
                        color: AppColor.grey,
                        size: 16,
                      ),
                      SizedBox(width: 5),
                      Text(
                        data['date'] + '  ',
                        style: TextStyle(color: AppColor.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
            Container(
              width: actionWidth,
              height: height,
              child: GestureDetector(
                onTap: () {
                  String id = data['id'];
                  bool isFavor = bangumiGetIsFavorite(id);
                  if (!isFavor && !Storage.hasKey(id)) {
                    var tempCache = Map.from(data);
                    tempCache['_cacheTime'] = 0;
                    Storage.putObject(id, tempCache);
                  }                  
                  setState(() {
                    bangumiSetFavorite(id, !isFavor);
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 5),
                    Icon(
                      bangumiGetIsFavorite(data['id']) ? Icons.favorite : Icons.favorite_border,
                      size: 28,
                      color: Color(0xFFF7AC3A),
                    ),
                    SizedBox(height: 5),
                    Text('收藏', style: TextStyle(color: Color(0xFFF7AC3A)))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
