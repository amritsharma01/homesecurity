import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class VerifiedScreen extends StatefulWidget {
  late String name;
  late String text;
  late String imgpath;
  late String verified;
  Color color, color2;
  void Function()? ontap;

  VerifiedScreen(
      {super.key,
      required this.ontap,
      required this.name,
      required this.imgpath,
      required this.color,
      required this.text,
      required this.color2,
      required this.verified});

  @override
  State<VerifiedScreen> createState() => _VerifiedScreenState();
}

class _VerifiedScreenState extends State<VerifiedScreen> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.color,
      content: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          height: 450,
          width: 250,
          child: Column(
            children: [
              Image.asset(
                widget.verified,
                height: 40,
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 250,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(1000),
                    child: Image.asset(widget.imgpath)),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                widget.name,
                style: GoogleFonts.bebasNeue(
                  fontSize: 44,
                ),
              ),
              const SizedBox(
                height: 7,
              ),
              GestureDetector(
                onTap: widget.ontap,
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
