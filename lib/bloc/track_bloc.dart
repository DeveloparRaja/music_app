import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../repositories/track_repository.dart';
import 'track_event.dart';
import 'track_state.dart';

class TrackBloc extends Bloc<TrackEvent, TrackState> {
  final TrackRepository repository;
  final Connectivity connectivity;

  int offset = 0;
  String query = 'eminem';

  TrackBloc({required this.repository, required this.connectivity})
    : super(const TrackState()) {
    
    connectivity.onConnectivityChanged.listen((result) {
      add(
        TrackConnectivityChanged(
          isConnected: result != ConnectivityResult.none,
        ),
      );
    });

    on<TrackFetchInitial>(_onFetchInitial);
    on<TrackFetchNext>(_onFetchNext);
    on<TrackRefresh>(_onRefresh);
    on<TrackConnectivityChanged>(_onConnectivityChanged);
  }

  Future<void> _onFetchInitial(
    TrackFetchInitial event,
    Emitter<TrackState> emit,
  ) async {
    query = event.query.isEmpty ? 'eminem' : event.query;
    if (!state.isConnected) {
      emit(state.copyWith(errorMessage: "NO INTERNET CONNECTION"));
      return;
    }

    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
        tracks: [],
        hasMore: true,
      ),
    );
    offset = 0;

    try {
      final result = await repository.getTracks(query, offset: 0);
      offset = result.length;
      emit(
        state.copyWith(
          tracks: result,
          hasMore: result.length == 50,
          isLoading: false,
          errorMessage: null,
        ),
      );
    } on SocketException {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: "NO INTERNET CONNECTION",
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onFetchNext(
    TrackFetchNext event,
    Emitter<TrackState> emit,
  ) async {
    if (!state.hasMore || state.isLoading || !state.isConnected) return;

    emit(state.copyWith(isLoading: true));
    try {
      final result = await repository.getTracks(query, offset: offset);
      offset += result.length;
      emit(
        state.copyWith(
          tracks: List.from(state.tracks)..addAll(result),
          hasMore: result.length == 50,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onRefresh(TrackRefresh event, Emitter<TrackState> emit) async {
    add(TrackFetchInitial(query: query));
  }

  void _onConnectivityChanged(
    TrackConnectivityChanged event,
    Emitter<TrackState> emit,
  ) {
    emit(state.copyWith(isConnected: event.isConnected));
    if (!event.isConnected) {
      emit(state.copyWith(errorMessage: "NO INTERNET CONNECTION"));
    } else if (state.tracks.isEmpty) {
      add(TrackFetchInitial(query: query));
    }
  }
}
