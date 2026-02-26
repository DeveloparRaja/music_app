import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../repositories/track_repository.dart';
import '../bloc/track_bloc.dart';
import '../bloc/track_event.dart';
import '../bloc/track_state.dart';
import 'track_details_screen.dart';

class TrackListScreen extends StatefulWidget {
  final TrackRepository repository;
  final Connectivity connectivity;

  const TrackListScreen({
    super.key,
    required this.repository,
    required this.connectivity,
  });

  @override
  State<TrackListScreen> createState() => _TrackListScreenState();
}

class _TrackListScreenState extends State<TrackListScreen> {
  late final TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TrackBloc(
        repository: widget.repository,
        connectivity: widget.connectivity,
      )..add(const TrackFetchInitial(query: 'eminem')),
      child: BlocBuilder<TrackBloc, TrackState>(
        builder: (context, state) {
          final bloc = context.read<TrackBloc>();

          _scrollController.addListener(() {
            if (_scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent - 200 &&
                !state.isLoading &&
                state.hasMore) {
              bloc.add(TrackFetchNext());
            }
          });

          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              title: const Text('Music Tracks'),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search songs, artists...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),

                      suffixIcon: const Icon(Icons.search),
                    ),


                    onChanged: (value) {
                      if (_debounce?.isActive ?? false) {
                        _debounce!.cancel();
                      }

                      _debounce =
                          Timer(const Duration(milliseconds: 500), () {
                            final text = value.trim();
                            bloc.add(
                              TrackFetchInitial(
                                query: text.isEmpty ? 'eminem' : text,
                              ),
                            );
                          });
                    },

                    onSubmitted: (value) {
                      final text = value.trim();
                      bloc.add(
                        TrackFetchInitial(
                          query: text.isEmpty ? 'eminem' : text,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            body: state.errorMessage != null
                ? Center(
              child: Text(
                state.errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
                : RefreshIndicator(
              onRefresh: () async {
                final text = _searchController.text.trim();
                bloc.add(
                  TrackFetchInitial(
                    query: text.isEmpty ? 'eminem' : text,
                  ),
                );
              },
              child: state.isLoading && state.tracks.isEmpty
                  ?  ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 300),
                  Center(child: CircularProgressIndicator()),
                ],
              )
                  : ListView.builder(
                physics:
                const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                itemCount: state.tracks.length +
                    (state.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < state.tracks.length) {
                    final track = state.tracks[index];
                    final duration =
                    (track.trackTimeMillis ~/ 1000);
                    final mins =
                    (duration ~/ 60).toString().padLeft(2, '0');
                    final secs =
                    (duration % 60).toString().padLeft(2, '0');

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: track.artworkUrl.isNotEmpty
                            ? Image.network(
                          track.artworkUrl,
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.music_note,
                              size: 55),
                        )
                            : const Icon(Icons.music_note, size: 55),
                        title: Text(
                          track.trackName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${track.artistName} • ${track.albumName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          '$mins:$secs',
                          style: const TextStyle(
                              color: Colors.grey),
                        ),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TrackDetailsScreen(track: track),
                            ),
                          );
                          if (result == true) {
                            bloc.add(TrackRefresh());
                          }
                        },
                      ),
                    );
                  } else {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                          child: CircularProgressIndicator()),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}