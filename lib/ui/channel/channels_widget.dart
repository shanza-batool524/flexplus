import 'package:flutter/material.dart';
import 'package:flutter_app_tv/constants.dart';
import 'package:flutter_app_tv/ui/channel/channel_detail.dart';
import 'package:flutter_app_tv/ui/home/home.dart';
import 'package:flutter_app_tv/model/channel.dart';
import 'package:flutter_app_tv/ui/channel/channel_widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ChannelsWidget extends StatefulWidget {
  List<Channel> channels = [];

  String title;
  double size;

  int posty;
  int postx;
  int jndex;
  ItemScrollController scrollController;

  ChannelsWidget(
      {required this.posty,
      required this.postx,
      required this.jndex,
      required this.scrollController,
      required this.size,
      required this.title,
      required this.channels});

  @override
  _ChannelsWidgetState createState() => _ChannelsWidgetState();
}

class _ChannelsWidgetState extends State<ChannelsWidget> {
  bool isMobile = true;
  @override
  void initState() {
    super.initState();
    context.isMobile.then((value) => isMobile = value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(
                left: context.isPortrait
                    ? 15
                    : isMobile && context.isLandscape
                        ? 30
                        : 50,
                bottom: 5),
            height: 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:[
                Text(
                widget.title,
                style: TextStyle(
                    color: (widget.jndex == widget.posty)
                        ? Colors.white
                        :Color(0xff2676a9),
                    fontSize: widget.size,
                    fontWeight: FontWeight.w900),
              ),
            Padding(
                padding: EdgeInsets.only(right: 15),
                child: Icon(Icons.grid_on,color: Color(0xff2676a9),)),

              ],),
          ),
          Container(
            height: 75,
            child: ScrollConfiguration(
              behavior:
                  MyBehavior(), // From this behaviour you can change the behaviour
              child: ScrollablePositionedList.builder(
                itemCount: widget.channels.length,
                itemScrollController: widget.scrollController,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                        left: (0 == index)
                            ? context.isPortrait
                                ? 10
                                : isMobile && context.isLandscape
                                    ? 25
                                    : 40
                            : 0),
                    child: GestureDetector(
                        onTap: () {
                          setState(() {
                            widget.posty = widget.jndex;
                            widget.postx = index;
                            Future.delayed(Duration(milliseconds: 250), () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                          ChannelDetail(
                                              channel: widget.channels[index]),
                                  transitionDuration: Duration(seconds: 0),
                                ),
                              );
                            });
                          });
                        },
                        child: ChannelWidget(
                            isFocus: ((widget.posty == widget.jndex &&
                                widget.postx == index)),
                            channel: widget.channels[index])),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
    ;
  }
}
