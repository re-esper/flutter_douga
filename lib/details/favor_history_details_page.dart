import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_douga/details/bangumi_details_page.dart';

import 'package:flutter_douga/public.dart';

class FavorHistoryDetailsPage extends StatefulWidget {
  final bool _isFavorDetails;

  @override
  State<StatefulWidget> createState() => new FavorHistoryDetailsPageState();
  FavorHistoryDetailsPage(isFavor) : _isFavorDetails = isFavor;
}

class FavorHistoryDetailsPageState extends State<FavorHistoryDetailsPage> {
  final ScrollController _controller = new ScrollController();

  List<dynamic> _bangumiList = [];
  int _page = 0;
  bool _isNoMore = false;

  FavorHistoryDetailsPageState();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      var maxScroll = _controller.position.maxScrollExtent;
      var pixels = _controller.position.pixels;
      if (maxScroll == pixels && !_isNoMore) {
        _fetchRecipeListData();
      }
    });
    _fetchRecipeListData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget._isFavorDetails ? '我的收藏' : '观看历史',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return ListView.builder(
      itemCount: _bangumiList.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            height: 10,
          );
        } else if (index < _bangumiList.length + 1) {
          return GestureDetector(
            child: _buildBangumiItem(index - 1),
            onTap: () {
              var data = _bangumiList[index - 1];
              pushPage(context, BangumiDetailsPage(data['id'], data['name']));              
            },
          );
        }
        return null;
      },
      controller: _controller,
    );
  }

  Future _fetchRecipeListData() async {
    List<String> ids = Storage.getStringList(widget._isFavorDetails ? KEY_FAVOR : KEY_HISTORY);
    if (_page * HISTORY_PAGE_ITEM_PER_PAGE >= ids.length) {
      setState(() {
        _isNoMore = true;
      });
    } else {
      int bound = min(ids.length, (_page + 1) * HISTORY_PAGE_ITEM_PER_PAGE);
      for (int index = _page * HISTORY_PAGE_ITEM_PER_PAGE; index < bound; ++index) {
        if (Storage.hasKey(ids[index])) {
          var data = Storage.getObject(ids[index]);
          data['id'] = ids[index];
          _bangumiList.add(data);
        }
      }
      _page++;
      setState(() {});
    }
  }

  Widget _buildBangumiItem(int index) {
    const double imgWidth = 100;
    const double height = imgWidth / 0.7;
    const double spaceWidth = 10;    
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
              width: Screen.width - imgWidth - spaceWidth * 3,
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
                  SizedBox(height: 10),
                  Text(
                    data['desc'],
                    style: TextStyle(color: AppColor.grey, fontSize: 14),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
