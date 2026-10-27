import 'package:flutter/material.dart';

class ZoomableImageThumbnail extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ZoomableImageThumbnail({
    super.key,
    required this.imageUrl,
    this.width = 44,
    this.height = 44,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Normal Dialog without any extra animation
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Zoomable & Pannable Image
                InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Close Button
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: width,
            height: height,
            color: Colors.grey.shade300,
            child: const Icon(Icons.image_not_supported_outlined, size: 18),
          ),
        ),
      ),
    );
  }
}