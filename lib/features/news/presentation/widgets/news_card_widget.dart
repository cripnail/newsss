import 'package:flutter/material.dart';
import '../../domain/entities/news_article.dart';

class NewsCardWidget extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTapArticle;
  final VoidCallback onTapComments;

  const NewsCardWidget({
    super.key,
    required this.article,
    required this.onTapArticle,
    required this.onTapComments,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      elevation: 2.0,
      child: InkWell(
        onTap: onTapArticle,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                article.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8.0),

              // Description
              Text(
                article.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8.0),

              // Comments Button/Indicator
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: Icon(Icons.comment_outlined, size: 18, color: Colors.grey[700]),
                  label: Text(
                    article.comments.length.toString(),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  onPressed: onTapComments,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(40, 30), // Smaller tap target
                    alignment: Alignment.centerRight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 