import 'carp_movesense_flutter_pigeon.dart';

/// Deprecated compatibility wrapper for code importing the template file.
///
/// Native communication now goes through generated Pigeon bindings. Keep this
/// class only as a short-term migration aid; new code should use
/// [PigeonCarpMovesenseFlutter].
@Deprecated('Use PigeonCarpMovesenseFlutter; this plugin no longer uses raw MethodChannel transport.')
class MethodChannelCarpMovesenseFlutter extends PigeonCarpMovesenseFlutter {
  MethodChannelCarpMovesenseFlutter({super.gateway});
}
