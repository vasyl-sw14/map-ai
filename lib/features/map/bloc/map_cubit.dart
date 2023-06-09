import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:ui' as ui;

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
    controller.move(point, 18);
    emit(state.copyWith(currentZoom: 18));
  }

  void setZoom(double zoom) {
    emit(state.copyWith(currentZoom: zoom));
  }

  Future<void> addMarker(LatLng coords, GlobalKey key) async {
    bool positive = false;

    if (kIsWeb && kDebugMode) {
      Uint8List? image = await _capturePng(key);

      if (image != null) {
        final interpreter = await Interpreter.fromAsset('assets/model.tflite');

        final inputImage = image;
        final output = List.filled(1 * 2, 0).reshape([1, 2]);

        interpreter.run(inputImage, output);

        if (output[0] > 0.8) {
          positive = true;
        }
      }
    }

    emit(state.copyWith(
        markers: List.of(state.markers)..add(coords),
        results: List.of(state.results)..add(positive)));
  }

  Future<Uint8List?> _capturePng(GlobalKey key) async {
    final RenderRepaintBoundary boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary;

    final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List? pngBytes = byteData?.buffer.asUint8List();
    return pngBytes;
  }

  void selectModel(String? model) {
    emit(state.copyWith(currentModel: model));
  }
}
