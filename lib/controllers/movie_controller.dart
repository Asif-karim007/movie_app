import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/movie_model.dart';

const String TMDB_API_KEY = "a2554ec0dc3430d7da9b0b21be0857a2";
const String TMDB_POPULAR_MOVIES_URL =
    "https://api.themoviedb.org/3/movie/popular?api_key=$TMDB_API_KEY";

class MovieController extends GetxController {
  var isLoading = true.obs;
  var movies = <Movie>[].obs;
  var trendingMovies = <Movie>[].obs;
  var continueWatchingMovies = <Movie>[].obs;
  var recommendedMovies = <Movie>[].obs;

  @override
  void onInit() {
    fetchMovies();
    super.onInit();
  }

  Future<void> fetchMovies() async {
    isLoading(true);
    try {
      final response = await http.get(Uri.parse(TMDB_POPULAR_MOVIES_URL));

      if (response.statusCode == 200) {
        print("API Response: ${response.body}");
        final jsonData = json.decode(response.body);

        List<Movie> fetchedMovies = (jsonData['results'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();

        movies.assignAll(fetchedMovies);
        trendingMovies.assignAll(List<Movie>.from(fetchedMovies)..shuffle());
        continueWatchingMovies.assignAll(List<Movie>.from(fetchedMovies)..shuffle());
        recommendedMovies.assignAll(List<Movie>.from(fetchedMovies)..shuffle());

        // Cache the fetched movies
        final box = Hive.box<Movie>('movies');
        await box.clear();
        await box.addAll(fetchedMovies);
      } else {
        loadMoviesFromCache();
      }
    } catch (e) {
      print("Error fetching movies: $e");
      loadMoviesFromCache();
    } finally {
      isLoading(false);
    }
  }

  void loadMoviesFromCache() {
    final box = Hive.box<Movie>('movies');
    final cachedMovies = box.values.toList();
    if (cachedMovies.isNotEmpty) {
      movies.assignAll(cachedMovies);
      trendingMovies.assignAll(List<Movie>.from(cachedMovies)..shuffle());
      continueWatchingMovies.assignAll(List<Movie>.from(cachedMovies)..shuffle());
      recommendedMovies.assignAll(List<Movie>.from(cachedMovies)..shuffle());
    }
  }
}
