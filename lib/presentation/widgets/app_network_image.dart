import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Drop-in replacement for `Image.network(url, fit:, errorBuilder:)` that
/// caches decoded bytes on disk/memory (no re-fetch/re-decode on every
/// scroll-reveal) and downsamples the decode to the rendered size when
/// [width]/[height] are given, instead of decoding at full source resolution.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    required this.errorWidget,
    this.placeholder,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget errorWidget;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: width != null ? (width! * dpr).round() : null,
      memCacheHeight: height != null ? (height! * dpr).round() : null,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: placeholder != null
          ? (_, _) => placeholder!
          : (_, _) => const SizedBox.shrink(),
      errorWidget: (_, _, _) => errorWidget,
    );
  }
}
