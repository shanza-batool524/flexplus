import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_tv/api/api_rest.dart';
import 'package:flutter_app_tv/constants.dart';
import 'package:flutter_app_tv/model/genre.dart';
import 'package:flutter_app_tv/model/poster.dart';
import 'package:flutter_app_tv/ui/auth/auth.dart';
import 'package:flutter_app_tv/ui/auth/profile.dart';
import 'package:flutter_app_tv/ui/channel/channels.dart';
import 'package:flutter_app_tv/ui/dialogs/filters_dialog.dart';
import 'package:flutter_app_tv/ui/dialogs/genres_dialog.dart';
import 'package:flutter_app_tv/ui/home/home.dart';
import 'package:flutter_app_tv/key_code.dart';
import 'package:flutter_app_tv/ui/home/mylist.dart';
import 'package:flutter_app_tv/ui/movie/movie.dart';
import 'package:flutter_app_tv/ui/movie/movie_loading_widget.dart';
import 'package:flutter_app_tv/ui/movie/movie_widget.dart';
import 'package:flutter_app_tv/ui/search/search.dart';
import 'package:flutter_app_tv/ui/serie/series.dart';
import 'package:flutter_app_tv/ui/setting/settings.dart';

import 'package:flutter_app_tv/ui/movie/movie_short_detail_mini.dart';

import 'package:flutter_app_tv/widget/navigation_widget.dart';
import 'package:flutter_app_tv/widget/navigation_widget_mobile.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:need_resume/need_resume.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'dart:convert' as convert;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';

/// A [StatelessWidget] which demonstrates
/// how to consume and interact with a [CounterBloc].
class Movies extends StatefulWidget {
  @override
  _MoviesState createState() => _MoviesState();
}

class _MoviesState extends ResumableState<Movies> {
  int postx = 2;
  int posty = -2;

  List<String> order = [
    "created",
    "views",
    "rating",
    "imdb",
    "title",
    "year",
  ];

  List<Genre> genres = [];
  List<String> filters = [
    'Newest',
    'Views',
    'Rating',
    'Imdb Rating',
    'Title',
    'Year',
  ];
  List<Poster> movies = [];

  int page = 0;

  int selected_sort = 1;

  int _focused_poster = 0;
  int _focused_genre = 0;
  int _focused_filter = 0;
  int _selected_genre = 0;
  int _selected_filter = 0;
  ItemScrollController _scrollController = ItemScrollController();
  ItemScrollController _genresScrollController = ItemScrollController();
  ItemScrollController _filtersScrollController = ItemScrollController();

  List<ItemScrollController> _scrollControllers = [];
  List<int> _position_x_line_saver = [];
  List<int> _counts_x_line_saver = [];
  FocusNode home_focus_node = FocusNode();

  bool _visibile_genres_dialog = false;
  bool _visibile_filters_dialog = false;
  bool _visibile_loading = false;
  bool _visibile_error = false;
  bool _visibile_success = false;
  bool? logged;
  Image image = Image.asset("assets/images/profile.jpg");
  bool isMobile = true;
  @override
  void initState() {
    context.isMobile.then((value) => isMobile = value);
    super.initState();
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(home_focus_node);
      _getGenres();
      _getList();
      getLogged();
    });
  }

  @override
  void onResume() {
    super.onResume();
    getLogged();
  }

  getLogged() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    logged = await prefs.getBool("LOGGED_USER");

    if (logged == true) {
      String? img = await prefs.getString("IMAGE_USER");
      image = Image.network(img!);
    } else {
      logged = false;
      image = Image.asset("assets/images/profile.jpg");
    }
    setState(() {
      print(logged);
    });
  }

  void _getGenres() async {
    genres.clear();
    Genre genre = Genre(id: 0, title: "All genres");
    genres.add(genre);
    var response = await apiRest.getGenres();
    if (response != null) {
      if (response.statusCode == 200) {
        var jsonData = convert.jsonDecode(response.body);
        for (Map<String, dynamic> i in jsonData) {
          Genre genre = Genre.fromJson(i);
          genres.add(genre);
        }
      }
    }
  }

  void _getList() async {
    movies.clear();
    page = 0;
    _showLoading();
    var response = await apiRest.getMoviesByFiltres(
        genres[_selected_genre].id, order[selected_sort - 1], page);
    if (response == null) {
      _showTryAgain();
    } else {
      if (response.statusCode == 200) {
        var jsonData = convert.jsonDecode(response.body);
        for (Map<String, dynamic> i in jsonData) {
          Poster poster = Poster.fromJson(i);
          movies.add(poster);
        }
        _showData();
        page++;
      } else {
        _showTryAgain();
      }
    }
    _scrollControllers.clear();
    for (int jndex = 0; jndex < ((movies.length / 8).ceil()); jndex++) {
      int items_line_count = (movies.length - ((jndex + 1) * 8) > 0)
          ? 8
          : (movies.length - (jndex * 8)).abs();

      ItemScrollController controller = new ItemScrollController();
      _scrollControllers.add(controller);
      _position_x_line_saver.add(0);
      _counts_x_line_saver.add(items_line_count);
    }
  }

  void _loadMore() async {
    var response = await apiRest.getMoviesByFiltres(
        genres[_selected_genre].id, order[selected_sort - 1], page);
    if (response != null) {
      if (response.statusCode == 200) {
        var jsonData = convert.jsonDecode(response.body);
        for (Map<String, dynamic> i in jsonData) {
          Poster poster = Poster.fromJson(i);
          movies.add(poster);
        }
        page++;
      }
    }
    _scrollControllers.clear();
    for (int jndex = 0; jndex < ((movies.length / 8).ceil()); jndex++) {
      int items_line_count = (movies.length - ((jndex + 1) * 8) > 0)
          ? 8
          : (movies.length - (jndex * 8)).abs();

      ItemScrollController controller = new ItemScrollController();
      _scrollControllers.add(controller);
      _position_x_line_saver.add(0);
      _counts_x_line_saver.add(items_line_count);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_visibile_genres_dialog) {
          setState(() {
            _visibile_genres_dialog = false;
          });

          return false;
        }
        return true;
      },
      child: SafeArea(
        top: isMobile,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: KeyboardListener(
            focusNode: home_focus_node,
            onKeyEvent: (KeyEvent event) {
              if (event is KeyDownEvent) {
                final logicalKey = event.logicalKey;

                switch (logicalKey) {
                  case (LogicalKeyboardKey.select || LogicalKeyboardKey.enter):
                    _selectFilter();

                    _goToSearch();
                    _goToHome();
                    _goToSeries();
                    _goToChannels();
                    _goToMyList();
                    _goToSettings();
                    _goToProfile();

                    _goToMovieDetail();
                    _tryAgain();
                    if (_visibile_genres_dialog == true) {
                      _selectedGenre();
                    } else {
                      _showGenresDialog();
                    }
                    break;
                  case LogicalKeyboardKey.arrowUp:
                    if (_visibile_loading) {
                      print("playing sound ");
                      break;
                    }
                    if (_visibile_error) {
                      if (posty == -2) {
                        print("playing sound ");
                      } else if (posty == -1) {
                        posty--;
                        postx = 0;
                      }
                      break;
                    }
                    if (_visibile_genres_dialog) {
                      (_focused_genre == 0)
                          ? print("play sound")
                          : _focused_genre--;
                      break;
                    }
                    if (posty == -2) {
                      print("playing sound ");
                    } else if (posty == -1) {
                      posty--;
                      postx = 2;
                    } else if (posty == 0) {
                      posty--;
                      postx = 0;
                    } else {
                      posty--;
                      _scrollToIndexXY(postx, posty);
                      _focused_poster = ((posty * 8) + postx);
                    }
                    break;
                  case LogicalKeyboardKey.arrowDown:
                    if (_visibile_error) {
                      if (posty < -1)
                        posty++;
                      else
                        print("playing sound ");
                      break;
                    }
                    if (_visibile_loading) {
                      print("playing sound ");
                      break;
                    }
                    if (_visibile_genres_dialog) {
                      (_focused_genre == genres.length - 1)
                          ? print("play sound")
                          : _focused_genre++;
                      break;
                    }
                    if ((movies.length / 8).ceil() - 1 == posty) {
                      print("playing sound ");
                    } else {
                      posty++;
                      if (posty >= 0) {
                        if (postx > (_counts_x_line_saver[posty] - 1)) {
                          postx = _counts_x_line_saver[posty] - 1;
                        }
                        _scrollToIndexXY(postx, posty);
                        _focused_poster = ((posty * 8) + postx);
                      } else {
                        postx = 0;
                      }
                      if (posty == (movies.length / 8).ceil() - 3) {
                        _loadMore();
                      }
                    }
                    break;
                  case LogicalKeyboardKey.arrowLeft:
                    if (_visibile_genres_dialog) {
                      print("playing sound ");
                      break;
                    }

                    if (posty == -2) {
                      if (postx == 0) {
                        print("playing sound ");
                      } else {
                        postx--;
                      }
                    } else if (posty == -1) {
                      if (_visibile_loading || _visibile_error) {
                        print("playing sound ");
                        break;
                      }
                      (postx == 0) ? print("playing sound ") : postx--;
                    } else {
                      if (_visibile_loading || _visibile_error) {
                        print("playing sound ");
                        break;
                      }
                      if (postx == 0) {
                        print("playing sound ");
                      } else {
                        postx--;
                        _scrollToIndexXY(postx, posty);
                      }
                      _focused_poster = ((posty * 8) + postx);
                    }
                    break;
                  case LogicalKeyboardKey.arrowRight:
                    if (_visibile_genres_dialog) {
                      print("playing sound ");
                      break;
                    }
                    switch (posty) {
                      case -1:
                        if (_visibile_loading || _visibile_error) {
                          print("playing sound ");
                          break;
                        }
                        (postx == 6) ? print("playing sound ") : postx++;
                        break;
                      case -2:
                        if (postx == 7)
                          print("playing sound ");
                        else
                          postx++;
                        break;
                      default:
                        if (_visibile_loading || _visibile_error) {
                          print("playing sound ");
                          break;
                        }
                        if (_counts_x_line_saver[posty] - 1 == postx) {
                          print("playing sound ");
                        } else {
                          postx++;
                          _scrollToIndexXY(postx, posty);
                        }
                        _focused_poster = ((posty * 8) + postx);

                        break;
                    }

                    break;
                  default:
                    break;
                }

                setState(() {});
                if (_visibile_genres_dialog &&
                    _genresScrollController != null) {
                  _genresScrollController.scrollTo(
                      index: _focused_genre,
                      alignment: 0.43,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOutQuart);
                }
              }
            },
            child: Stack(
              children: [
                if (!movies.isEmpty)
                  Positioned(
                      right: 0,
                      top: 0,
                      left: MediaQuery.of(context).size.width / 4,
                      bottom: MediaQuery.of(context).size.height / 4,
                      child: CachedNetworkImage(
                        imageUrl: movies[_focused_poster].cover,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fadeInDuration: Duration(seconds: 1),
                      )),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  top: 0,
                  child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black,
                      Colors.black,
                      Colors.black54,
                      Colors.black54,
                      Colors.black54
                    ],
                  ))),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                      height: MediaQuery.of(context).size.height -
                          (MediaQuery.of(context).size.height / 3),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black,
                          Colors.black,
                          Colors.transparent,
                          Colors.transparent
                        ],
                      ))),
                ),
                // context.isPortrait
                //     ? NavigationWidgetMobile(
                //         postx: postx,
                //         posty: posty,
                //         selectedItem: 2,
                //         image: image,
                //         logged: logged)
                //     :
                if (!isMobile)
                  NavigationWidget(
                      postx: postx,
                      posty: posty,
                      selectedItem: 2,
                      image: image,
                      logged: logged),
                if (_visibile_loading) MovieLoadingWidget(),
                if (_visibile_error) _tryAgainWidget(),
                if (movies.length > 0 && !_visibile_loading && !_visibile_error)
                  AnimatedPositioned(
                      // top: (posty < 0)
                      //     ? isMobile && context.isLandscape
                      //         ? -5
                      //         : context.isPortrait
                      //             ? 10
                      //             : 100
                      //     : isMobile && context.isLandscape
                      //         ? -5
                      //         : 40,
                      top: 100,
                      left: 0,
                      right: 0,
                      duration: Duration(milliseconds: 200),
                      child: MovieShortDetailMiniWidget(
                          movie: movies[_focused_poster])),
                Positioned(
                  top: 10,
                  left: 45,
                  right: 45,
                  child: AnimatedOpacity(
                    opacity: (posty < 0) ? 0 : 1,
                    duration: Duration(milliseconds: 200),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          posty = -1;
                        });
                      },
                      child: Container(
                        child: Icon(
                          Icons.keyboard_arrow_up,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_visibile_success)
                  AnimatedPositioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    top: MediaQuery.of(context).size.height / 2.6,
                    duration: Duration(milliseconds: 200),
                    // height: isMobile && context.isLandscape
                    //     ? (MediaQuery.of(context).size.height / 3.6) + 25
                    //     : isMobile && context.isPortrait
                    //         ? (MediaQuery.of(context).size.height / 1.9) + 25
                    //         : (posty < 0)
                    //             ? (MediaQuery.of(context).size.height / 2) + 20
                    //             : (MediaQuery.of(context).size.height / 2) + 50,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: context.isPortrait ? 15 : 45),
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                margin: EdgeInsets.symmetric(vertical: 7),
                                height: 50,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      posty = -1;
                                      postx = 0;
                                      Future.delayed(Duration(milliseconds: 50),
                                          () {
                                        _showGenresDialog();
                                      });
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        genres[_selected_genre].title,
                                        style: TextStyle(
                                            color: (posty == -1 && postx == 0)
                                                ? Colors.black
                                                : Colors.white70,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        color: (posty == -1 && postx == 0)
                                            ? Colors.black
                                            : Colors.white70,
                                        size: 30,
                                      ),
                                    ],
                                  ),
                                ),
                                decoration: BoxDecoration(
                                    color: (posty == -1 && postx == 0)
                                        ? Colors.white
                                        : Colors.transparent,
                                    border: Border.all(
                                        color: Colors.white70, width: 2),
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              if (isMobile)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  margin: EdgeInsets.symmetric(vertical: 7),
                                  height: 50,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        posty = -2;
                                        postx = 0;
                                        Future.delayed(
                                            Duration(milliseconds: 50), () {
                                          _showFiltersDialog();
                                        });
                                      });
                                    },
                                    child: Icon(
                                      Icons.menu,
                                      color: (posty == -2 && postx == 0)
                                          ? Colors.black
                                          : Colors.white70,
                                      size: 30,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                      color: (posty == -2 && postx == 0)
                                          ? Colors.white
                                          : Colors.transparent,
                                      border: Border.all(
                                          color: Colors.white70, width: 2),
                                      borderRadius: BorderRadius.circular(5)),
                                ),
                              if (!isMobile)
                                SizedBox(
                                  width: 20,
                                ),
                              if (!isMobile)
                                AnimatedOpacity(
                                  opacity: (posty == -1 && postx > 0) ? 1 : 0.8,
                                  duration: Duration(milliseconds: 250),
                                  child: Container(
                                    height: 50,
                                    margin: EdgeInsets.symmetric(vertical: 7),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              posty = -1;
                                              postx = 1;
                                              Future.delayed(
                                                  Duration(milliseconds: 50),
                                                  () {
                                                _selectFilter();
                                              });
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12),
                                            height: 50,
                                            color:
                                                ((posty == -1 && postx == 1) ||
                                                        selected_sort == 1)
                                                    ? Colors.white
                                                    : Colors.transparent,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  color: ((posty == -1 &&
                                                              postx == 1) ||
                                                          selected_sort == 1)
                                                      ? Colors.black
                                                      : Colors.white,
                                                  size: 18,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  "Newest",
                                                  style: TextStyle(
                                                      color: ((posty == -1 &&
                                                                  postx == 1) ||
                                                              selected_sort ==
                                                                  1)
                                                          ? Colors.black
                                                          : Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              posty = -1;
                                              postx = 2;
                                              Future.delayed(
                                                  Duration(milliseconds: 50),
                                                  () {
                                                _selectFilter();
                                              });
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12),
                                            height: 50,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.remove_red_eye,
                                                  color: ((posty == -1 &&
                                                              postx == 2) ||
                                                          selected_sort == 2)
                                                      ? Colors.black
                                                      : Colors.white,
                                                  size: 18,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  "Views",
                                                  style: TextStyle(
                                                      color: ((posty == -1 &&
                                                                  postx == 2) ||
                                                              selected_sort ==
                                                                  2)
                                                          ? Colors.black
                                                          : Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                              ],
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                  left: BorderSide(
                                                      color: Colors.white,
                                                      width: 1)),
                                              color: ((posty == -1 &&
                                                          postx == 2) ||
                                                      selected_sort == 2)
                                                  ? Colors.white
                                                  : Colors.transparent,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              posty = -1;
                                              postx = 3;
                                              Future.delayed(
                                                  Duration(milliseconds: 50),
                                                  () {
                                                _selectFilter();
                                              });
                                            });
                                          },
                                          child: Container(
                                            height: 50,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.star_half,
                                                  color: ((posty == -1 &&
                                                              postx == 3) ||
                                                          selected_sort == 3)
                                                      ? Colors.black
                                                      : Colors.white,
                                                  size: 18,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  "Rating",
                                                  style: TextStyle(
                                                      color: ((posty == -1 &&
                                                                  postx == 3) ||
                                                              selected_sort ==
                                                                  3)
                                                          ? Colors.black
                                                          : Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                              ],
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                  left: BorderSide(
                                                      color: Colors.white,
                                                      width: 1)),
                                              color: ((posty == -1 &&
                                                          postx == 3) ||
                                                      selected_sort == 3)
                                                  ? Colors.white
                                                  : Colors.transparent,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              posty = -1;
                                              postx = 4;
                                              Future.delayed(
                                                  Duration(milliseconds: 50),
                                                  () {
                                                _selectFilter();
                                              });
                                            });
                                          },
                                          child: Container(
                                            height: 50,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons.imdb,
                                                  color: ((posty == -1 &&
                                                              postx == 4) ||
                                                          selected_sort == 4)
                                                      ? Colors.black
                                                      : Colors.white,
                                                  size: 18,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  "Imdb Rating",
                                                  style: TextStyle(
                                                      color: ((posty == -1 &&
                                                                  postx == 4) ||
                                                              selected_sort ==
                                                                  4)
                                                          ? Colors.black
                                                          : Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                              ],
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                  left: BorderSide(
                                                      color: Colors.white,
                                                      width: 1)),
                                              color: ((posty == -1 &&
                                                          postx == 4) ||
                                                      selected_sort == 4)
                                                  ? Colors.white
                                                  : Colors.transparent,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              posty = -1;
                                              postx = 5;
                                              Future.delayed(
                                                  Duration(milliseconds: 50),
                                                  () {
                                                _selectFilter();
                                              });
                                            });
                                          },
                                          child: Container(
                                            height: 50,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.text_fields,
                                                  color: ((posty == -1 &&
                                                              postx == 5) ||
                                                          selected_sort == 5)
                                                      ? Colors.black
                                                      : Colors.white,
                                                  size: 18,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  "Title",
                                                  style: TextStyle(
                                                      color: ((posty == -1 &&
                                                                  postx == 5) ||
                                                              selected_sort ==
                                                                  5)
                                                          ? Colors.black
                                                          : Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                              ],
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                  left: BorderSide(
                                                      color: Colors.white,
                                                      width: 1)),
                                              color: ((posty == -1 &&
                                                          postx == 5) ||
                                                      selected_sort == 5)
                                                  ? Colors.white
                                                  : Colors.transparent,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              posty = -1;
                                              postx = 6;
                                              Future.delayed(
                                                  Duration(milliseconds: 50),
                                                  () {
                                                _selectFilter();
                                              });
                                            });
                                          },
                                          child: Container(
                                            height: 50,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.date_range,
                                                  color: ((posty == -1 &&
                                                              postx == 6) ||
                                                          selected_sort == 6)
                                                      ? Colors.black
                                                      : Colors.white,
                                                  size: 18,
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  "Year",
                                                  style: TextStyle(
                                                      color: ((posty == -1 &&
                                                                  postx == 6) ||
                                                              selected_sort ==
                                                                  6)
                                                          ? Colors.black
                                                          : Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                              ],
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                  left: BorderSide(
                                                      color: Colors.white,
                                                      width: 1)),
                                              color: ((posty == -1 &&
                                                          postx == 6) ||
                                                      selected_sort == 6)
                                                  ? Colors.white
                                                  : Colors.transparent,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                        if (context.isPortrait) SizedBox(height: 10),
                        Expanded(
                          child: Container(
                            // height: MediaQuery.of(context).size.height * 0.5,
                            // width: MediaQuery.of(context).size.width,
                            child: ScrollConfiguration(
                              behavior: MyBehavior(),
                              child: ScrollablePositionedList.builder(
                                itemCount: (movies.length / 8).ceil(),
                                scrollDirection: Axis.vertical,
                                itemScrollController: _scrollController,
                                itemBuilder: (context, jndex) {
                                  int items_line_count =
                                      (movies.length - ((jndex + 1) * 8) > 0)
                                          ? 8
                                          : (movies.length - (jndex * 8)).abs();
                                  return _moviesLineGridWidget(
                                      jndex, items_line_count);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                GenresDialog(
                    genresScrollController: _genresScrollController,
                    visibile: _visibile_genres_dialog,
                    genresList: genres,
                    focused_genre: _focused_genre,
                    selected_genre: _selected_genre,
                    select: selectGenre,
                    close: closeGenreDialog),
                FiltersDialog(
                    genresScrollController: _filtersScrollController,
                    visibile: _visibile_filters_dialog,
                    genresList: filters,
                    focused_genre: _focused_filter,
                    selected_genre: selected_sort - 1,
                    select: selectFilter,
                    close: closeFilterDialog),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _scrollToIndexXY(int x, int y) async {
    try {
      _scrollControllers[y].scrollTo(
          index: x,
          duration: Duration(milliseconds: 500),
          alignment: 0.04,
          curve: Curves.fastOutSlowIn);
    } catch (ex) {}
    _scrollController.scrollTo(
        index: y,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOutQuart);
  }

  void _selectFilter() {
    if (posty == -1 && postx > 0 && postx < 7) {
      setState(() {
        selected_sort = postx;
      });
      _getList();
    }
  }

  void _goToHome() {
    if (posty == -2 && postx == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => Home(),
          transitionDuration: Duration(seconds: 0),
        ),
      );
      FocusScope.of(context).requestFocus(null);
    }
  }

  void _goToSeries() {
    if (posty == -2 && postx == 3) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => Series(),
          transitionDuration: Duration(seconds: 0),
        ),
      );
    }
  }

  void _goToChannels() {
    if (posty == -2 && postx == 4) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => Channels(),
          transitionDuration: Duration(seconds: 0),
        ),
      );
    }
  }

  void _goToSettings() {
    if (posty == -2 && postx == 6) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => Settings(),
          transitionDuration: Duration(seconds: 0),
        ),
      );
      FocusScope.of(context).requestFocus(null);
    }
  }

  void _goToSearch() {
    if (posty == -2 && postx == 0) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => Search(),
          transitionDuration: Duration(seconds: 0),
        ),
      );
      FocusScope.of(context).requestFocus(null);
    }
  }

  void _goToMyList() {
    if (posty == -2 && postx == 5) {
      if (logged == true) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => MyList(),
            transitionDuration: Duration(seconds: 0),
          ),
        );
        FocusScope.of(context).requestFocus(null);
      } else {
        push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => Auth(),
            transitionDuration: Duration(seconds: 0),
          ),
        );
      }
    }
  }

  void _goToProfile() {
    if (posty == -2 && postx == 7) {
      if (logged == true) {
        push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => Profile(),
            transitionDuration: Duration(seconds: 0),
          ),
        );
      } else {
        push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => Auth(),
            transitionDuration: Duration(seconds: 0),
          ),
        );
      }
    }
  }

  void _goToMovieDetail() {
    if (posty >= 0) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) =>
              Movie(movie: movies[_focused_poster]),
          transitionDuration: Duration(seconds: 0),
        ),
      );
      FocusScope.of(context).requestFocus(null);
    }
  }

  void _showGenresDialog() {
    if (posty == -1 && postx == 0) {
      setState(() {
        _visibile_genres_dialog = true;
      });
      Future.delayed(Duration(milliseconds: 100), () {
        _genresScrollController.scrollTo(
            index: _selected_genre,
            alignment: 0.43,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOutQuart);
      });
    }
  }

  void _showFiltersDialog() {
    if (posty == -2 && postx == 0) {
      setState(() {
        _visibile_filters_dialog = true;
      });
      Future.delayed(Duration(milliseconds: 100), () {
        _filtersScrollController.scrollTo(
            index: _selected_filter,
            alignment: 0.43,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOutQuart);
      });
    }
  }

  void _selectedGenre() {
    _selected_genre = _focused_genre;
    setState(() {
      _visibile_genres_dialog = false;
    });
    _getList();
  }

  void _selectedFilter() {
    selected_sort = _focused_filter + 1;
    setState(() {
      _visibile_filters_dialog = false;
    });
    _getList();
  }

  Widget _moviesLineGridWidget(jndex, int itemCount) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: context.isPortrait ? 10 : 40),
            height: MediaQuery.of(context).size.height / 3.1,
            width: double.infinity,
            child: ScrollablePositionedList.builder(
              itemCount: itemCount,
              itemScrollController: _scrollControllers[jndex],
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      setState(() {
                        posty = jndex;
                        postx = index;
                        Future.delayed(Duration(milliseconds: 250), () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  Movie(movie: movies[(jndex * 8) + index]),
                              transitionDuration: Duration(seconds: 0),
                            ),
                          );
                        });
                      });
                    },
                    child: MoviesMovieWidget(
                        isFocus: ((posty == jndex && postx == index)),
                        movie: movies[(jndex * 8) + index]));
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _tryAgainWidget() {
    return Positioned(
      bottom: 0,
      left: 45,
      right: 45,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error,
                  color: Colors.white,
                ),
                SizedBox(width: 5),
                Text(
                  "Something wrong !",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              "Please check your internet connexion and try again  !",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                setState(() {
                  posty = -1;
                  Future.delayed(Duration(milliseconds: 100), () {
                    _tryAgain();
                    posty = -2;
                  });
                });
              },
              child: Container(
                  margin: EdgeInsets.only(top: 10),
                  height: 40,
                  width: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white54, width: 1),
                    color: (_visibile_error && posty == -1)
                        ? Colors.white
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: (_visibile_error && posty == -1)
                                ? Colors.black
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.refresh,
                            color: (_visibile_error && posty == -1)
                                ? Colors.white
                                : Colors.black,
                          )),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Try Again",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: (_visibile_error && posty == -1)
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoading() {
    setState(() {
      _visibile_loading = true;
      _visibile_error = false;
      _visibile_success = false;
    });
  }

  void _showTryAgain() {
    setState(() {
      _visibile_loading = false;
      _visibile_error = true;
      _visibile_success = false;
    });
  }

  void _showData() {
    setState(() {
      _visibile_loading = false;
      _visibile_error = false;
      _visibile_success = true;
    });
  }

  void _tryAgain() {
    if (_visibile_error && posty == -1) {
      _getList();
    }
  }

  void closeGenreDialog() {
    setState(() {
      _visibile_genres_dialog = false;
    });
  }

  void closeFilterDialog() {
    setState(() {
      _visibile_filters_dialog = false;
    });
  }

  void selectGenre(int selected_genre_pick) {
    setState(() {
      _focused_genre = selected_genre_pick;
      Future.delayed(Duration(milliseconds: 200), () {
        _selectedGenre();
      });
    });
  }

  void selectFilter(int selected_genre_pick) {
    setState(() {
      _focused_filter = selected_genre_pick;
      Future.delayed(Duration(milliseconds: 200), () {
        _selectedFilter();
      });
    });
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
