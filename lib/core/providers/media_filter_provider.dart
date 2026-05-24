import 'package:flutter_riverpod/legacy.dart';

import '../../features/tracking/data/models/media_type.dart';

final selectedMediaTypeProvider = StateProvider<MediaType>(
  (ref) => MediaType.series,
);
