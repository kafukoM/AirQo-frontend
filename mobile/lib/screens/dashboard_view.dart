import 'dart:math';

import 'package:app/constants/app_constants.dart';
import 'package:app/models/measurement.dart';
import 'package:app/models/place_details.dart';
import 'package:app/screens/search_page.dart';
import 'package:app/services/fb_notifications.dart';
import 'package:app/services/local_storage.dart';
import 'package:app/services/rest_api.dart';
import 'package:app/utils/date.dart';
import 'package:app/utils/pm.dart';
import 'package:app/widgets/analytics_card.dart';
import 'package:app/widgets/custom_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'air_pollution_ways_page.dart';
import 'favourite_places.dart';
import 'for_you_page.dart';

class DashboardView extends StatefulWidget {
  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  List<PlaceDetails> dashBoardPlaces = [];
  var greetings = '';
  double tipsProgress = 0.0;
  bool isRefreshing = false;
  List<Widget> dashboardCards = [];

  final CustomAuth _customAuth = CustomAuth();

  Widget actionsSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    var response = await Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const AirPollutionWaysPage();
                    }));
                    if (response == null) {
                      await initialize();
                    } else {
                      await initialize();
                    }
                  },
                  child: const Text(
                      'Actions You Can Take to Reduce '
                      'Air Pollution',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                const SizedBox(
                  height: 28,
                ),
                GestureDetector(
                  onTap: () async {
                    var response = await Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const AirPollutionWaysPage();
                    }));
                    if (response == null) {
                      await initialize();
                    } else {
                      await initialize();
                    }
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Start reading',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: ColorConstants.appColorBlue,
                          )),
                      const SizedBox(
                        width: 6,
                      ),
                      Icon(
                        Icons.arrow_forward_ios_sharp,
                        size: 10,
                        color: ColorConstants.appColorBlue,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          GestureDetector(
            onTap: () async {
              var response = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                return const AirPollutionWaysPage();
              }));
              if (response == null) {
                await initialize();
              } else {
                await initialize();
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                'assets/images/know-your-air.png',
                width: 104,
                height: 104,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget appNavBar() {
    return Container(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/icon/airqo_home.svg',
            height: 40,
            width: 58,
            semanticsLabel: 'Search',
          ),
          const Spacer(),
          Container(
            height: 40,
            width: 40,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            child: GestureDetector(
              onTap: () async {
                var response = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                  return const SearchPage();
                }));
                if (response == null) {
                  await initialize();
                } else {
                  await initialize();
                }
              },
              child: SvgPicture.asset(
                'assets/icon/search.svg',
                semanticsLabel: 'Search',
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: appNavBar(),
        elevation: 0,
        toolbarHeight: 65,
        backgroundColor: ColorConstants.appBodyColor,
      ),
      body: Container(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 24),
          color: ColorConstants.appBodyColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                greetings,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 16,
              ),
              topTabs(),
              const SizedBox(
                height: 25,
              ),
              Expanded(
                  child: RefreshIndicator(
                onRefresh: initialize,
                color: ColorConstants.appColorBlue,
                child: _dashboardItems(),
              )),
            ],
          )),
    );
  }

  Widget favPlaceAvatar(double rightPadding, Measurement favouritePlace) {
    return Positioned(
        right: rightPadding,
        child: Container(
          height: 32.0,
          width: 32.0,
          padding: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            color: pm2_5ToColor(favouritePlace.getPm2_5Value()),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${favouritePlace.getPm2_5Value()}',
              style: TextStyle(
                  fontSize: 7,
                  color: pm2_5TextColor(favouritePlace.getPm2_5Value())),
            ),
          ),
        ));
  }

  Future<void> getDashboardLocations() async {
    var measurements = await DBHelper().getLatestMeasurements();

    for (var i = 0; i < 4; i++) {
      var random = 0 + Random().nextInt(measurements.length - 0);
      setState(() {
        dashBoardPlaces
            .add(PlaceDetails.measurementToPLace(measurements[random]));
      });
    }
    loadDashboardCards();
  }

  Future<void> initialize() async {
    setGreetings();
    _getLatestMeasurements();
    _getLocationMeasurements();
    loadDashboardCards();
    getDashboardLocations();
    var preferences = await SharedPreferences.getInstance();
    setState(() {
      tipsProgress = preferences.getDouble(PrefConstant.tipsProgress) ?? 0.0;
    });
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void loadDashboardCards() {
    setState(() {
      dashboardCards
        ..clear()
        ..add(
          Text(
            getDateTime(),
            style: TextStyle(
              color: Colors.black.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        )
        ..add(const Text(
          'Today’s air quality',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ))
        ..add(
          const SizedBox(
            height: 12,
          ),
        )
        ..add(locationCard(0))
        ..add(const SizedBox(
          height: 16,
        ))
        ..add(tipsSection())
        ..add(const SizedBox(
          height: 16,
        ))
        ..add(locationCard(1))
        ..add(const SizedBox(
          height: 16,
        ))
        ..add(locationCard(2))
        ..add(const SizedBox(
          height: 16,
        ))
        ..add(locationCard(3))
        ..add(const SizedBox(
          height: 12,
        ));
    });
  }

  Widget locationCard(position) {
    if (dashBoardPlaces.isNotEmpty) {
      try {
        return AnalyticsCard(dashBoardPlaces[position], isRefreshing);
      } catch (e) {
        return Visibility(
            visible: dashBoardPlaces.isEmpty,
            child: loadingAnimation(255.0, 16.0));
      }
    }
    return Visibility(
        visible: dashBoardPlaces.isEmpty, child: loadingAnimation(255.0, 16.0));
  }

  void setGreetings() {
    setState(() {
      greetings = getGreetings(_customAuth.getDisplayName());
    });
  }

  List<Widget> showFavourites(List<PlaceDetails> favouritePlaces) {
    var widgets = <Widget>[];

    // try {
    //   if (favouritePlaces.length == 1) {
    //     widgets.add(favPlaceAvatar(0, favouritePlaces[0]));
    //   } else if (favouritePlaces.length == 2) {
    //     widgets
    //       ..add(favPlaceAvatar(0, favouritePlaces[0]))
    //       ..add(favPlaceAvatar(7, favouritePlaces[1]));
    //   } else if (favouritePlaces.length >= 3) {
    //     widgets
    //       ..add(favPlaceAvatar(0, favouritePlaces[0]))
    //       ..add(favPlaceAvatar(7, favouritePlaces[1]))
    //       ..add(favPlaceAvatar(14, favouritePlaces[2]));
    //   } else {}
    // } catch (e) {
    //   debugPrint(e.toString());
    // }

    return widgets;
  }

  Widget tipsSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    var response = await Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      if (tipsProgress >= 1.0) {
                        return ForYouPage();
                      }
                      return const AirPollutionWaysPage();
                    }));
                    if (response == null) {
                      await initialize();
                    } else {
                      await initialize();
                    }
                  },
                  child: const Text('The Tid Tips On Air Quality!',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                const SizedBox(
                  height: 28,
                ),
                GestureDetector(
                  onTap: () async {
                    var response = await Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      if (tipsProgress >= 1.0) {
                        return ForYouPage();
                      }
                      return const AirPollutionWaysPage();
                    }));
                    if (response == null) {
                      await initialize();
                    } else {
                      await initialize();
                    }
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (tipsProgress == 0.0)
                        Text('Start learning',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: ColorConstants.appColorBlue,
                            )),
                      if (tipsProgress > 0.0 && tipsProgress < 1.0)
                        Text('Continue',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: ColorConstants.appColorBlue,
                            )),
                      if (tipsProgress >= 1.0)
                        const Text('Complete! Move to ',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                            )),
                      if (tipsProgress >= 1.0)
                        Text('For You',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: ColorConstants.appColorBlue,
                            )),
                      const SizedBox(
                        width: 6,
                      ),
                      Icon(
                        Icons.arrow_forward_ios_sharp,
                        size: 10,
                        color: ColorConstants.appColorBlue,
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Container(
                    height: 4,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    child: LinearProgressIndicator(
                      color: ColorConstants.appColorBlue,
                      value: tipsProgress,
                      backgroundColor:
                          ColorConstants.appColorDisabled.withOpacity(0.2),
                    )),
              ],
            ),
          ),
          const SizedBox(
            width: 16,
          ),
          GestureDetector(
            onTap: () async {
              var response = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                if (tipsProgress >= 1.0) {
                  return ForYouPage();
                }
                return const AirPollutionWaysPage();
              }));
              if (response == null) {
                await initialize();
              } else {
                await initialize();
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                'assets/images/know-your-air.png',
                width: 104,
                height: 104,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget topTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
            child: GestureDetector(
          onTap: () async {
            var response = await Navigator.push(context,
                MaterialPageRoute(builder: (context) {
              return const FavouritePlaces();
            }));
            if (response == null) {
              await initialize();
            } else {
              await initialize();
            }
          },
          child: Container(
            height: 56,
            padding: const EdgeInsets.all(12.0),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Consumer<PlaceDetailsModel>(
                  builder: (context, placeDetailsModel, child) {
                    if (placeDetailsModel.favouritePlaces.isEmpty) {
                      return SvgPicture.asset(
                        'assets/icon/add_avator.svg',
                      );
                    }
                    return SizedBox(
                      height: 32,
                      width: 44,
                      child: Stack(
                        children:
                            showFavourites(placeDetailsModel.favouritePlaces),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  'Favorite',
                  style: TextStyle(
                      color: ColorConstants.appColorBlue,
                      fontWeight: FontWeight.w500,
                      fontSize: 14),
                )
              ],
            ),
          ),
        )),
        const SizedBox(
          width: 16,
        ),
        Expanded(
            child: GestureDetector(
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ForYouPage();
            }));
          },
          child: Container(
            height: 56,
            padding: const EdgeInsets.all(12.0),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icon/add_avator.svg',
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  'For You',
                  style: TextStyle(
                      color: ColorConstants.appColorBlue,
                      fontWeight: FontWeight.w500,
                      fontSize: 14),
                )
              ],
            ),
          ),
        )),
      ],
    );
  }

  void updateCurrentLocation() async {
    // try {
    //   var prefs = await SharedPreferences.getInstance();
    //   var dashboardSite = prefs.getString(PrefConstant.dashboardSite) ?? '';
    //
    //   if (dashboardSite == '') {
    //     await LocationService().getCurrentLocationReadings().then((value) => {
    //           if (value != null)
    //             {
    //               prefs.setStringList(PrefConstant.lastKnownLocation,
    //                   [(value.site.getUserLocation()), (value.site.id)]),
    //               if (mounted)
    //                 {
    //                   setState(() {
    //                     measurementData = value;
    //                     isRefreshing = false;
    //                     print(measurementData);
    //                   }),
    //                 }
    //             },
    //         });
    //   }
    // } catch (e) {
    //   debugPrint(e.toString());
    // }
  }

  Widget _dashboardItems() {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          controller: ScrollController(),
          shrinkWrap: true,
          children: dashboardCards,
        ));
  }

  void _getLatestMeasurements() async {
    await AirqoApiClient(context).fetchLatestMeasurements().then((value) => {
          if (value.isNotEmpty) {DBHelper().insertLatestMeasurements(value)}
        });
  }

  void _getLocationMeasurements() async {
    // try {
    //   await Settings().dashboardMeasurement().then((value) => {
    //         if (value != null)
    //           {
    //             if (mounted)
    //               {
    //                 setState(() {
    //                   measurementData = value;
    //                   isRefreshing = false;
    //                 }),
    //                 updateCurrentLocation()
    //               },
    //           }
    //         else
    //           {
    //
    //           }
    //       });
    // } catch (e) {
    //   debugPrint('error getting data : $e');
    // }
  }
}
