import 'dart:convert' as convert;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_tv/api/api_rest.dart';
import 'package:flutter_app_tv/constants.dart';
import 'package:flutter_app_tv/model/actor.dart';
import 'package:flutter_app_tv/model/poster.dart';
import 'package:flutter_app_tv/ui/channel/channels.dart';
import 'package:flutter_app_tv/ui/movie/movie.dart';
import 'package:flutter_app_tv/ui/movie/movies_widget.dart';
import 'package:flutter_app_tv/ui/movie/related_loading_widget.dart';
import 'package:flutter_app_tv/ui/serie/serie.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:transparent_image/transparent_image.dart';

class ActorDetail extends StatefulWidget {
  Actor actor;

  ActorDetail({required this.actor});

  @override
  _ActorDetailState createState() => _ActorDetailState();
}

class _ActorDetailState extends State<ActorDetail> {
  int postx = 0;
  int posty = 1;
  FocusNode actor_focus_node = FocusNode();
  ItemScrollController _scrollController = ItemScrollController();
  ItemScrollController _moviesScrollController = ItemScrollController();
  bool _visibile_related_loading = true;
  List<Poster> movies = [];
  bool isMobile = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).requestFocus(actor_focus_node);

      _getMoviesList();
    });
    getMobileVal();
  }

  Future getMobileVal() async {
    isMobile = await context.isMobile;
    setState(() {});
  }

  void _getMoviesList() async {
    movies.clear();
    setState(() {
      _visibile_related_loading = true;
    });
    var response = await apiRest.getMoviesByActor(widget.actor.id);
    if (response != null) {
      if (response.statusCode == 200) {
        var jsonData = convert.jsonDecode(response.body);
        for (Map<String, dynamic> i in jsonData) {
          Poster _poster = Poster.fromJson(i);
          movies.add(_poster);
        }
      }
    }
    setState(() {
      _visibile_related_loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (bool pop) {
        // return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: KeyboardListener(
          focusNode: actor_focus_node,
          onKeyEvent: (KeyEvent event) {
            if (event is KeyDownEvent) {
              final logicalKey = event.logicalKey;
              switch (logicalKey) {
                case LogicalKeyboardKey
                      .select: // Replace KEY_CENTER with a more general key
                  _goToMovieDetail();
                  break;
                case LogicalKeyboardKey.arrowUp:
                  if (posty == 0) {
                    print(
                        "play sound"); // Consider playing a sound cue for user feedback
                  } else {
                    posty--;
                    _scrollToIndexY(posty);
                  }
                  break;
                case LogicalKeyboardKey.arrowDown:
                  if (posty == 1) {
                    print("play sound");
                  } else {
                    posty++;
                    _scrollToIndexY(posty);
                  }
                  break;
                case LogicalKeyboardKey.arrowLeft:
                  if (postx == 0) {
                    print("play sound");
                  } else {
                    postx--;
                    _scrollToIndexMovie(postx);
                  }
                  break;
                case LogicalKeyboardKey.arrowRight:
                  if (postx == movies.length - 1) {
                    print("play sound");
                  } else {
                    postx++;
                    _scrollToIndexMovie(postx);
                  }
                  break;
                default:
                  break;
              }
              print("x: " + postx.toString() + " y: " + posty.toString());
              setState(() {});
            }
          },
          child: Container(
            child: Stack(
              children: [
                FadeInImage(
                    placeholder: MemoryImage(kTransparentImage),
                    image: CachedNetworkImageProvider(widget.actor.image
                        .replaceAll("uploads/cache/actor_thumb/", "")),
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width),

                // ClipRRect( // Clip it cleanly.
                //   child: BackdropFilter(
                //     filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                //     child: Container(
                //       color: Colors.black.withOpacity(0.5),
                //       alignment: Alignment.center,
                //     ),
                //   ),
                // ),
                Container(
                    child: ScrollConfiguration(
                  behavior: MyBehavior(),
                  child: ScrollablePositionedList.builder(
                      itemCount: 3,
                      itemScrollController: _scrollController,
                      itemBuilder: (context, index) {
                        switch (index) {
                          case 0:
                            return Container(
                              padding: EdgeInsets.only(
                                  left: isMobile ? 5 : 50,
                                  right: isMobile ? 5 : 50,
                                  bottom: 20,
                                  top: 100),
                              child: isMobile
                                  ? Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            // if (Platform.isIOS)
                                            //   SizedBox(
                                            //     width: 20.0,
                                            //   ),
                                            // if (Platform.isIOS)
                                            //   InkWell(
                                            //     onTap: () {
                                            //       Navigator.pop(context);
                                            //     },
                                            //     child: Icon(
                                            //       Icons.arrow_back_ios,
                                            //       color: Colors.white,
                                            //       size: 25.0,
                                            //     ),
                                            //   ),
                                            // if (Platform.isIOS)
                                            //   SizedBox(
                                            //     width: 80.0,
                                            //   ),
                                            Container(
                                              height: 150,
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  child: CachedNetworkImage(
                                                    imageUrl: widget.actor.image
                                                        .replaceAll(
                                                            "uploads/cache/actor_thumb/",
                                                            ""),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                    fit: BoxFit.cover,
                                                  )),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(left: 20),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.actor.name.toUpperCase(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 22,
                                                    fontWeight:
                                                        FontWeight.w900),
                                              ),
                                              SizedBox(height: 15),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "${widget.actor.type}",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    " •  ${widget.actor.born} ",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    " •  ${widget.actor.height} ",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                widget.actor.bio +
                                                    widget.actor.bio,
                                                style: TextStyle(
                                                    color: Colors.white60,
                                                    fontSize: 11,
                                                    height: 1.5,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                              SizedBox(height: 10),
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    child: CachedNetworkImage(
                                                      imageUrl: widget
                                                          .actor.image
                                                          .replaceAll(
                                                              "uploads/cache/actor_thumb/",
                                                              ""),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons.error),
                                                      fit: BoxFit.cover,
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Container(
                                            padding: EdgeInsets.only(left: 20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget.actor.name
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.w900),
                                                ),
                                                SizedBox(height: 15),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "${widget.actor.type}",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w800),
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      " •  ${widget.actor.born} ",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w800),
                                                    ),
                                                    SizedBox(width: 5),
                                                    Text(
                                                      " •  ${widget.actor.height} ",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w800),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  widget.actor.bio +
                                                      widget.actor.bio,
                                                  style: TextStyle(
                                                      color: Colors.white60,
                                                      fontSize: 11,
                                                      height: 1.5,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                                SizedBox(height: 10),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                            );
                            break;

                          case 1:
                            return Container(
                              padding: EdgeInsets.only(top: 5, bottom: 20),
                              child: Column(
                                children: [
                                  if (!_visibile_related_loading)
                                    MoviesWidget(
                                        title: "Filmography",
                                        size: 13,
                                        scrollController:
                                            _moviesScrollController,
                                        postx: postx,
                                        jndex: 1,
                                        posty: posty,
                                        posters: movies)
                                  else
                                    RelatedLoadingWidget(),
                                ],
                              ),
                            );
                            break;
                          default:
                            return Container();
                            break;
                        }
                      }),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _scrollToIndexY(int y) async {
    _scrollController.scrollTo(
        index: y,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOutQuart);
  }

  Future _scrollToIndexMovie(int y) async {
    _moviesScrollController.scrollTo(
        index: y,
        alignment: 0.04,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOutQuart);
  }

  void _goToMovieDetail() {
    if (posty == 2) {
      if (movies.length > 0) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                (movies[postx].type == "serie")
                    ? Serie(serie: movies[postx])
                    : Movie(movie: movies[postx]),
            transitionDuration: Duration(seconds: 0),
          ),
        );
        FocusScope.of(context).requestFocus(null);
      }
    }
  }
}
