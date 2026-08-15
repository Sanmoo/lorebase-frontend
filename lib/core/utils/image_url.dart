String highResolutionIgdbImageUrl(String imageUrl) {
  final uri = Uri.tryParse(imageUrl);
  if (uri?.host != 'images.igdb.com') return imageUrl;

  return imageUrl.replaceFirst('/t_thumb/', '/t_cover_big/');
}
