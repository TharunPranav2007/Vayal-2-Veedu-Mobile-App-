import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/product_image_helper.dart';

class ProduceImageWidget extends StatelessWidget {
  final String productName;
  final String categoryName;
  final List<String>? imageUrls;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;

  const ProduceImageWidget({
    super.key,
    required this.productName,
    required this.categoryName,
    this.imageUrls,
    this.width = 60,
    this.height = 60,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = ProductImageHelper.getImageUrl(
      name: productName,
      categoryName: categoryName,
      imageUrls: imageUrls,
    );

    final fallbackUrl = ProductImageHelper.getFallbackImageUrl(
      name: productName,
      categoryName: categoryName,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: Image.network(
          resolvedUrl,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            // Secondary network fallback with category default
            return Image.network(
              fallbackUrl,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (context, error2, stackTrace2) => Container(
                width: width,
                height: height,
                color: AppColors.surfaceSubtleGreen,
                child: Center(
                  child: Icon(
                    categoryName.toLowerCase().contains('green')
                        ? Icons.grass
                        : categoryName.toLowerCase().contains('fruit')
                            ? Icons.apple
                            : categoryName.toLowerCase().contains('grain')
                                ? Icons.grain
                                : Icons.eco,
                    size: width * 0.5,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: width,
              height: height,
              color: AppColors.surfaceSubtleGreen,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
              ),
            );
          },
        ),
      ),
    );
  }
}
