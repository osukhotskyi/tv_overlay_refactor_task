import '../domain/entities/video_source.dart';

/// Hardcoded content for the task; a real app would resolve this from a
/// catalogue and pass it to the player screen the same way.
///
/// This points at a single HLS variant instead of the master playlist on
/// purpose: the master playlist stalls the emulator's H.264 decoder when
/// combined with the `mediacodec_embed` workaround for media-kit#1343.
/// On a real Android TV the master playlist is the correct choice.
const sampleVideo = VideoSource(
  url:
      'https://exprts.stork.ru/.well-known/acme-challenge/'
      'data534gsf5109/data/movie_hls/v0/index.m3u8',
  title: 'Big Buck Bunny',
);
