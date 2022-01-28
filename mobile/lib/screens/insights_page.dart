import 'package:app/constants/config.dart';
import 'package:app/models/place_details.dart';
import 'package:app/services/local_storage.dart';
import 'package:app/services/rest_api.dart';
import 'package:app/widgets/custom_widgets.dart';
import 'package:app/widgets/insights_tab.dart';
import 'package:flutter/material.dart';

class InsightsPage extends StatefulWidget {
  final PlaceDetails placeDetails;

  const InsightsPage(this.placeDetails, {Key? key}) : super(key: key);

  @override
  _InsightsPageState createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  TabController? _tabController;
  bool _isWeekly = true;
  AirqoApiClient? _airqoApiClient;
  final DBHelper _dbHelper = DBHelper();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Config.appBodyColor,
        leading: Padding(
          padding: const EdgeInsets.only(top: 6.5, bottom: 6.5, left: 16),
          child: backButton(context),
        ),
        title: const Text(
          'More Insights',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(right: 0, left: 0),
        color: Config.appBodyColor,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 10, bottom: 10, right: 16, left: 16),
              child: Material(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(7.0)),
                child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    labelColor: Colors.transparent,
                    unselectedLabelColor: Colors.transparent,
                    labelPadding: const EdgeInsets.all(3.0),
                    onTap: (value) {
                      if (value == 0) {
                        setState(() {
                          _isWeekly = true;
                        });
                      } else {
                        setState(() {
                          _isWeekly = false;
                        });
                      }
                    },
                    tabs: <Widget>[
                      Container(
                        constraints: const BoxConstraints(
                            minWidth: double.infinity, maxHeight: 32),
                        decoration: BoxDecoration(
                            color:
                                _isWeekly ? Config.appColorBlue : Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5.0))),
                        child: Tab(
                            child: Text(
                          'Day',
                          style: TextStyle(
                            color: _isWeekly ? Colors.white : Colors.black,
                          ),
                        )),
                      ),
                      Container(
                        constraints: const BoxConstraints(
                            minWidth: double.infinity, maxHeight: 32),
                        decoration: BoxDecoration(
                            color:
                                _isWeekly ? Colors.white : Config.appColorBlue,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5.0))),
                        child: Tab(
                            child: Text(
                          'Week',
                          style: TextStyle(
                            color: _isWeekly ? Colors.black : Colors.white,
                          ),
                        )),
                      )
                    ]),
              ),
            ),
            Expanded(
                child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                InsightsTab(widget.placeDetails, false),
                InsightsTab(widget.placeDetails, true),
                // MonthlyView(site),
              ],
            )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _airqoApiClient = AirqoApiClient(context);
    _fetchAllHourlyInsights();
    _fetchDailyInsights();
    super.initState();
  }

  void _fetchAllHourlyInsights() async {
    var hourlyInsights = await _airqoApiClient!
        .fetchSiteInsights(widget.placeDetails.siteId, false, true);

    if (hourlyInsights.isNotEmpty) {
      await _dbHelper.insertInsights(
          hourlyInsights, widget.placeDetails.siteId, 'hourly');
    }
  }

  void _fetchDailyInsights() async {
    var dailyInsights = await _airqoApiClient!
        .fetchSiteInsights(widget.placeDetails.siteId, true, false);

    if (dailyInsights.isNotEmpty) {
      await _dbHelper.insertInsights(
          dailyInsights, widget.placeDetails.siteId, 'daily');
    }
  }
}
