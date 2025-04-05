import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart'; // For debounce
import 'package:bloc_concurrency/bloc_concurrency.dart'; // For restartable()

import '../../domain/entities/news_article.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/news_repository.dart';
import '../../../../core/error/exceptions.dart'; // Import custom exceptions

part 'news_event.dart';
part 'news_state.dart';

// Duration for search debounce
const _debounceDuration = Duration(milliseconds: 500);

// Event transformer for debounce
EventTransformer<E> debounceRestartable<E>(
  Duration duration,
) {
  return (events, mapper) {
    return restartable<E>().call(events.debounce(duration), mapper);
  };
}

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRepository _newsRepository;

  NewsBloc({required NewsRepository newsRepository}) 
      : _newsRepository = newsRepository,
        super(const NewsState()) {
    // Register event handlers
    on<GetNewsListEvent>(_onGetNewsList);
    // Apply debounce to search event
    on<SearchNewsEvent>(_onSearchNews, transformer: debounceRestartable(_debounceDuration));
    on<AddCommentEvent>(_onAddComment);
    // Consider how LoadCommentsEvent interacts. Maybe it updates a specific article in the state?
    // For now, comments are loaded within getNews/searchNews and attached to articles.
    // on<LoadCommentsEvent>(_onLoadComments);
  }

  Future<void> _onGetNewsList(GetNewsListEvent event, Emitter<NewsState> emit) async {
    try {
      // Indicate loading only if it's a forced refresh or initial load
      if (event.forceRefresh || state.status == NewsStatus.initial) {
          emit(state.copyWith(status: NewsStatus.loading));
      }
      final articles = await _newsRepository.getNews(forceRefresh: event.forceRefresh);
      emit(state.copyWith(
        status: NewsStatus.loaded,
        articles: articles,
        // Reset hasReachedMax if needed for pagination later
      ));
    } on DatabaseException catch (e) {
      emit(state.copyWith(status: NewsStatus.error, errorMessage: e.message));
    } on NetworkException catch (e) {
       // If network fails during refresh, show error but keep old data if available
       emit(state.copyWith(status: NewsStatus.error, errorMessage: e.message));
    } on ServerException catch (e) {
       // If server fails during refresh, show error but keep old data if available
       emit(state.copyWith(status: NewsStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: NewsStatus.error, errorMessage: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onSearchNews(SearchNewsEvent event, Emitter<NewsState> emit) async {
    if (event.query.isEmpty) {
      // If search query is cleared, reload the full list
      add(const GetNewsListEvent()); 
      return;
    }
    
    emit(state.copyWith(status: NewsStatus.searching)); // Indicate searching state
    try {
      final articles = await _newsRepository.searchNewsLocally(event.query);
      emit(state.copyWith(
        status: NewsStatus.loaded, // Treat search results as 'loaded' data
        articles: articles,
      ));
    } on DatabaseException catch (e) {
       emit(state.copyWith(status: NewsStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(status: NewsStatus.error, errorMessage: 'Search failed: ${e.toString()}'));
    }
  }

  Future<void> _onAddComment(AddCommentEvent event, Emitter<NewsState> emit) async {
     // We don't necessarily need a loading state for adding a comment unless it takes long
    try {
      await _newsRepository.addComment(event.articleUrl, event.userName, event.text);
      // After adding, refresh the comments for the specific article implicitly
      // by reloading the news list (which re-fetches comments)
      // This is simpler than managing comments separately in the state for now.
      // Find the article in the current state to update its comments
      final updatedArticles = List<NewsArticle>.from(state.articles);
      final articleIndex = updatedArticles.indexWhere((a) => a.id == event.articleUrl);

      if (articleIndex != -1) {
          final latestComments = await _newsRepository.getComments(event.articleUrl);
          final originalArticle = updatedArticles[articleIndex];
          updatedArticles[articleIndex] = NewsArticle( // Create a new instance with updated comments
            id: originalArticle.id,
            sourceName: originalArticle.sourceName,
            author: originalArticle.author,
            title: originalArticle.title,
            description: originalArticle.description,
            url: originalArticle.url,
            urlToImage: originalArticle.urlToImage,
            publishedAt: originalArticle.publishedAt,
            content: originalArticle.content,
            comments: latestComments, // Update comments
          );
          emit(state.copyWith(articles: updatedArticles, status: NewsStatus.loaded));
      } else {
          // If article not found in current list (e.g. after search cleared), 
          // maybe just reload all news? 
           add(const GetNewsListEvent(forceRefresh: false));
      }
      
      // Alternatively, emit a success state or message? For now, just update list.
    } on DatabaseException catch (e) {
       // How to show comment add error? Maybe a separate state field or SnackBar
       emit(state.copyWith(status: NewsStatus.error, errorMessage: 'Failed to add comment: ${e.message}'));
       // Revert to loaded state after showing error? Or keep error state?
       emit(state.copyWith(status: NewsStatus.loaded)); // Revert to loaded state
    } catch (e) {
       emit(state.copyWith(status: NewsStatus.error, errorMessage: 'Failed to add comment: ${e.toString()}'));
       emit(state.copyWith(status: NewsStatus.loaded)); // Revert to loaded state
    }
  }

  // Example of how _onLoadComments might work if managing comments separately
  // Future<void> _onLoadComments(LoadCommentsEvent event, Emitter<NewsState> emit) async {
  //   try {
  //     final comments = await _newsRepository.getComments(event.articleUrl);
  //     final currentComments = Map<String, List<Comment>>.from(state.commentsByArticle);
  //     currentComments[event.articleUrl] = comments;
  //     emit(state.copyWith(commentsByArticle: currentComments));
  //   } catch (e) {
  //      // Handle error loading comments
  //   }
  // }

} 