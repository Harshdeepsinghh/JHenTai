import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:jhentai/src/utils/toast_util.dart';

import '../../service/gallery_download_service.dart';
import '../layout/mobile_v2/notification/tap_menu_button_notification.dart';
import 'archive_download_body.dart';
import 'gallery_download_body.dart';

class DownloadPage extends StatefulWidget {
  final bool showMenuButton;

  const DownloadPage({Key? key, this.showMenuButton = false}) : super(key: key);

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  final GalleryDownloadService downloadService = Get.find();

  bool _showArchiveBody = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: _showArchiveBody ? Text('archive'.tr) : Text('download'.tr),
        elevation: 1,
        leadingWidth: 120,
        leading: ExcludeFocus(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showMenuButton)
                IconButton(
                  icon: const Icon(FontAwesomeIcons.bars, size: 20),
                  onPressed: () => TapMenuButtonNotification().dispatch(context),
                ),
              IconButton(onPressed: _showHelpInfo, icon: const Icon(Icons.help, size: 22)),
            ],
          ),
        ),
        actions: [
          if (!_showArchiveBody)
            ExcludeFocus(
              child: IconButton(
                onPressed: downloadService.resumeAllDownloadGallery,
                icon: Icon(Icons.play_arrow, size: 26, color: Get.theme.primaryColor),
              ),
            ),
          if (!_showArchiveBody)
            ExcludeFocus(
              child: IconButton(
                onPressed: downloadService.pauseAllDownloadGallery,
                icon: Icon(Icons.pause, size: 26, color: Get.theme.primaryColorLight),
              ),
            ),
          ExcludeFocus(
            child: IconButton(
              key: const Key('1'),
              onPressed: () => setState(() {
                _showArchiveBody = !_showArchiveBody;
              }),
              icon: _showArchiveBody ? const Icon(Icons.switch_left) : const Icon(Icons.switch_right),
            ),
          )
        ],
      ),
      body: _showArchiveBody
          ? FadeIn(
              key: const Key('1'),
              child: const ArchiveDownloadBody(
                key: PageStorageKey('ArchiveDownloadBody'),
              ),
            )
          : FadeIn(
              key: const Key('2'),
              child: const GalleryDownloadBody(
                key: PageStorageKey('GalleryDownloadBody'),
              ),
            ),
    );
  }

  void _showHelpInfo() {
    toast('downloadHelpInfo'.tr, isCenter: false, isShort: false);
  }
}
