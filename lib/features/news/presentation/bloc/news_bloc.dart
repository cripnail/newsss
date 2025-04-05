import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart'; //
import 'package:newsss/features/news/domain/entities/news_article.dart';
import 'package:newsss/features/news/domain/repositories/news_repository.dart';
import 'package:newsss/core/error/exceptions.dart';

part 'news_event.dart';

part 'news_state.dart';

const _debounceDuration = Duration(milliseconds: 500);

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
    on<GetNewsListEvent>(_onGetNewsList);
    on<SearchNewsEvent>(_onSearchNews,
        transformer: debounceRestartable(_debounceDuration));
    on<AddCommentEvent>(_onAddComment);
  }

  Future<void> _onGetNewsList(
      GetNewsListEvent event, Emitter<NewsState> emit) async {
    try {
      if (event.forceRefresh || state.status == NewsStatus.initial) {
        emit(state.copyWith(status: NewsStatus.loading));
      }
      final articles =
          await _newsRepository.getNews(forceRefresh: event.forceRefresh);
      emit(state.copyWith(
        status: NewsStatus.loaded,
        articles: articles,
      ));
    } on DatabaseException catch (e) {
      emit(state.copyWith(status: NewsStatus.error, errorMessage: e.message));
    } on NetworkException catch (e) {
      emit(state.copyWith(status: NewsStatus.error, errorMessage: e.message));
    } on ServerException catch (e) {
      emit(state.copyWith(status: NewsStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(
          status: NewsStatus.error,
          errorMessage: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onSearchNews(
      SearchNewsEvent event, Emitter<NewsState> emit) async {
    if (event.query.isEmpty) {
      add(const GetNewsListEvent());
      return;
    }

    emit(state.copyWith(status: NewsStatus.searching));
    try {
      final articles = await _newsRepository.searchNewsLocally(event.query);
      emit(state.copyWith(
        status: NewsStatus.loaded,
        articles: articles,
      ));
    } on DatabaseException catch (e) {
      emit(state.copyWith(status: NewsStatus.error, errorMessage: e.message));
    } catch (e) {
      emit(state.copyWith(
          status: NewsStatus.error,
          errorMessage: 'Search failed: ${e.toString()}'));
    }
  }

  Future<void> _onAddComment(
      AddCommentEvent event, Emitter<NewsState> emit) async {
    try {
      await _newsRepository.addComment(
          event.articleUrl, event.userName, event.text);
      final updatedArticles = List<NewsArticle>.from(state.articles);
      final articleIndex =
          updatedArticles.indexWhere((a) => a.id == event.articleUrl);

      if (articleIndex != -1) {
        final latestComments =
            await _newsRepository.getComments(event.articleUrl);
        final originalArticle = updatedArticles[articleIndex];
        updatedArticles[articleIndex] = NewsArticle(
          id: originalArticle.id,
          sourceName: originalArticle.sourceName,
          author: originalArticle.author,
          title: originalArticle.title,
          description: originalArticle.description,
          url: originalArticle.url,
          urlToImage: originalArticle.urlToImage,
          publishedAt: originalArticle.publishedAt,
          content: originalArticle.content,
          comments: latestComments,
        );
        emit(state.copyWith(
            articles: updatedArticles, status: NewsStatus.loaded));
      } else {
        add(const GetNewsListEvent(forceRefresh: false));
      }
    } on DatabaseException catch (e) {
      emit(state.copyWith(
          status: NewsStatus.error,
          errorMessage: 'Failed to add comment: ${e.message}'));
      emit(state.copyWith(status: NewsStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
          status: NewsStatus.error,
          errorMessage: 'Failed to add comment: ${e.toString()}'));
      emit(state.copyWith(status: NewsStatus.loaded));
    }
  }
}
