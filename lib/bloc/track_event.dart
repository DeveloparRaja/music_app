import 'package:equatable/equatable.dart';

abstract class TrackEvent extends Equatable {
  const TrackEvent();

  @override
  List<Object?> get props => [];
}

class TrackFetchInitial extends TrackEvent {
  final String query;
  const TrackFetchInitial({required this.query});
}

class TrackFetchNext extends TrackEvent {}

class TrackRefresh extends TrackEvent {}

class TrackConnectivityChanged extends TrackEvent {
  final bool isConnected;
  const TrackConnectivityChanged({required this.isConnected});
}