class ProductImageHelper {
  static const String defaultTomato = 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600&auto=format&fit=crop&q=80';
  static const String defaultSpinach = 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=600&auto=format&fit=crop&q=80';
  static const String defaultCarrot = 'https://images.unsplash.com/photo-1598170845058-12ef4a457939?w=600&auto=format&fit=crop&q=80';
  static const String defaultBanana = 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=600&auto=format&fit=crop&q=80';
  static const String defaultRice = 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600&auto=format&fit=crop&q=80';
  static const String defaultPepper = 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=600&auto=format&fit=crop&q=80';
  static const String defaultCoconut = 'https://images.unsplash.com/photo-1543362906-acfc16c67564?w=600&auto=format&fit=crop&q=80';

  static const String fallbackVegetables = 'https://images.unsplash.com/photo-1566385101042-1a0aa0c1268c?w=600&auto=format&fit=crop&q=80';
  static const String fallbackGreens = 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600&auto=format&fit=crop&q=80';
  static const String fallbackFruits = 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=600&auto=format&fit=crop&q=80';
  static const String fallbackGrains = 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=600&auto=format&fit=crop&q=80';

  /// Resolves the best image URL for a given product or category
  static String getImageUrl({required String name, required String categoryName, List<String>? imageUrls}) {
    if (imageUrls != null && imageUrls.isNotEmpty && imageUrls.first.trim().isNotEmpty) {
      return imageUrls.first.trim();
    }

    final lowerName = name.toLowerCase();
    final lowerCat = categoryName.toLowerCase();

    if (lowerName.contains('tomato')) return defaultTomato;
    if (lowerName.contains('spinach') || lowerName.contains('palak') || lowerName.contains('greens')) return defaultSpinach;
    if (lowerName.contains('carrot')) return defaultCarrot;
    if (lowerName.contains('banana')) return defaultBanana;
    if (lowerName.contains('rice') || lowerName.contains('paddy')) return defaultRice;
    if (lowerName.contains('pepper') || lowerName.contains('capsicum')) return defaultPepper;
    if (lowerName.contains('coconut')) return defaultCoconut;

    if (lowerCat.contains('green')) return fallbackGreens;
    if (lowerCat.contains('fruit')) return fallbackFruits;
    if (lowerCat.contains('grain')) return fallbackGrains;
    return fallbackVegetables;
  }

  /// Gets default image URL for a newly selected category
  static String getCategoryDefaultImage(String categoryName) {
    final lowerCat = categoryName.toLowerCase();
    if (lowerCat.contains('green')) return defaultSpinach;
    if (lowerCat.contains('fruit')) return defaultBanana;
    if (lowerCat.contains('grain')) return defaultRice;
    return defaultTomato;
  }
}
