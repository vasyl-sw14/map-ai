import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart';
import 'package:screenshot/screenshot.dart';

part 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit()
      : super(const MapState(
            positions: [],
            markers: [],
            currentZoom: 13,
            results: [],
            currentModel: 'ResNet50'));

  void zoomIn(MapController controller, LatLng point) {
    controller.move(point, 16.4);
    emit(state.copyWith(currentZoom: 16.4));
  }

  void setZoom(double zoom) {
    emit(state.copyWith(currentZoom: zoom));
  }

  Future<void> addMarker(LatLng coords, ScreenshotController controller) async {
    bool positive = false;

    Uint8List? image = await _capturePng(controller);

    if (image != null) {
      String base64Image = base64Encode(image);

      final response = await post(
          Uri.parse(
              'https://u3mn3ctbqf.execute-api.eu-central-1.amazonaws.com/inference'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'img': base64Image}));

      if (response.statusCode == 200) {
        Map<String, dynamic> result = json.decode(json.decode(response.body));

        print(result);

        if (result['result'] == '1') {
          positive = true;
        }
      }
    }

    emit(state.copyWith(
        markers: List.of(state.markers)..add(coords),
        results: List.of(state.results)..add(positive)));
  }

  Future<Uint8List?> _capturePng(ScreenshotController controller) async {
    Uint8List? image = await controller.capture();

    return image;
  }

  void selectModel(String? model) {
    emit(state.copyWith(currentModel: model));
  }
}
