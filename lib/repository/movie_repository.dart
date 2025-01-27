import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/movie_model.dart';

const String TMDB_API_KEY = "a2554ec0dc3430d7da9b0b21be0857a2";
const String TMDB_POPULAR_MOVIES_URL =
    "https://api.themoviedb.org/3/movie/popular?api_key=$TMDB_API_KEY";

class MovieRepository {
  Future<List<Movie>> getTrendingMovies() async {
    final response = await http.get(Uri.parse(TMDB_POPULAR_MOVIES_URL));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return (jsonData['results'] as List)
          .map((movieJson) => Movie.fromJson(movieJson))
          .toList();
    } else {
      throw Exception('Failed to load trending movies');
    }
  }

  Future<List<Movie>> getRecommendedMovies() async {
    final response = await http.get(Uri.parse(TMDB_POPULAR_MOVIES_URL));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      var moviesList = (jsonData['results'] as List)
          .map((movieJson) => Movie.fromJson(movieJson))
          .toList();
      moviesList.shuffle(); 
      return moviesList;
    } else {
      throw Exception('Failed to load recommended movies');
    }
  }
}
