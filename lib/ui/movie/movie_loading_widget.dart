import 'package:flutter/material.dart';
import 'package:flutter_app_tv/constants.dart';

class MovieLoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 45,
      right: 45,
      top: context.isPortrait ? 150 : null,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 70,
        child: Container(
          child: Wrap(
            children: [
              Stack(
                children: [
                  Container(
                    height: 190,
                    margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width / 5),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 300,
                          height: 30,
                          color: Colors.white70,
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              width: 45,
                              height: 18,
                              color: Colors.white70,
                            ),
                            SizedBox(width: 5),
                            Container(
                              width: 110,
                              height: 18,
                              color: Colors.white70,
                            ),
                            SizedBox(width: 10),
                            Container(
                              width: 55,
                              height: 18,
                              color: Colors.white70,
                            ),
                            SizedBox(width: 5),
                            Container(
                              width: 40,
                              height: 18,
                              color: Colors.white70,
                            ),
                          ],
                        ),
                        SizedBox(height: 7),
                        Row(
                          children: [
                            Container(
                              width: 70,
                              height: 18,
                              color: Colors.white70,
                            ),
                            SizedBox(width: 5),
                            Container(
                              width: 70,
                              height: 18,
                              color: Colors.white70,
                            ),
                            SizedBox(width: 10),
                            Container(
                              width: 70,
                              height: 18,
                              color: Colors.white70,
                            ),
                            SizedBox(width: 5),
                            Container(
                              width: 70,
                              height: 18,
                              color: Colors.white70,
                            ),
                            SizedBox(width: 5),
                            Container(
                              width: 70,
                              height: 18,
                              color: Colors.white70,
                            ),
                            SizedBox(width: 5),
                            Container(
                              width: 70,
                              height: 18,
                              color: Colors.white70,
                            ),
                            SizedBox(width: 5),
                            Container(
                              width: 70,
                              height: 18,
                              color: Colors.white70,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Container(
                          width: 600,
                          height: 10,
                          color: Colors.white70,
                        ),
                        SizedBox(height: 5),
                        Container(
                          width: 600,
                          height: 10,
                          color: Colors.white70,
                        ),
                        SizedBox(height: 5),
                        Container(
                          width: 600,
                          height: 10,
                          color: Colors.white70,
                        ),
                        SizedBox(height: 5),
                        Container(
                          width: 400,
                          height: 10,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 5,
                    top: 135,
                    child: Container(
                      child: Row(
                        children: [
                          Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        width: 1, color: Colors.black12))),
                          ),
                        ],
                      ),
                      height: 35,
                      width: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0),
                        color: Colors.white70,
                      ),
                    ),
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.only(bottom: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      color: Colors.white70,
                      width: 100,
                      height: 30,
                    ),
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 2),
                          color: Colors.white70,
                          width: 100,
                          height: 30,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 2),
                          color: Colors.white70,
                          width: 100,
                          height: 30,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 2),
                          color: Colors.white70,
                          width: 100,
                          height: 30,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 2),
                          color: Colors.white70,
                          width: 100,
                          height: 30,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 2),
                          color: Colors.white70,
                          width: 100,
                          height: 30,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.white70,
                        height: 140,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        color: Colors.white70,
                        height: 140,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        color: Colors.white70,
                        height: 140,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        color: Colors.white70,
                        height: 140,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        color: Colors.white70,
                        height: 140,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        color: Colors.white70,
                        height: 140,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        color: Colors.white70,
                        height: 140,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        color: Colors.white70,
                        height: 140,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.white70,
                      height: 140,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 10),
                      color: Colors.white70,
                      height: 140,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 10),
                      color: Colors.white70,
                      height: 140,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 10),
                      color: Colors.white70,
                      height: 140,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 10),
                      color: Colors.white70,
                      height: 140,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 10),
                      color: Colors.white70,
                      height: 140,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 10),
                      color: Colors.white70,
                      height: 140,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 10),
                      color: Colors.white70,
                      height: 140,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
