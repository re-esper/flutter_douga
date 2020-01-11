import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter_douga/details/bangumi_list_page.dart';
import 'package:flutter_douga/details/bangumi_details_page.dart';
import 'package:flutter_douga/public.dart';

class BangumiSectionView extends StatelessWidget {
  final String _title;
  final List<Map> _dataList;
  final int _kind;

  BangumiSectionView(this._title, this._dataList, this._kind);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSectionHeader(context),
          Container(
            padding: EdgeInsets.fromLTRB(15, 10, 0, 10),
            child: Wrap(
              spacing: 15,
              runSpacing: 20,
              children: _dataList.map((data) => _buildAnimeGrids(context, data)).toList(),
            ),
          ),
          Container(
            height: 10,
            color: Color(0xFFF5F5F5),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(15, 15, 15, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(_title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Container(
                width: 80,
                height: 2,
                color: Colors.black,
              )
            ],
          ),
          GestureDetector(
            onTap: () {
              pushPage(context, BangumiListPage(_title, _kind));              
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('全部', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(width: 3),
                Icon(CupertinoIcons.forward, size: 14),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAnimeGrids(BuildContext context, Map data) {
    var width = (Screen.width - 15 * 4) / 3;
    return GestureDetector(
      onTap: () {
        pushPage(context, BangumiDetailsPage(data['id'], data['image']));
      },
      child: Container(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AnimeCoverImage(data['image'], width, width / 0.75),
            SizedBox(height: 5),
            Text(
              data['name'],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              maxLines: 1,
            ),
            SizedBox(height: 2),
            Text(
              data['shortdesc'],
              style: TextStyle(fontSize: 12, color: AppColor.grey),
            ),
          ],
        ),
      ),
    );
  }
}
