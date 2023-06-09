import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:map_ai/features/auth/cubit/auth_cubit.dart';
import 'package:map_ai/features/map/bloc/map_cubit.dart';

class MapViewController extends StatefulWidget {
  const MapViewController({super.key});

  static const String routeName = '/map';

  @override
  State<MapViewController> createState() => _MapViewControllerState();
}

GlobalKey mapKey = GlobalKey();

class _MapViewControllerState extends State<MapViewController> {
  late MapController mapController;

  @override
  void initState() {
    super.initState();

    mapController = MapController();

    mapController.mapEventStream.listen((event) {
      context.read<MapCubit>().setZoom(event.zoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          title: const Text('MapAI'),
          actions: [
            IconButton(
                onPressed: () {
                  context.read<AuthCubit>().signOut();
                },
                icon: const Icon(Icons.logout_rounded))
          ],
        ),
        body: BlocBuilder<MapCubit, MapState>(builder: (context, state) {
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: double.maxFinite,
                      height: double.maxFinite,
                      child: FlutterMap(
                        key: mapKey,
                        mapController: mapController,
                        options: MapOptions(
                            center: LatLng(49.842957, 24.031111),
                            zoom: state.currentZoom,
                            minZoom: 2,
                            maxZoom: 18.0,
                            onTap: (tapPosition, point) {
                              context
                                  .read<MapCubit>()
                                  .zoomIn(mapController, point);
                              context.read<MapCubit>().addMarker(point, mapKey);
                            },
                            keepAlive: true),
                        children: [
                          TileLayer(
                              subdomains: const ['a', 'b', 'c'],
                              urlTemplate:
                                  'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'),
                          MarkerLayer(
                              markers: state.markers
                                  .map((e) => state.currentZoom > 17
                                      ? Marker(
                                          point: e,
                                          width: min(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  50,
                                              500),
                                          height: min(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  50,
                                              500),
                                          builder: (context) => Container(
                                              color: state
                                                  .colorForCoord(e)
                                                  .withOpacity(0.5)))
                                      : Marker(
                                          point: e,
                                          width: 20,
                                          height: 20,
                                          builder: (context) => Container(
                                                decoration: BoxDecoration(
                                                    color: state
                                                        .colorForCoord(e)
                                                        .withOpacity(0.5),
                                                    shape: BoxShape.circle),
                                              )))
                                  .toList())
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                      child: Container(
                          margin: const EdgeInsets.only(bottom: 50),
                          child: CupertinoButton.filled(
                              child: const Text('Detect plantations'),
                              onPressed: () {
                                context.read<MapCubit>().zoomIn(
                                    mapController, mapController.center);
                                context
                                    .read<MapCubit>()
                                    .addMarker(mapController.center, mapKey);
                              })))),
              Align(
                  alignment: Alignment.topRight,
                  child: SafeArea(
                      child: Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: DropdownButton(
                              dropdownColor: Colors.white,
                              isDense: true,
                              underline: const SizedBox(),
                              borderRadius: BorderRadius.circular(10),
                              value: state.currentModel,
                              items: modelsList
                                  .map((model) => DropdownMenuItem<String>(
                                      value: model, child: Text(model)))
                                  .toList(),
                              onChanged: (String? model) {
                                context.read<MapCubit>().selectModel(model);
                              }))))
            ],
          );
        }));
  }
}
