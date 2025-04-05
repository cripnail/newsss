import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/comment.dart';
import '../bloc/news_bloc.dart'; // To dispatch AddCommentEvent
import 'comment_widget.dart';

class CommentListWidget extends StatefulWidget {
  final String articleUrl; // Needed to add new comments
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
      // TODO: Get actual username from user state/profile
      const userName = 'CurrentUser'; 
      
      context.read<NewsBloc>().add(AddCommentEvent(
            articleUrl: widget.articleUrl,
            userName: userName,
            text: text,
          ));
      
      _commentController.clear();
      FocusScope.of(context).unfocus(); // Hide keyboard
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
        // Input field
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
        // List of comments
        if (widget.comments.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text('No comments yet. Be the first!')),
          )
        else
          ListView.builder(
            shrinkWrap: true, // Important inside Column/ScrollView
            physics: const NeverScrollableScrollPhysics(), // List scrolls with the page
            itemCount: widget.comments.length,
            itemBuilder: (context, index) {
              return CommentWidget(comment: widget.comments[index]);
            },
          ),
      ],
    );
  }
} 