import '../domain/entities/video_source.dart';

/// Hardcoded catalogue for the task; a real app would fetch this from a
/// backend together with the stream URLs. Titles and durations are catalogue
/// metadata on purpose — HLS carries no reliable presentation title, and
/// probing playlists for durations costs a network round-trip per film.
///
/// Both URLs are single HLS variants so playback works everywhere, including
/// the Android emulator: a master playlist stalls the emulated H.264 decoder
/// when combined with the `mediacodec_embed` workaround for media-kit#1343.
/// On a real device prefer master playlists — they enable adaptive quality
/// (for the first film: .../movie_hls/master.m3u8). See README, «Запуск».
const sampleCatalogue = <VideoSource>[
  VideoSource(
    url:
        'https://exprts.stork.ru/.well-known/acme-challenge/'
        'data534gsf5109/data/movie_hls/v0/index.m3u8',
    title: 'Colombo: Butterfly in Shades of Grey',
    duration: Duration(minutes: 10),
  ),
  VideoSource(
    url:
        'https://test-streams.mux.dev/x36xhzz/'
        'url_0/193039199_mp4_h264_aac_hd_7.m3u8',
    title: 'Big Buck Bunny',
    duration: Duration(minutes: 10, seconds: 34),
  ),
];
