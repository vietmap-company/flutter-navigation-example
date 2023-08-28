import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vietmap_flutter_navigation/navigation_plugin.dart';
import 'package:vietmap_flutter_navigation/embedded/controller.dart';
import 'package:vietmap_flutter_navigation/models/options.dart';
import 'package:vietmap_flutter_navigation/models/route_progress_event.dart';
import 'package:vietmap_flutter_navigation/models/way_point.dart';
import 'package:vietmap_flutter_navigation/views/navigation_view.dart';
import 'package:vietmap_map/constants/colors.dart';
import 'package:vietmap_map/di/app_context.dart';
import 'package:vietmap_map/extension/driving_profile_extension.dart';
import 'package:vietmap_map/features/navigation_screen/components/vietmap_banner_instruction_view.dart';
import 'package:vietmap_map/features/navigation_screen/components/vietmap_bottom_view.dart';
import 'package:vietmap_map/features/navigation_screen/models/navigation_params.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  MapNavigationViewController? _controller;
  late MapOptions _navigationOption;
  final _vietmapPlugin = VietMapNavigationPlugin();

  List<WayPoint> wayPoints = [
    WayPoint(name: "You are here", latitude: 10.759091, longitude: 106.675817),
    WayPoint(name: "You are here", latitude: 10.762528, longitude: 106.653099)
  ];
  Widget instructionImage = const SizedBox.shrink();
  String guideDirection = "";
  Widget recenterButton = const SizedBox.shrink();
  RouteProgressEvent? routeProgressEvent;
  bool _isRunning = false;
  FocusNode focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    EasyLoading.show();
    initialize();
  }

  Future<void> initialize() async {
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    _navigationOption = _vietmapPlugin.getDefaultOptions();
    _navigationOption.simulateRoute = false;
    _navigationOption.isCustomizeUI = true;

    _navigationOption.apiKey = AppContext.getVietmapAPIKey() ?? "";
    _navigationOption.mapStyle = AppContext.getVietmapMapStyleUrl() ?? "";

    _vietmapPlugin.setDefaultOptions(_navigationOption);
  }

  MapOptions? options;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isRunning) {
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    title: const Text('Thông báo'),
                    content: const Text('Bạn có muốn dừng hướng dẫn đi đường?'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Không')),
                      TextButton(
                          onPressed: () {
                            _controller?.finishNavigation();
                            _onStopNavigation();
                            Navigator.pop(context);
                          },
                          child: const Text('Có'))
                    ],
                  ));
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              NavigationView(
                mapOptions: _navigationOption,
                onMapRendered: () {
                  final arguments = ModalRoute.of(context)!.settings.arguments
                      as NavigationScreenParams;
                  var listWaypoint = <WayPoint>[];
                  listWaypoint.add(WayPoint(
                      name: '',
                      latitude: arguments.from?.latitude,
                      longitude: arguments.from?.longitude));

                  listWaypoint.add(WayPoint(
                      name: '',
                      latitude: arguments.to?.latitude,
                      longitude: arguments.to?.longitude));
                  _controller
                      ?.buildAndStartNavigation(
                          wayPoints: listWaypoint,
                          profile:
                              arguments.profile?.convertToDrivingProfile() ??
                                  DrivingProfile.drivingTraffic)
                      .then((value) {
                    EasyLoading.dismiss();
                    setState(() {
                      _isRunning = true;
                    });
                  });
                },
                onMapReady: () {},
                onMapCreated: (p0) async {
                  _controller = p0;
                },
                onMapMove: () => _showRecenterButton(),
                onRouteBuilt: (p0) {
                  setState(() {
                    EasyLoading.dismiss();
                  });
                },
                onRouteProgressChange: (RouteProgressEvent routeProgressEvent) {
                  if (!mounted) return;
                  setState(() {
                    this.routeProgressEvent = routeProgressEvent;
                  });
                  _setInstructionImage(routeProgressEvent.currentModifier,
                      routeProgressEvent.currentModifierType);
                },
                onArrival: () {
                  setState(() {
                    _isRunning = false;
                  });
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => AlertDialog(
                            title: const Text('Thông báo'),
                            content: const Text('Bạn đã đến nơi'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('OK'))
                            ],
                          ));
                },
              ),
              Positioned(
                  top: MediaQuery.of(context).viewPadding.top,
                  left: 0,
                  child: VietmapBannerInstructionView(
                    routeProgressEvent: routeProgressEvent,
                    instructionIcon: instructionImage,
                  )),
              Positioned(
                  bottom: 0,
                  child: VietmapBottomActionView(
                    recenterButton: recenterButton,
                    controller: _controller,
                    onOverviewCallback: _showRecenterButton,
                    onStopNavigationCallback: _onStopNavigation,
                    routeProgressEvent: routeProgressEvent,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  _showRecenterButton() {
    recenterButton = TextButton(
        style: ButtonStyle(overlayColor:
            MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
          return Colors.transparent;
        })),
        onPressed: () {
          _controller?.recenter();
          recenterButton = const SizedBox.shrink();
        },
        child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.white,
                border: Border.all(color: Colors.black45, width: 1)),
            child: const Row(
              children: [
                Icon(
                  Icons.keyboard_double_arrow_up_sharp,
                  size: 35,
                  color: vietmapColor,
                ),
                Text(
                  'Về giữa',
                  style: TextStyle(fontSize: 18, color: vietmapColor),
                )
              ],
            )));
    setState(() {});
  }

  _setInstructionImage(String? modifier, String? type) {
    if (modifier != null && type != null) {
      List<String> data = [
        type.replaceAll(' ', '_'),
        modifier.replaceAll(' ', '_')
      ];
      String path = 'assets/navigation_symbol/${data.join('_')}.svg';
      setState(() {
        instructionImage = SvgPicture.asset(path, color: Colors.white);
      });
    }
  }

  _onStopNavigation() {
    Navigator.pop(context);
    setState(() {
      routeProgressEvent = null;
      _isRunning = false;
    });
  }

  @override
  void dispose() {
    _controller?.onDispose();
    super.dispose();
  }
}
