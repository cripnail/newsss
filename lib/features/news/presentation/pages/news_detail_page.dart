import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/news_article.dart';
import '../bloc/news_bloc.dart';
import '../widgets/comment_list_widget.dart';
import '../../../../core/widgets/loading_indicator.dart'; // If needed for image loading

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
  final GlobalKey _commentsSectionKey =
      GlobalKey(); // Key for the comments section

  @override
  void initState() {
    super.initState();
    // Выполняем скролл после отрисовки первого кадра, если нужно
    if (widget.scrollToComments) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Добавляем небольшую задержку, чтобы гарантировать,
        // что виджет комментариев отрисовался и имеет размеры
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

  // Function to launch URL
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString')),
        );
      }
      print('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Bloc теперь доступен через context благодаря BlocProvider.value в роутере
    // final newsBloc = BlocProvider.of<NewsBloc>(context); 
    final String formattedDate = widget.article.publishedAt != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(widget.article.publishedAt!)
        : 'Date unavailable';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article.sourceName ?? 'News Details'),
      ),
      // Убираем вложенный BlocProvider.value
      body: BlocListener<NewsBloc, NewsState>(
        // Listener все еще может быть полезен
        listener: (context, state) {
           // Например, показать SnackBar при ошибке добавления коммента
           if (state.status == NewsStatus.error && state.errorMessage?.contains('comment') == true) {
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
                // Title
                Text(
                  widget.article.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                // Author and Date
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
                // Image
                if (widget.article.urlToImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      widget.article.urlToImage!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      // Optional: Add loading and error builders for the image
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                            child: LoadingIndicator(
                                message: 'Loading image...'));
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                              child: Icon(Icons.broken_image,
                                  color: Colors.grey)),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16.0),
                // Content
                // NewsAPI often provides limited content, display what we have
                Text(
                  widget.article.content.isNotEmpty
                      ? widget.article.content
                      : widget.article.description,
                  // Fallback to description if content is empty
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(height: 1.5),
                ),
                // Always show button if URL exists, removing the arbitrary length check
                if (widget.article.url != null) 
                   Padding(
                     padding: const EdgeInsets.only(top: 8.0),
                     child: TextButton(
                       onPressed: () => _launchUrl(widget.article.url), 
                       child: const Text('Read full story...'),
                     ),
                   ),

                const SizedBox(height: 24.0),
                const Divider(),
                // Comments Section
                BlocBuilder<NewsBloc, NewsState>(
                  // Bloc теперь получается из контекста
                  // bloc: newsBloc, // Не нужно указывать явно
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
