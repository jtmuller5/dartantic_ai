import 'provider.dart';
import 'provider_settings.dart';

/// Function type for creating provider instances from settings.
///
/// Takes [ProviderSettings] and returns a [Provider] instance configured
/// according to those settings.
typedef ProviderFactory = Provider Function(ProviderSettings settings);
