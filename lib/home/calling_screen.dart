import 'package:flutter/material.dart';

class CallingScreen extends StatelessWidget {
  const CallingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/background.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomIconButton(
                  icon: Icons.volume_up,
                ),
                CustomIconButton(
                  icon: Icons.flip_camera_ios_rounded,
                ),
                CustomIconButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                ),
                CustomIconButton(
                  icon: Icons.keyboard_voice_rounded,
                ),
                CustomIconButton(
                  icon: Icons.videocam,
                )
              ],
            ),
          ),
          Positioned(
            bottom: 120,
            right: 20,
            child: Container(
              height: 300,
              width: 200,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/background.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  const CustomIconButton(
      {super.key, required this.icon, this.onTap, this.color});

  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
          shape: const OvalBorder(), color: color ?? Colors.white24),
      child: IconButton(
          onPressed: onTap,
          icon: Icon(
            icon,
            color: Colors.white,
          )),
    );
  }
}
