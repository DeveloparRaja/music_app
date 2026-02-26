import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/repositories/track_repository.dart';
import 'package:music_app/screen/library_screen.dart';
import 'package:music_app/services/deezer_service.dart';

import 'bloc/track_bloc.dart';
import 'bloc/track_event.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final itunesService = ItunesService();
    final repository = TrackRepository(itunesService);
    final connectivity = Connectivity(); // ← added

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => TrackBloc(
            repository: repository,
            connectivity: connectivity, // ← pass here
          )..add(const TrackFetchInitial(query: 'eminem')),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Music Library',
        theme: ThemeData(primarySwatch: Colors.deepPurple),
        home: TrackListScreen(repository: repository, connectivity: connectivity),
      ),
    );
  }
}