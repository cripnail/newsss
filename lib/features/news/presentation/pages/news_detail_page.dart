import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:newsss/features/news/domain/entities/news_article.dart';
import 'package:newsss/features/news/presentation/bloc/news_bloc.dart';
import 'package:newsss/features/news/presentation/widgets/comment_list_widget.dart';
import 'package:newsss/core/widgets/loading_indicator.dart';

class NewsDetailPage extends StatefulWidget {
  final NewsArticle article;
  final bool scrollToComments;

  const NewsDetailPage(
      {super.key, required this.article, this.scrollToComments = false});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _commentsSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.scrollToComments) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 100), _scrollToComments);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToComments() {
    final context = _commentsSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = widget.article.publishedAt != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(widget.article.publishedAt!)
        : 'Date unavailable';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article.sourceName ?? 'News Details'),
      ),
      body: BlocListener<NewsBloc, NewsState>(
        listener: (context, state) {
          if (state.status == NewsStatus.error &&
              state.errorMessage?.contains('comment') == true) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.article.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    if (widget.article.author != null &&
                        widget.article.author!.isNotEmpty)
                      Expanded(
                        child: Text(
                          'By ${widget.article.author}',
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Text(
                      formattedDate,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                if (widget.article.urlToImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      widget.article.urlToImage!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                            child:
                                LoadingIndicator(message: 'Loading image...'));
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                              child:
                                  Icon(Icons.broken_image, color: Colors.grey)),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16.0),
                Text(
                  widget.article.content.isNotEmpty
                      ? widget.article.content
                      : widget.article.description,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(height: 1.5),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextButton(
                    onPressed: () => _launchUrl(widget.article.url),
                    child: const Text('Read full story...'),
                  ),
                ),
                const SizedBox(height: 24.0),
                const Divider(),
                BlocBuilder<NewsBloc, NewsState>(
                  builder: (context, state) {
                    final currentArticle = state.articles.firstWhere(
                      (a) => a.id == widget.article.id,
                      orElse: () => widget.article,
                    );
                    return CommentListWidget(
                      key: _commentsSectionKey,
                      articleUrl: currentArticle.id,
                      comments: currentArticle.comments,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
