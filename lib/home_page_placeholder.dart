import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:posmotrim_app/signin_page.dart';
import 'package:posmotrim_app/movie.dart';
import 'package:posmotrim_app/user_page.dart';


class MainPagePlaceholder extends StatefulWidget {
  @override
  _MainPagePlaceholderState createState() => _MainPagePlaceholderState();
}

class _MainPagePlaceholderState extends State<MainPagePlaceholder>{

  var movieData = [];
  var horrorData = [];
  var dramaData = [];
  var userId;


  @override
  void initState() {
    fetchUserId();
    fetchMoviesByGenreData();
    fetchHorrorData();
    fetchDramaData();
    super.initState();
  }

  Future<void> fetchUserId() async {
    final response = await http.get(Uri.parse('${dotenv.env['BACKEND_HTTP']}/users/me'));
    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      setState(() {
        userId = decodedResponse['id']; // Обновляем userId с учетом поля "id" из ответа сервера
      });
    } else {
      throw Exception('Не удалось получить данные пользователя');
    }
  }



  Future<void> fetchMoviesByGenreData() async {
    var requestBody = Uri.encodeFull("комедия/10");
    final response = await http.get(Uri.parse('${dotenv.env['BACKEND_HTTP']}/films/top_films_by_genre/$requestBody'));
    if (response.statusCode == 200) {
      setState(() {
        final decodedResponse = utf8.decode(response.bodyBytes);
        movieData = json.decode(decodedResponse);
      });
    } else {
      throw Exception('Не удалось получить данные о фильме');
    }
  }

  Future<void> fetchHorrorData() async {
    var requestBody = Uri.encodeFull("ужасы/10");
    final response = await http.get(Uri.parse('${dotenv.env['BACKEND_HTTP']}/films/top_films_by_genre/$requestBody'));
    if (response.statusCode == 200) {
      setState(() {
        final decodedResponse = utf8.decode(response.bodyBytes);
        horrorData = json.decode(decodedResponse);
      });
    } else {
      throw Exception('Не удалось получить данные о фильме');
    }
  }

  Future<void> fetchDramaData() async {
    var requestBody = Uri.encodeFull("драма/10");
    final response = await http.get(Uri.parse('${dotenv.env['BACKEND_HTTP']}/films/top_films_by_genre/$requestBody'));
    if (response.statusCode == 200) {
      setState(() {
        final decodedResponse = utf8.decode(response.bodyBytes);
        dramaData = json.decode(decodedResponse);
      });
    } else {
      throw Exception('Не удалось получить данные о фильме');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 20),
          Text(
            'Топ 10 в жанре комедия:',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 300.0,
            child: ListView.separated(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              itemCount: movieData.length,
              separatorBuilder: (context, index) {
                return const SizedBox(width: 12);
              },
              itemBuilder: (context, index) {
                final movie = movieData[index];
                return movieCard(movie);
              },
            ),
          ),
          Text(
            'Топ 10 в жанре ужасы:',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 300.0,
            child: ListView.separated(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              itemCount: horrorData.length,
              separatorBuilder: (context, index) {
                return const SizedBox(width: 12);
              },
              itemBuilder: (context, index) {
                final movie = horrorData[index];
                return movieCard(movie);
              },
            ),
          ),
          Text(
            'Топ 10 в жанре драма:',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 300.0,
            child: ListView.separated(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(12),
              itemCount: dramaData.length,
              separatorBuilder: (context, index) {
                return const SizedBox(width: 12);
              },
              itemBuilder: (context, index) {
                final movie = dramaData[index];
                return movieCard(movie);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget movieCard(movie) => GestureDetector(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            'https://www.kinopoisk.ru/images/film_big/${movie['kinopoisk_id']}.jpg',
            height: 200,
            width: 200,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 200, // Задаем фиксированную ширину контейнера
          child: Align(
            alignment: Alignment.centerLeft, // Выравнивание текста по левому краю
            child: Text(
              movie['name'].toString(),
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2, // Максимальное количество строк
              overflow: TextOverflow.ellipsis, // Обрезание текста, если не помещается
            ),
          ),
        ),
      ],
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MoviePage(
            filmId: movie['kinopoisk_id'],
            userId: userId,
          ),
        ),
      );
    },
  );
}

