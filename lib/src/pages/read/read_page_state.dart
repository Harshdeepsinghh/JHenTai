import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:jhentai/src/model/gallery_image.dart';
import 'package:jhentai/src/model/gallery_thumbnail.dart';
import 'package:jhentai/src/widget/loading_state_indicator.dart';

class ReadPageState {
  late int initialIndex;
  late int pageCount;

  late String galleryUrl;
  late List<GalleryThumbnail?> thumbnails;
  late LoadingState thumbnailsParsingState = LoadingState.idle;
  late List<GalleryImage?> images;
  late List<LoadingState?> imageParsingStates;

  FlutterListViewController listViewController = FlutterListViewController();

  ReadPageState() {
    listViewController.sliverController.onPaintItemPositionsCallback =
        (double widgetHeight, List<FlutterListViewItemPosition> positions) {};
  }
}