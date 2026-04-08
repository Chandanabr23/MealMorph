/// One fridge entry backed by a local image file from the device camera.
class FridgeItem {
  const FridgeItem({
    required this.id,
    required this.imagePath,
    this.name,
    this.detail,
    this.expiringSoon = false,
  });

  final String id;
  final String imagePath;
  final String? name;
  final String? detail;
  final bool expiringSoon;
}
