part of 'map_cubit.dart';

class MapState extends Equatable {
  final List<LatLng> positions;
  final List<LatLng> markers;
  final double currentZoom;
  final String currentModel;
  final List<bool> results;

  const MapState(
      {required this.positions,
      required this.currentZoom,
      required this.markers,
      required this.results,
      required this.currentModel});

  @override
  List<Object?> get props =>
      [positions, currentZoom, currentModel, results, markers];

  MapState copyWith(
      {List<LatLng>? positions,
      double? currentZoom,
      List<LatLng>? markers,
      List<bool>? results,
      String? currentModel}) {
    return MapState(
        positions: positions ?? this.positions,
        markers: markers ?? this.markers,
        results: results ?? this.results,
        currentModel: currentModel ?? this.currentModel,
        currentZoom: currentZoom ?? this.currentZoom);
  }

  Color colorForCoord(LatLng point) {
    int index = markers.indexOf(point);

    if (index >= 0 && index < results.length) {
      return results[index] ? Colors.green : Colors.red;
    } else {
      return Colors.red;
    }
  }
}

List<String> modelsList = [
  'ResNet50',
  'VGG19',
  'ResNet50 - FastAI',
  'ResNet18 - FastAI'
];
