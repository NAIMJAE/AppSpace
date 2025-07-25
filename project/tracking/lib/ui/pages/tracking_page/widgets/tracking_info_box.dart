import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TrackingInfoBox extends StatefulWidget {
  final Widget child;
  const TrackingInfoBox({super.key, required this.child});

  @override
  State<TrackingInfoBox> createState() => _TrackingInfoBoxState();
}

class _TrackingInfoBoxState extends State<TrackingInfoBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(8.0),
      width: MediaQuery.sizeOf(context).width - 16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
        color: Color(0XFF222222),
      ),
      child: widget.child,
    );
  }
}
