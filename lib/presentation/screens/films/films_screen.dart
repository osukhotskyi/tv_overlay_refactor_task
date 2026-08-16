import 'package:flutter/material.dart';

import '../../../domain/entities/video_source.dart';
import '../../utils/duration_label.dart';
import '../../widgets/player_button.dart';

/// The opening screen: pick a film, watch it.
///
/// Deliberately bloc-free: the catalogue is a static list handed in by the
/// composition root, and picking a film is a callback — navigation stays
/// with whoever owns the routes. Vertical D-pad movement between tiles is
/// the framework's geometric traversal; nothing to route by hand here.
class FilmsScreen extends StatelessWidget {
  const FilmsScreen({
    required this.films,
    required this.onFilmSelected,
    super.key,
  });

  final List<VideoSource> films;
  final ValueChanged<VideoSource> onFilmSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 24,
          children: [
            const Text(
              'Films',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: films.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _FilmTile(
                  film: films[index],
                  // The screen has no focus controller; the first tile takes
                  // the initial focus itself.
                  autofocus: index == 0,
                  onTap: () => onFilmSelected(films[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilmTile extends StatelessWidget {
  const _FilmTile({
    required this.film,
    required this.onTap,
    this.autofocus = false,
  });

  final VideoSource film;
  final VoidCallback onTap;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final duration = film.duration;
    return PlayerButton(
      autofocus: autofocus,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          spacing: 16,
          children: [
            Expanded(
              child: Text(film.title, style: const TextStyle(fontSize: 20)),
            ),
            if (duration != null)
              Text(
                duration.asTimeLabel,
                style: const TextStyle(
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
