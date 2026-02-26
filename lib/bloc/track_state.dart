import 'package:equatable/equatable.dart';
import '../model/track_model.dart';

class TrackState extends Equatable {
  final List<Track> tracks;
  final bool isLoading;
  final bool hasMore;
  final String? errorMessage;
  final bool isConnected;
  final bool noDataFound;


  const TrackState({
    this.tracks = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.errorMessage,
    this.isConnected = true,
    this.noDataFound = false,
  });

  TrackState copyWith({
    List<Track>? tracks,
    bool? isLoading,
    bool? hasMore,
    String? errorMessage,
    bool? isConnected,
    bool? noDataFound,
  }) {
    return TrackState(
      tracks: tracks ?? this.tracks,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage ?? this.errorMessage,
      isConnected: isConnected ?? this.isConnected,
      noDataFound: noDataFound ?? this.noDataFound,
    );
  }

  @override
  List<Object?> get props => [tracks, isLoading, hasMore, errorMessage, isConnected];
}