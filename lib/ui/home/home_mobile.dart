import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_tv/ui/auth/auth.dart';
import 'package:flutter_app_tv/ui/auth/profile.dart';
import 'package:flutter_app_tv/ui/channel/channels.dart';
import 'package:flutter_app_tv/ui/home/home.dart';
import 'package:flutter_app_tv/ui/home/mylist.dart';
import 'package:flutter_app_tv/ui/movie/movies.dart';
import 'package:flutter_app_tv/ui/search/search.dart';
import 'package:flutter_app_tv/ui/serie/series.dart';
import 'package:flutter_app_tv/ui/setting/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';

class HomeMobile extends StatefulWidget {
  const HomeMobile({super.key});

  @override
  State<HomeMobile> createState() => _HomeMobileState();
}

class _HomeMobileState extends State<HomeMobile> {
  int _selectedIndex = 0;
  bool logged = false;

  @override
  void initState() {
    getLogged();
    super.initState();
  }

  getLogged() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    logged = await prefs.getBool("LOGGED_USER") ?? false;

    setState(() {});
  }

  static List<Widget> _widgetOptions = <Widget>[
    Home(),
    Movies(),
    Series(),
    Channels(),
    MyList(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7),
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        // iconTheme: IconThemeData(
        //   color: Colors.white,
        // ),
        // elevation: 0,
        // centerTitle: true,
        // title: Container(
        //   width: 100,
        //   child: Padding(
        //     padding: const EdgeInsets.all(0.0),
        //     child: Image.asset("assets/tvappflix_mobile.png"),
        //   ),
        // ),
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {
                // widget.postx = 0;
                // widget.posty = -2;
                Future.delayed(Duration(milliseconds: 200), () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          Search(),
                      transitionDuration: Duration(seconds: 0),
                    ),
                  );
                });
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                // color: (widget.selectedItem == 0)
                //     ? (widget.posty == -2 && widget.postx == 0)
                //         ? Colors.white
                //         : Colors.white70
                //     : (widget.posty == -2 && widget.postx == 0)
                //         ? Colors.white24
                //         : Colors.transparent,
                color: Colors.transparent,
              ),
              // child: Row(
              //   children: [
              //     Icon(
              //       Icons.search,
              //       size: 20,
              //       // color: (widget.selectedItem == 0)
              //       //     ? Colors.black
              //       //     : (widget.posty == -2 &&
              //       //             widget.postx == 0)
              //       //         ? Colors.white
              //       //         : Colors.white60,
              //       color: Colors.white,
              //     ),
              //     SizedBox(width: 5),
              //     Text(
              //       "Search",
              //       style: TextStyle(
              //           // color: (widget.selectedItem == 0)
              //           //     ? Colors.black
              //           //     : (widget.posty == -2 && widget.postx == 0)
              //           //         ? Colors.white
              //           //         : Colors.white60,
              //           color: Colors.white,
              //           fontSize: 15,
              //           fontWeight: FontWeight.w500),
              //     ),
              //   ],
              // ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            FadeInImage(
                placeholder: MemoryImage(kTransparentImage),
                image: AssetImage("assets/images/background.jpeg"),
                fit: BoxFit.cover),
            CustomDrawerTile(
                title: 'Profile',
                onTap: () {
                  if (logged) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            Profile(),
                        transitionDuration: Duration(seconds: 0),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            Auth(),
                        transitionDuration: Duration(seconds: 0),
                      ),
                    );
                  }
                },
                icon: Icons.person),
            CustomDrawerTile(
                title: 'Settings',
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          Settings(),
                      transitionDuration: Duration(seconds: 0),
                    ),
                  );
                },
                icon: Icons.settings),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => (Search())));
                  },
                  child: Container(
                    width: 400,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.only(left: 20.0),
                    height: 50,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Let\'s find your favorite content',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  child: Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedIndex == 4
                ? (logged ? MyList() : Auth())
                : _widgetOptions.elementAt(_selectedIndex),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 105,
        child: FloatingNavbar(
          backgroundColor: Colors.black,
          items: <FloatingNavbarItem>[
            FloatingNavbarItem(
              icon: Icons.home_outlined,
              title: 'Home',
            ),
            FloatingNavbarItem(
              icon: Icons.movie_creation_outlined,
              title: 'Movies',
            ),
            FloatingNavbarItem(
              icon: Icons.ondemand_video_rounded,
              title: 'Shows',
            ),
            FloatingNavbarItem(
              icon: Icons.live_tv,
              title: 'Live TV',
            ),
            FloatingNavbarItem(
              icon: Icons.list,
              title: 'My List',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedBackgroundColor: Color(0xff402700),
          selectedItemColor: Color(0xffd59e44),
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: Colors.black,
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home_outlined),
      //       label: 'Home',
      //       backgroundColor: Colors.black,
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.movie_creation_outlined),
      //       label: 'Movies',
      //       backgroundColor: Colors.black,
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.ondemand_video_rounded),
      //       label: 'Shows',
      //       backgroundColor: Colors.black,
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.live_tv),
      //       label: 'Live TV',
      //       backgroundColor: Colors.black,
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.list),
      //       label: 'My List',
      //       backgroundColor: Colors.black,
      //     ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   type: BottomNavigationBarType.shifting,
      //   selectedItemColor: Colors.amber[800],
      //   showSelectedLabels: true,
      //   showUnselectedLabels: true,
      //   unselectedLabelStyle: TextStyle(color: Colors.white),
      //   // useLegacyColorScheme: false,
      //   onTap: _onItemTapped,
      // ),
    );
  }
}

class CustomDrawerTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final IconData icon;

  const CustomDrawerTile(
      {super.key,
      required this.title,
      required this.onTap,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      onTap: onTap,
    );
  }
}
