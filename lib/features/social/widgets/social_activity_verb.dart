String socialActivityVerbFor(String type) {
  return switch (type.toUpperCase()) {
    'RATED' => 'avaliou',
    'REVIEWED' => 'escreveu uma review de',
    'COMPLETED' => 'completou',
    'STARTED_WATCHING' => 'começou',
    'DROPPED' => 'abandonou',
    'ADDED_TO_LIST' => 'adicionou à lista',
    _ => 'interagiu com',
  };
}
