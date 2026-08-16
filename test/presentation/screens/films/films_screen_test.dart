import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tv_overlay_refactor_task/domain/entities/video_source.dart';
import 'package:tv_overlay_refactor_task/presentation/screens/films/films_screen.dart';

void main() {
  const films = [
    VideoSource(
      url: 'u1',
      title: 'First film',
      duration: Duration(minutes: 10),
    ),
    VideoSource(
      url: 'u2',
      title: 'Second film',
      duration: Duration(minutes: 10, seconds: 34),
    ),
  ];

  Future<void> pumpFilms(
    WidgetTester tester, {
    ValueChanged<VideoSource>? onSelected,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FilmsScreen(films: films, onFilmSelected: onSelected ?? (_) {}),
      ),
    );
    // Lets the first tile's autofocus apply.
    await tester.pump();
  }

  testWidgets('shows every film with its duration', (tester) async {
    await pumpFilms(tester);

    expect(find.text('First film'), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);
    expect(find.text('Second film'), findsOneWidget);
    expect(find.text('10:34'), findsOneWidget);
  });

  testWidgets('Select on the initially focused tile picks the first film', (
    tester,
  ) async {
    VideoSource? selected;
    await pumpFilms(tester, onSelected: (film) => selected = film);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(selected, films.first);
  });

  testWidgets('D-pad down moves to the next film', (tester) async {
    VideoSource? selected;
    await pumpFilms(tester, onSelected: (film) => selected = film);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(selected, films.last);
  });
}
