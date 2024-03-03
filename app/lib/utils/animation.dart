import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

// ignore: must_be_immutable
class AnimationDialog extends StatefulWidget {
  late String name;
  late String text;
  late String animationpath;
  Color color, color2;
  void Function()? onTap;
  AnimationDialog({
    super.key,
    required this.name,
    required this.text,
    required this.animationpath,
    required this.color,
    required this.color2,
    required this.onTap,
  });

  @override
  State<AnimationDialog> createState() => _AnimationDialogState();
}

class _AnimationDialogState extends State<AnimationDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.color,
      content: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          height: 400,
          width: 250,
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 250,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(1000),
                    child: Lottie.asset(
                      widget.animationpath,
                      repeat: false,
                    )),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                widget.name,
                style: GoogleFonts.bebasNeue(
                  fontSize: 31,
                ),
              ),
              const SizedBox(
                height: 17,
              ),
              GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  height: 50,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: widget.color2,
                  ),
                  child: Center(
                      child: Text(
                    widget.text,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
