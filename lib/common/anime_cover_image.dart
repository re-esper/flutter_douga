import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AnimeCoverImage extends StatelessWidget {
  final String _imgUrl;
  final double _width;
  final double _height;

  AnimeCoverImage(this._imgUrl, this._width, this._height);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ClipRRect(
          child: Image(
          image: CachedNetworkImageProvider(_imgUrl),
          fit: BoxFit.cover,
          width: _width,
          height: _height,
        ),
        borderRadius: BorderRadius.circular(3.0),
      ),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
    );
  }
}