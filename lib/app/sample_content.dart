import '../domain/entities/video_source.dart';

/// Hardcoded content for the task; a real app would resolve this from a
/// catalogue and pass it to the player screen the same way.
///
/// Points at a single HLS variant so playback works everywhere, including
/// the Android emulator: the master playlist stalls the emulated H.264
/// decoder when combined with the `mediacodec_embed` workaround for
/// media-kit#1343. On a real device swap in the master playlist below —
/// it is what enables adaptive quality. See README, «Запуск».
const sampleVideo = VideoSource(
  url:
      'https://exprts.stork.ru/.well-known/acme-challenge/'
      'data534gsf5109/data/movie_hls/v0/index.m3u8',
  // Master playlist (adaptive quality) for real devices:
  // 'https://exprts.stork.ru/.well-known/acme-challenge/'
  // 'data534gsf5109/data/movie_hls/master.m3u8',
  title: 'Big Buck Bunny',
);
