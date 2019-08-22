import 'package:cloud_firestore/cloud_firestore.dart';

class News {
  final String author;
  final String title;
  final String description;
  final String url;
  final String articleImage;
  final String publishedAt;

  News({
    this.author,
    this.title,
    this.description,
    this.url,
    this.articleImage,
    this.publishedAt,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return News.initialData();
    } else {
      return News(
        author: json['author'] ?? 'Not available',
        title: json['title'] ?? 'No title',
        description: json['description'] ?? 'No description',
        url: json['url'] ?? null,
        articleImage: json['urlToImage'] ?? 'https://firebasestorage.googleapis.com/v0/b/ifunny-66ef2.appspot.com/o/bg_placeholder.jpeg?alt=media&token=1f6da019-f9ed-4635-a040-33b8a0f80d25',
        publishedAt: json['publishedAt'] ?? 'Not available',
      );
    }
  }

  factory News.fromFirestore(DocumentSnapshot doc) {
    Map json = doc.data;

    if (json.isEmpty) {
      return News.initialData();
    } else {
      return News(
        author: json['author'] ?? 'Not available',
        title: json['title'] ?? 'No title',
        description: json['description'] ?? 'No description',
        url: json['url'] ?? null,
        articleImage: json['articleImage'] ?? 'https://firebasestorage.googleapis.com/v0/b/ifunny-66ef2.appspot.com/o/bg_placeholder.jpeg?alt=media&token=1f6da019-f9ed-4635-a040-33b8a0f80d25',
        publishedAt: json['publishedAt'] ?? 'Not available',
      );
    }
  }

  Map<String, dynamic> toJson() => {
        'author': author,
        'title': title,
        'description': description,
        'url': url,
        'articleImage': articleImage,
        'publishedAt': publishedAt,
      };

  factory News.initialData() {
    return News(
      author: '...',
      title: '...',
      description: '...',
      url: null,
      articleImage: 'https://firebasestorage.googleapis.com/v0/b/ifunny-66ef2.appspot.com/o/bg_placeholder.jpeg?alt=media&token=1f6da019-f9ed-4635-a040-33b8a0f80d25',
      publishedAt: '...',
    );
  }
}
