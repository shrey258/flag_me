enum RelationType {
  professional,
  personal,
  family,
}

enum GiftCategory {
  books,
  stationery,
  watches,
  officeAccessories,
  techGadgets,
  flowers,
  gourmetTreats,
  fashionAccessories,
  clothing,
  shoes,
  jewelry,
  electronics,
  hobbyItems,
  experienceGifts,
  beautyProducts,
  homeDecor,
  kitchenAppliances,
  photoFrames,
  furniture,
  gardenItems,
  familyGames,
  travelAccessories,
  personalizedItems,
}

extension GiftCategoryExtension on GiftCategory {
  String get displayName {
    switch (this) {
      case GiftCategory.officeAccessories:
        return 'Office Accessories';
      case GiftCategory.techGadgets:
        return 'Tech Gadgets';
      case GiftCategory.gourmetTreats:
        return 'Gourmet Treats';
      case GiftCategory.fashionAccessories:
        return 'Fashion Accessories';
      case GiftCategory.hobbyItems:
        return 'Hobby Items';
      case GiftCategory.experienceGifts:
        return 'Experience Gifts';
      case GiftCategory.beautyProducts:
        return 'Beauty Products';
      case GiftCategory.homeDecor:
        return 'Home Decor';
      case GiftCategory.kitchenAppliances:
        return 'Kitchen Appliances';
      case GiftCategory.photoFrames:
        return 'Photo Frames';
      case GiftCategory.gardenItems:
        return 'Garden Items';
      case GiftCategory.familyGames:
        return 'Family Games';
      case GiftCategory.travelAccessories:
        return 'Travel Accessories';
      case GiftCategory.personalizedItems:
        return 'Personalized Items';
      default:
        return name[0].toUpperCase() + name.substring(1);
    }
  }

  static Map<RelationType, List<GiftCategory>> getCategoriesByRelationType() {
    return {
      RelationType.professional: [
        GiftCategory.books,
        GiftCategory.stationery,
        GiftCategory.watches,
        GiftCategory.officeAccessories,
        GiftCategory.techGadgets,
        GiftCategory.flowers,
        GiftCategory.gourmetTreats,
      ],
      RelationType.personal: [
        GiftCategory.fashionAccessories,
        GiftCategory.clothing,
        GiftCategory.shoes,
        GiftCategory.jewelry,
        GiftCategory.electronics,
        GiftCategory.hobbyItems,
        GiftCategory.experienceGifts,
        GiftCategory.beautyProducts,
      ],
      RelationType.family: [
        GiftCategory.homeDecor,
        GiftCategory.kitchenAppliances,
        GiftCategory.photoFrames,
        GiftCategory.furniture,
        GiftCategory.gardenItems,
        GiftCategory.familyGames,
        GiftCategory.travelAccessories,
        GiftCategory.personalizedItems,
      ],
    };
  }
}
