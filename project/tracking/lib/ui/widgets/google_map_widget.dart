import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracking/data/models/tracking.dart';

class GoogleMapWidget extends StatefulWidget {
  final List<Tracking> trackingList;

  const GoogleMapWidget({
    Key? key,
    required this.trackingList,
  }) : super(key: key);

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  GoogleMapController? mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _updateMarkersAndPolyline();
  }

  @override
  void didUpdateWidget(covariant GoogleMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.trackingList.length != oldWidget.trackingList.length) {
      _updateMarkersAndPolyline();
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  /// Tracking 리스트 기반으로 마커/선 업데이트
  Future<void> _updateMarkersAndPolyline() async {
    _markers.clear();
    _polylines.clear();

    if (widget.trackingList.isEmpty) return;

    // ✅ verification == true인 좌표만 필터링
    final validPoints = widget.trackingList
        .where((tracking) => tracking.verification == true)
        .map((tracking) => LatLng(tracking.latitude, tracking.longitude))
        .toList();

    if (validPoints.isNotEmpty) {
      // 시작 마커
      _markers.add(
        Marker(
          markerId: const MarkerId('start_marker'),
          position: validPoints.first,
        ),
      );

      // 끝 마커
      if (validPoints.length > 1) {
        _markers.add(
          Marker(
            markerId: const MarkerId('end_marker'),
            position: validPoints.last,
          ),
        );
      }
    }

    // ✅ verification에 따라 선 분리
    if (widget.trackingList.length >= 2) {
      List<LatLng> segment = [];
      bool? currentVerification = widget.trackingList.first.verification;
      int polylineId = 0;

      for (int i = 0; i < widget.trackingList.length; i++) {
        final tracking = widget.trackingList[i];
        final latLng = LatLng(tracking.latitude, tracking.longitude);

        if (currentVerification == null) {
          currentVerification = tracking.verification;
        }

        if (tracking.verification != currentVerification &&
            segment.length >= 2) {
          if (currentVerification == true) {
            _polylines.add(
              Polyline(
                polylineId: PolylineId('polyline_$polylineId'),
                points: List.from(segment),
                color: Colors.blue,
                width: 5,
                zIndex: 100,
              ),
            );
            polylineId++;
          }
          segment.clear();
        }

        segment.add(latLng);
        currentVerification = tracking.verification;
      }

      if (segment.length >= 2 && currentVerification == true) {
        _polylines.add(
          Polyline(
            polylineId: PolylineId('polyline_$polylineId'),
            points: List.from(segment),
            color: Colors.blue,
            width: 5,
            zIndex: 100,
          ),
        );
      }
    }

    // 새로 추가된 **정상 좌표** 기준으로 지도 중심 이동
    if (mapController != null && validPoints.isNotEmpty) {
      await mapController!.animateCamera(
        CameraUpdate.newLatLng(validPoints.last),
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialPosition = widget.trackingList.isNotEmpty
        ? LatLng(widget.trackingList.first.latitude,
            widget.trackingList.first.longitude)
        : const LatLng(37.5665, 126.9780); // 기본 좌표 서울

    return GoogleMap(
      mapType: MapType.normal,
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 16.5,
      ),
      buildingsEnabled: false,
      markers: _markers,
      polylines: _polylines,
      myLocationEnabled: false,
      zoomControlsEnabled: true,
      myLocationButtonEnabled: false,
    );
  }
}
