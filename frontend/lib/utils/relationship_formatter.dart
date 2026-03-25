String formatRelationshipLabel(
  String? relationship, {
  String emptyFallback = 'Chưa cập nhật',
}) {
  final value = (relationship ?? '').trim();
  if (value.isEmpty) {
    return emptyFallback;
  }
  if (value.toLowerCase() == 'me') {
    return 'Bản thân';
  }
  return value;
}
