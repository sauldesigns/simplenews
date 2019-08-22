import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:simple_news/models/news.dart';

class NewsApi with ChangeNotifier {
  final String apiURL = 'https://newsapi.org/v2/';

  NewsApi() {
    fetchData();
  }

  String _jsonResponse = '';
  bool _isFetching = false;

  bool get isFetching => _isFetching;

  Future<void> fetchData(
      {String query = 'top-headlines?country=us&pageSize=100'}) async {
    _isFetching = true;
    notifyListeners();

    var response = await http
        .get(Uri.encodeFull('https://newsapi.org/v2/' + query), headers: {
      'Accept': 'application/json',
      'X-Api-Key': '7b9fb000e2244968b0f05ce6dd04c9d2'
    });

    if (response.statusCode == 200) {
      _jsonResponse = response.body;
    }

    _isFetching = false;
    notifyListeners();
  }

  String get getResponseText => _jsonResponse;

  List<News> getArticles() {
    List<News> newsArticles = [];
    if (_jsonResponse.isNotEmpty) {
      Map<String, dynamic> json = jsonDecode(_jsonResponse);
      for (int i = 0; i < json['articles'].length; ++i) {
        News temp = News.fromJson(json['articles'][i]);
        newsArticles.add(temp);
      }
    }

    return newsArticles;
  }
}
