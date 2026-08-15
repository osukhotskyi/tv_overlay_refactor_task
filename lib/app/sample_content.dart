import '../domain/entities/video_source.dart';

/// Hardcoded content for the task; a real app would resolve this from a
/// catalogue and pass it to the player screen the same way.
///
/// The URL points at the master playlist, as production should: it is what
/// gives the player adaptive quality. On the Android emulator the master
/// playlist stalls the emulated H.264 decoder when combined with the
/// `mediacodec_embed` workaround for media-kit#1343 — for local debugging
/// swap in the single-variant URL below. See README, «Запуск».
const sampleVideo = VideoSource(
  url:
      'https://exprts.stork.ru/.well-known/acme-challenge/'
      'data534gsf5109/data/movie_hls/master.m3u8',
  // Single variant for the emulator:
  // 'https://exprts.stork.ru/.well-known/acme-challenge/'
  // 'data534gsf5109/data/movie_hls/v0/index.m3u8',
  title: 'Big Buck Bunny',
);
