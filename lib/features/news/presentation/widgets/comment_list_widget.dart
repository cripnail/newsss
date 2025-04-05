import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsss/features/news/domain/entities/comment.dart';
import 'package:newsss/features/news/presentation/bloc/news_bloc.dart';
import 'package:newsss/features/news/presentation/widgets/comment_widget.dart';

class CommentListWidget extends StatefulWidget {
  final String articleUrl;
  final List<Comment> comments;

  const CommentListWidget({
    super.key,
    required this.articleUrl,
    required this.comments,
  });

  @override
  State<CommentListWidget> createState() => _CommentListWidgetState();
}

class _CommentListWidgetState extends State<CommentListWidget> {
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() {
    if (_formKey.currentState!.validate()) {
      final text = _commentController.text;
      const userName = 'CurrentUser'; // Placeholder
      
      context.read<NewsBloc>().add(AddCommentEvent(
            articleUrl: widget.articleUrl,
            userName: userName,
            text: text,
          ));
      
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Comments (${widget.comments.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Form(
            key: _formKey,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Comment cannot be empty';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.send,
                    onFieldSubmitted: (_) => _addComment(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                  tooltip: 'Post Comment',
                ),
              ],
            ),
          ),
        ),
        if (widget.comments.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text('No comments yet. Be the first!')),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.comments.length,
            itemBuilder: (context, index) {
              return CommentWidget(comment: widget.comments[index]);
            },
          ),
      ],
    );
  }
} 