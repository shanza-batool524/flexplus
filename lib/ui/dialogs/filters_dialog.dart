import 'package:flutter/material.dart';
import 'package:flutter_app_tv/constants.dart';
import 'package:flutter_app_tv/ui/home/home.dart';
import 'package:flutter_app_tv/model/genre.dart';
import 'package:flutter_app_tv/ui/movie/filter_widget.dart';
import 'package:flutter_app_tv/ui/movie/genre_widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class FiltersDialog extends StatelessWidget {
  List<String> genresList = [];
  bool visibile;
  int focused_genre;
  int selected_genre;
  ItemScrollController genresScrollController = ItemScrollController();
  Function close;
  Function select;

  FiltersDialog(
      {required this.genresList,
      required this.visibile,
      required this.focused_genre,
      required this.selected_genre,
      required this.genresScrollController,
      required this.close,
      required this.select});

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      left: 0,
      right: 0,
      bottom: 0,
      top: 0,
      duration: Duration(milliseconds: 250),
      child: Visibility(
        visible: visibile,
        child: Container(
          color: Colors.black87,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    close();
                  },
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              Expanded(
                flex: context.isPortrait ? 3 : 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black,
                          offset: Offset(0, 0),
                          blurRadius: 5),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black45,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 80.0, left: 10, bottom: 10),
                          child: Row(
                            children: [
                              Icon(Icons.tag, color: Colors.white70, size: 35),
                              SizedBox(width: 10),
                              Text(
                                "Select Filter",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                          child: Container(
                        color: Colors.black.withOpacity(0.7),
                        child: ScrollConfiguration(
                          behavior:
                              MyBehavior(), // From this behaviour you can change the behaviour
                          child: ScrollablePositionedList.builder(
                            itemCount: genresList.length,
                            itemScrollController: genresScrollController,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                  onTap: () {
                                    select(index);
                                  },
                                  child: FilterWidget(
                                      isFocused: (focused_genre == index),
                                      selected_genre: selected_genre,
                                      index: index,
                                      title: genresList[index]));
                            },
                          ),
                        ),
                      ))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}