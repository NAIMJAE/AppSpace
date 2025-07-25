import 'package:flutter/material.dart';
import 'package:tracking/ui/widgets/button/text_btn.dart';

/// context와 message를 받아 True, False를 반환하는 모달
class ConfirmDialog {
  static Future<bool> show(
    BuildContext context, {
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 100,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: TextBtn(
                      text: '취소', textSize: 16, textColor: Colors.black),
                ),
              ),
              SizedBox(
                width: 100,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(true),
                  child: TextBtn(
                      text: '확인', textSize: 16, textColor: Colors.green),
                ),
              ),
            ],
          )
        ],
      ),
    );

    return result ?? false;
  }
}
