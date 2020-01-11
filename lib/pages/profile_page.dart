import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_douga/details/favor_history_details_page.dart';
import 'package:flutter_douga/public.dart';

class ProfilePage extends StatefulWidget {
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    Screen.updateStatusBarStyle(SystemUiOverlayStyle.light);
    List<String> favorIds = Storage.getStringList(KEY_FAVOR);
    List<String> historyIds = Storage.getStringList(KEY_HISTORY);
    List<String> actorIds = Storage.getStringList(KEY_ACTORS);
    int favorExtra = 0;
    int favorItemCount = favorIds.length;
    if (favorIds.length > PROFILE_PAGE_MAX_PREVIEWS) {
      favorExtra = favorIds.length - PROFILE_PAGE_MAX_PREVIEWS;
      favorItemCount = PROFILE_PAGE_MAX_PREVIEWS + 1;
    }
    int historyExtra = 0;
    int historyItemCount = historyIds.length;
    if (historyIds.length > PROFILE_PAGE_MAX_PREVIEWS) {
      historyExtra = historyIds.length - PROFILE_PAGE_MAX_PREVIEWS;
      historyItemCount = PROFILE_PAGE_MAX_PREVIEWS + 1;
    }
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        title: Text('我的'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              margin: EdgeInsets.only(left: 20, right: 20, bottom: 5, top: 15),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.5), borderRadius: BorderRadius.all(Radius.circular(3))),
              child: Row(
                children: <Widget>[
                  _buildMapItemView(historyIds.length.toString(), '观看'),
                  _buildMapItemView(favorIds.length.toString(), '收藏'),
                  _buildMapItemView(actorIds.length.toString(), '浏览声优'),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                pushPage(context, FavorHistoryDetailsPage(true));                
              },
              splashColor: Colors.black12,
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text(
                      "我的收藏",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Divider(height: 5, color: Colors.transparent),
                    Text(
                      '已收藏了 ' + favorIds.length.toString() + ' 个番剧',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Divider(height: 5, color: Colors.transparent),
                    SizedBox(
                      height: 30,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: ((BuildContext context, int index) {
                          return VerticalDivider(width: 5);
                        }),
                        itemCount: favorItemCount,
                        itemBuilder: (BuildContext context, int index) => _buildBangumiItem(favorIds[index], index, favorExtra),
                      ),
                    )
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                pushPage(context, FavorHistoryDetailsPage(false));
              },
              splashColor: Colors.black12,
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text(
                      "观看历史",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Divider(height: 5, color: Colors.transparent),
                    Text(
                      '已观看过 ' + historyIds.length.toString() + ' 个番剧',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Divider(height: 5, color: Colors.transparent),
                    SizedBox(
                      height: 30,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (BuildContext context, int index) {
                          return VerticalDivider(width: 5);
                        },
                        itemCount: historyItemCount,
                        itemBuilder: (BuildContext context, int index) => _buildBangumiItem(historyIds[index], index, historyExtra),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapItemView(String value, String key) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Divider(height: 5, color: Colors.transparent),
          Text(
            key,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          )
        ],
      ),
      flex: 1,
    );
  }

  Widget _buildBangumiItem(String id, int index, int extraCount) {
    if (index == PROFILE_PAGE_MAX_PREVIEWS) {
      return Container(
        width: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(3)),
          color: AppColor.primary,
        ),
        child: Text(
          extraCount.toString(),
          style: TextStyle(color: Colors.white70),
        ),
      );
    } else {
      if (Storage.hasKey(id)) {
        return ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(3)),
          child: Image(
            image: CachedNetworkImageProvider(Storage.getObject(id)['image']),
            width: 30,
            height: 30,
            fit: BoxFit.cover,
          ),
        );
      } else {
        return Container(
          width: 30,
          alignment: Alignment.center,
        );
      }
    }
  }
}
