enum SocialPrivacy {
  public,
  private;

  bool get isPublic => this == SocialPrivacy.public;
}
