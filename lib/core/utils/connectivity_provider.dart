import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the current connectivity status stream
final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Simple boolean provider: true if online, false if offline
final isOnlineProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityStreamProvider);
  
  return connectivityAsync.when(
    data: (results) {
      // If any connection type is available (wifi, mobile, ethernet), we're online
      return results.isNotEmpty && 
             !results.every((result) => result == ConnectivityResult.none);
    },
    loading: () => true, // Assume online while loading
    error: (_, __) => true, // Assume online on error
  );
});
