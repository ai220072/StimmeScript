import 'package:flutter/material.dart';

class RecordButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onStart;
  final VoidCallback onStop;

  const RecordButton({
    super.key,
    required this.isRecording,
    required this.onStart,
    required this.onStop,
  });

  final Duration duration = const Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.5;

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedContainer(
          width: width,
          height: width,
          duration: duration,
          decoration: BoxDecoration(
            border: Border.all(
              color: isRecording ? Colors.red : Colors.grey.shade400,
              width: isRecording ? 4.0 : 1.0,
            ),
            borderRadius: BorderRadius.circular(width),
          ),
          child: tapButton(width),
        ),
      ],
    );
  }

  Widget tapButton(double size) => Center(
      child: GestureDetector(
        onTap: isRecording ? onStop : onStart,
        child: AnimatedContainer(
          duration: duration,
          width: isRecording ? size * 0.65 - 30 : size * 0.65,
          height: isRecording ? size * 0.65 - 30 : size * 0.65,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF0000), Color(0xFFB22222)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: isRecording ? 4.0 : 8.0,
            ),
            borderRadius: BorderRadius.circular(isRecording ? 20 : 80),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.4),
                blurRadius: isRecording ? 17.5 : 40.0,
                spreadRadius: isRecording ? 7.5 : 20.0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              isRecording ? 'STOP' : 'RECORD',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );

}