class ProductImageHelper {
  // Verified Unsplash Produce Images (High Definition & 100% Accurate Visuals)
  static const String tomato = 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600&auto=format&fit=crop&q=80';
  static const String spinach = 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=600&auto=format&fit=crop&q=80';
  static const String carrot = 'https://images.unsplash.com/photo-1590868309235-ea34bed7bd7f?w=600&auto=format&fit=crop&q=80';
  static const String banana = 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=600&auto=format&fit=crop&q=80';
  static const String rice = 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600&auto=format&fit=crop&q=80';
  
  // Vibrant colorful Red, Yellow, Green Bell Peppers
  static const String pepper = 'https://images.unsplash.com/photo-1526470608268-f674ce90ebd4?w=600&auto=format&fit=crop&q=80';
  
  // Fresh Tender Coconut cut open with coconut water
  static const String coconut = 'https://images.unsplash.com/photo-1543362906-acfc16c67564?w=600&auto=format&fit=crop&q=80';

  static const String onion = 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=600&auto=format&fit=crop&q=80';
  static const String potato = 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600&auto=format&fit=crop&q=80';
  static const String brinjal = 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=600&auto=format&fit=crop&q=80';
  static const String mango = 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=600&auto=format&fit=crop&q=80';
  static const String apple = 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600&auto=format&fit=crop&q=80';
  static const String orange = 'https://images.unsplash.com/photo-1611080626919-7cf5a9dbab5b?w=600&auto=format&fit=crop&q=80';
  static const String watermelon = 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=600&auto=format&fit=crop&q=80';
  static const String ladyfinger = 'https://images.unsplash.com/photo-1603833665858-e61d17a86224?w=600&auto=format&fit=crop&q=80';
  static const String lentils = 'https://images.unsplash.com/photo-1599940824399-b87987ceb72a?w=600&auto=format&fit=crop&q=80';
  static const String wheat = 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=600&auto=format&fit=crop&q=80';

  // Backup verified fallback produce images
  static const String carrotBackup = 'https://images.unsplash.com/photo-1582515073490-39981397c445?w=600&auto=format&fit=crop&q=80';
  static const String pepperBackup = 'https://images.unsplash.com/photo-1589927986089-35812388d1f4?w=600&auto=format&fit=crop&q=80';
  static const String coconutBackup = 'https://images.unsplash.com/photo-1584447128309-b66b7a4d1b63?w=600&auto=format&fit=crop&q=80';

  static const String fallbackVegetables = 'https://images.unsplash.com/photo-1566385101042-1a0aa0c1268c?w=600&auto=format&fit=crop&q=80';
  static const String fallbackGreens = 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600&auto=format&fit=crop&q=80';
  static const String fallbackFruits = 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=600&auto=format&fit=crop&q=80';
  static const String fallbackGrains = 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=600&auto=format&fit=crop&q=80';

  /// Resolves the best image URL for a given product or category
  static String getImageUrl({required String name, required String categoryName, List<String>? imageUrls}) {
    final lowerName = name.toLowerCase();

    // Direct produce keyword matching to ensure accurate visuals
    if (lowerName.contains('carrot')) return carrot;
    if (lowerName.contains('pepper') || lowerName.contains('capsicum') || lowerName.contains('chilli') || lowerName.contains('chili')) return pepper;
    if (lowerName.contains('coconut')) return coconut;
    if (lowerName.contains('tomato')) return tomato;
    if (lowerName.contains('spinach') || lowerName.contains('palak') || lowerName.contains('keerai') || lowerName.contains('leaf') || lowerName.contains('green')) return spinach;
    if (lowerName.contains('banana')) return banana;
    if (lowerName.contains('rice') || lowerName.contains('paddy')) return rice;

    if (lowerName.contains('onion') || lowerName.contains('shallot')) return onion;
    if (lowerName.contains('potato') || lowerName.contains('aloo')) return potato;
    if (lowerName.contains('brinjal') || lowerName.contains('eggplant') || lowerName.contains('baingan')) return brinjal;
    if (lowerName.contains('mango')) return mango;
    if (lowerName.contains('apple')) return apple;
    if (lowerName.contains('orange') || lowerName.contains('citrus')) return orange;
    if (lowerName.contains('watermelon') || lowerName.contains('melon')) return watermelon;
    if (lowerName.contains('lady') || lowerName.contains('okra') || lowerName.contains('bhindi')) return ladyfinger;
    if (lowerName.contains('dal') || lowerName.contains('lentil') || lowerName.contains('pulse')) return lentils;
    if (lowerName.contains('wheat') || lowerName.contains('flour') || lowerName.contains('atta')) return wheat;

    if (imageUrls != null && imageUrls.isNotEmpty && imageUrls.first.trim().isNotEmpty) {
      final url = imageUrls.first.trim();
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return url;
      }
    }

    final lowerCat = categoryName.toLowerCase();
    if (lowerCat.contains('green')) return fallbackGreens;
    if (lowerCat.contains('fruit')) return fallbackFruits;
    if (lowerCat.contains('grain')) return fallbackGrains;
    return fallbackVegetables;
  }

  /// Backup image URL if primary image fails to load
  static String getFallbackImageUrl({required String name, required String categoryName}) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('carrot')) return carrotBackup;
    if (lowerName.contains('pepper') || lowerName.contains('capsicum')) return pepperBackup;
    if (lowerName.contains('coconut')) return coconutBackup;
    return getCategoryDefaultImage(categoryName);
  }

  /// Gets default image URL for a category
  static String getCategoryDefaultImage(String categoryName) {
    final lowerCat = categoryName.toLowerCase();
    if (lowerCat.contains('green')) return spinach;
    if (lowerCat.contains('fruit')) return banana;
    if (lowerCat.contains('grain')) return rice;
    return fallbackVegetables;
  }
}
