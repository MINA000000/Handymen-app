import 'firebase_methods.dart';

class SkillsData {
  static Map<String, List<String>> categorySkills = {
    CategoriesNames.carpenter: [
      'Flooring',
      'Door fixing',
      'Cabinet installation',
      'Wood cutting',
      'Furniture making'
    ],
    CategoriesNames.plumbing: [
      'Water heater repair',
      'Leak repair',
      'Pipe fixing',
      'Toilet installation',
      'Drain cleaning'
    ],
    CategoriesNames.blacksmith: [
      'Steel fabrication',
      'Gate welding',
      'Metal forging',
      'Custom metal design',
      'Iron works'
    ],
    CategoriesNames.electrical: [
      'Lighting fixtures',
      'Wiring',
      'Power backup setup',
      'Circuit installation',
      'Electrical maintenance'
    ],
    CategoriesNames.painter: [
      'Spray painting',
      'Wall painting',
      'Exterior painting',
      'Texture painting',
      'Furniture painting'
    ],
    CategoriesNames.aluminum: [
      'Custom aluminum works',
      'Frame fabrication',
      'Partition installation',
      'Door fixing',
      'Window installation'
    ],
    CategoriesNames.marble: [
      'Marble cutting',
      'Tile laying',
      'Countertop installation',
      'Mosaic work',
      'Stone polishing'
    ],
    CategoriesNames.upholsterer: [
      'Fabric stitching',
      'Furniture restoration',
      'Foam replacement',
      'Sofa upholstery',
      'Car seat covering'
    ],
  };
}