import 'package:flutter/material.dart';
import 'package:flutter_douga/pages/bangumi_search_list_view.dart';

class SearchBarDelegate extends SearchDelegate<String> {
  SearchBarDelegate() : super(searchFieldLabel: "搜索番剧");
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => query = "",
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: AnimatedIcon(icon: AnimatedIcons.menu_arrow, progress: transitionAnimation), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    return BangumiSearchListView(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return super.appBarTheme(context);
  }
}
