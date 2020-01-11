import 'package:flutter/cupertino.dart';
import 'const.dart';
import 'screen.dart';
import 'storage.dart';

void pushPage(BuildContext context, Widget page) {
  Navigator.push(
    context,
    CupertinoPageRoute(
      builder: (BuildContext context) => page,
    ),
  );
}

double fixedFontSize(double fontSize) {
  return fontSize / Screen.textScaleFactor;
}

String formatShortDesc(String str) {
  if (RegExp(r"[A-Za-z]+").hasMatch(str)) {
    // e.g. 'HD720P中字'
    return str;
  } else if (str.indexOf('完结') != -1) {
    return '已完结';
  }
  var match = RegExp(r"[0-9\.]+").firstMatch(str); // e.g. '9.5集'
  if (match != null) {
    var episodes = match.group(0);
    return '更新至第 ' + episodes + ' 集';
  }
  return str;
}

String formatShortTitle(String title) {
  int found = title.indexOf('/');
  return found != -1 ? title.substring(0, found - 1) : title;
}

String parseMediaId(String url) {
  // "http://www.dilidili3.com/media/6856/"
  var match = RegExp(r"/([0-9]+)/").firstMatch(url);
  return match != null ? match.group(1) : "";
}

String parseActorId(String url) {
  // "http://www.dilidili3.com/cv/riliyangzi/"
  int found = url.indexOf('/cv/');
  return found != -1 ? url.substring(found + 4, url.length - 1) : url;
}

bool isValidActor(String actor) {
  const List<String> ignoredNames = ['内详'];
  if (ignoredNames.indexOf(actor) != -1) {
    return false;
  }
  if (actor.indexOf('·') != -1) {
    // skip western names
    return false;
  }
  return RegExp(r"[^\x00-\xff]").hasMatch(actor);
}

String getFileExt(String uri) {
  int found = uri.lastIndexOf('.');
  return found != -1 ? uri.substring(found) : "";
}

Future bangumiSetFavorite(String id, [bool isFavorite = true]) async {
  List<String> ids = Storage.getStringList(KEY_FAVOR);
  int found = ids.indexOf(id);
  if (isFavorite) {
    if (found == -1) {
      ids.insert(0, id);
      await Storage.putStringList(KEY_FAVOR, ids);
    }
  } else if (found != -1) {
    ids.removeAt(found);
    await Storage.putStringList(KEY_FAVOR, ids);
  }
}

bool bangumiGetIsFavorite(String id) {
  return Storage.getStringList(KEY_FAVOR).indexOf(id) != -1;
}

Future storageAddToIdList(String id, String key) async {
  List<String> ids = Storage.getStringList(key);
  int found = ids.indexOf(id);
  if (found != -1) {
    ids.removeAt(found);
  }
  ids.insert(0, id);
  await Storage.putStringList(key, ids);  
}