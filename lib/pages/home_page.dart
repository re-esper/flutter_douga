import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_douga/details/bangumi_details_page.dart';
import 'package:flutter_douga/pages/search_delegate.dart';

import 'package:flutter_douga/public.dart';

import 'bangumi_section_view.dart';

import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'dart:math' show Random;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  static const _hotAnimeUrl = 'http://www.dilidili3.com/anime/';
  static const _recentAnimeUrl = 'http://www.dilidili3.com/anime/?orderby=new';
  var nowPlayingList, comingList;
  List<Map> _headlineAnimes = [];
  List<Map> _hotAnimes = [];
  List<Map> _recentAnimes = [];

  @override
  void initState() {
    super.initState();
    _fetchMainPageDatas();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        title: Text('首页'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => showSearch(context: context, delegate: SearchBarDelegate()),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_headlineAnimes.isEmpty) {
      return Center(
        child: CupertinoActivityIndicator(),
      );
    } else {
      return Container(
        child: RefreshIndicator(
          color: AppColor.primary,
          onRefresh: _fetchMainPageDatas,
          child: ListView(
            addAutomaticKeepAlives: true,
            // prevent children from redrawing
            cacheExtent: 10000,
            children: <Widget>[
              _buildBanner(),
              new BangumiSectionView('最近热播', _hotAnimes, 0),
              new BangumiSectionView('最新更新', _recentAnimes, 1),
            ],
          ),
        ),
      );
    }
  }

  Map _parseAnimeData(var element) {
    var ele = element.querySelector('a.sort_lst_thumb');
    var shortdesc = element.querySelector('p.sort_lst_txt').text.trim();
    return {
      'name': ele.attributes['title'],
      'id': parseMediaId(ele.attributes['href']),
      'image': element.querySelector('img').attributes['data-src'],
      'shortdesc': formatShortDesc(shortdesc),
    };
  }

  Future<void> _fetchHeadlineData() async {
    var response = await http.get(_hotAnimeUrl);
    if (response.statusCode == 200) {
      var document = parse(response.body);
      var animeEles = document.querySelectorAll('li.video_item');

      assert(animeEles.length > HOT_ANIME_COUNT);

      _headlineAnimes.clear();
      _hotAnimes.clear();

      List<int> headlineIndexes = [];
      var randomizer = Random(DateTime.now().millisecondsSinceEpoch);
      for (int i = 0; i < HEADLINE_ANIME_COUNT; ++i) {
        int index = 0;
        do {
          index = randomizer.nextInt(animeEles.length);
        } while (headlineIndexes.indexOf(index) != -1);
        headlineIndexes.add(index);
      }
      for (int index in headlineIndexes) {
        _headlineAnimes.add(_parseAnimeData(animeEles[index]));
      }

      for (int index = 0; index < HOT_ANIME_COUNT; ++index) {
        _hotAnimes.add(_parseAnimeData(animeEles[index]));
      }
    }
  }

  Future<void> _fetchRecentAnimeData() async {
    var response = await http.get(_recentAnimeUrl);
    if (response.statusCode == 200) {
      var document = parse(response.body);
      var animeEles = document.querySelectorAll('li.video_item');

      assert(animeEles.length > RECENT_ANIME_COUNT);

      _recentAnimes.clear();
      for (int index = 0; index < RECENT_ANIME_COUNT; ++index) {
        _recentAnimes.add(_parseAnimeData(animeEles[index]));
      }
    }
  }

  Future<void> _fetchMainPageDatas() async {
    await Future.wait([
      _fetchHeadlineData(),
      _fetchRecentAnimeData(),
    ]);
    setState(() {});
  }

  Widget _buildBanner() {
    return Container(
      color: Colors.white,
      child: CarouselSlider(
        items: _headlineAnimes.map((data) {
          return Builder(
            builder: (BuildContext context) {
              return GestureDetector(
                onTap: () {
                  pushPage(context, BangumiDetailsPage(data['id'], data['image']));
                },
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                  child: Stack(
                    children: <Widget>[
                      RotatedBox(
                        quarterTurns: 1,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(data['image']),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(3)),
                          ),
                        ),
                      ),
                      Opacity(
                        opacity: 0.5,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.all(Radius.circular(3)),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(20),
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              data['name'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                shadows: [Shadow(color: Colors.black, offset: Offset(0, 0), blurRadius: 4)],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              data['shortdesc'],
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }).toList(),
        aspectRatio: 2.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        enlargeCenterPage: true,
      ),
    );
  }
}
