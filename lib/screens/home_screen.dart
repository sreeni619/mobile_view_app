// ignore_for_file: prefer_const_constructors
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/src/provider.dart';

import '../helpers/Icons.dart';
import '../main.dart';
// import '../widgets/admob_service.dart';
import '../widgets/admob_service.dart';
import '../provider/navigationBarProvider.dart';
import '../helpers/Constant.dart';
import '../widgets/load_web_view.dart';

class HomeScreen extends StatefulWidget {
  final String url;
  final bool mainPage;
  final bool isDeepLink;
  final Function? callback;
  const HomeScreen(this.url, this.mainPage, this.isDeepLink,
      {Key? key, this.callback})
      : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen>, TickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  late AnimationController navigationContainerAnimationController =
      AnimationController(
          vsync: this, duration: const Duration(milliseconds: 500));
  @override
  void initState() {
    super.initState();
    if (!showBottomNavigationBar) {
      Future.delayed(Duration.zero, () {
        context
            .read<NavigationBarProvider>()
            .setAnimationController(navigationContainerAnimationController);
      });
    }
  }

  @override
  void dispose() {
    navigationContainerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: displayAd(),
       
        body: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: LoadWebView(
            url: widget.url,
            webUrl: true,
            isDeepLink: widget.isDeepLink,
            isMainPage: widget.mainPage,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: !showBottomNavigationBar
            ? FadeTransition(
                opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                    CurvedAnimation(
                        parent: navigationContainerAnimationController,
                        curve: Curves.easeInOut)),
                child: SlideTransition(
                    position: Tween<Offset>(
                            begin: Offset.zero, end: const Offset(0.0, 1.0))
                        .animate(CurvedAnimation(
                            parent: navigationContainerAnimationController,
                            curve: Curves.easeInOut)),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: FloatingActionButton(
                        child: Lottie.asset(
                          Theme.of(context).colorScheme.settingsIcon,
                          height: 30,
                          repeat: true,
                        ),
                        onPressed: () {
                          // setState(() {
                          navigatorKey.currentState!.pushNamed('settings');
                          // });
                        },
                      ),
                    )))
            : null);
  }

  Widget displayAd() {
    if (showBannerAds) {
      return SizedBox(
        height: 50.0,
        width: double.maxFinite,
        child: AdWidget(
            key: UniqueKey(), ad: AdMobService.createBannerAd()..load()),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
