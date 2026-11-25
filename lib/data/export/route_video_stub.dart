import 'route_video.dart';

/// Whether this build can make videos.
bool get canRenderVideo => false;

Future<RouteVideo> renderRouteVideo(RouteVideoSpec spec) =>
    Future.error(UnsupportedError('Video export needs the web app.'));

/// Shares text with the system share sheet where there is one.
Future<ShareOutcome> shareText(String title, String text) async =>
    ShareOutcome.unsupported;
