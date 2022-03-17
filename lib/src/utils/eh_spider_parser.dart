import 'dart:collection';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:jhentai/src/consts/color_consts.dart';
import 'package:jhentai/src/model/gallery_comment.dart';
import 'package:jhentai/src/model/gallery_details.dart';
import 'package:jhentai/src/model/gallery_image.dart';
import 'package:jhentai/src/model/gallery_thumbnail.dart';

import '../model/gallery.dart';

class EHSpiderParser {
  static List<String?>? parseUserInfo(String html) {
    Document document = parse(html);

    /// cookie is wrong, not logged in
    if (document.querySelector('.pcen') != null) {
      return null;
    }

    String userName = document.querySelector('.home > b > a')!.text;
    String? avatarUrl = document.querySelector('#profilename + br + div > img')?.attributes['src'];
    return [userName, avatarUrl];
  }

  static List<dynamic> parseHomeGallerysList(String html) {
    Document document = parse(html);
    List<Element> galleryListElements = document.querySelectorAll('.itg.gltc > tbody > tr');

    /// remove table header
    galleryListElements.removeAt(0);

    /// remove ad
    galleryListElements.removeWhere((element) => element.querySelector('.itd') != null);
    List<Gallery> gallerys = galleryListElements.map((e) => _parseHomeGallery(e)).toList();

    int pageCount = _parseSearchTotalPageCount(document);
    return [gallerys, pageCount];
  }

  static Map<String, dynamic> parseGalleryDetails(String html) {
    Document document = parse(html);
    List<Element> commentElements = document.querySelectorAll('#cdiv > .c1');
    List<Element> thumbNailElements = document.querySelectorAll('#gdt > .gdtm');

    GalleryDetails galleryDetails = GalleryDetails(
      ratingCount: int.parse(document.querySelector('#rating_count')?.text ?? '0'),
      realRating: _parseGalleryDetailsRealRating(document),
      size: document.querySelector('#gdd > table > tbody')?.children[4].children[1].text ?? '',
      favoriteCount: _parseGalleryDetailsFavoriteCount(document),
      torrentCount: RegExp(r'\d+')
              .firstMatch(document.querySelector('#gd5')?.children[2].querySelector('a')?.text ?? '')
              ?.group(0) ??
          '0',
      torrentPageUrl:
          document.querySelector('#gd5')?.children[2].querySelector('a')?.attributes['onclick']?.split('\'')[1] ?? '',
      comments: _parseGalleryDetailsComments(commentElements),
      thumbnails: _parseGalleryDetailsThumbnails(thumbNailElements),
    );

    return {'galleryDetails': galleryDetails, 'apikey': _parseApikey(document)};
  }

  static List<GalleryThumbnail> parseGalleryDetailsThumbnails(String html) {
    Document document = parse(html);
    List<Element> thumbNailElements = document.querySelectorAll('#gdt > .gdtm');
    return _parseGalleryDetailsThumbnails(thumbNailElements);
  }

  static List<String> parseFavoritePopup(String html) {
    Document document = parse(html);
    List<Element> divs = document.querySelectorAll('.nosel > div');
    return divs.map((div) => div.querySelector('div:nth-child(5)')?.text ?? '').toList();
  }

  static LinkedHashMap<String, int> parseFavoriteTags(String html) {
    Document document = parse(html);
    List<Element> divs = document.querySelectorAll('.nosel > .fp');

    /// not favorite tag
    divs.removeLast();
    LinkedHashMap<String, int> tagNames2Count = LinkedHashMap();

    for (Element div in divs) {
      String tagName = div.querySelector('div:last-child')?.text ?? '';
      int favoriteCount = int.parse(div.querySelector('div:first-child')?.text ?? '0');
      tagNames2Count.putIfAbsent(tagName, () => favoriteCount);
    }

    return tagNames2Count;
  }

  static GalleryImage parseGalleryImage(String html) {
    Document document = parse(html);
    Element img = document.querySelector('#img')!;

    /// height: 1600px; width: 1124px;
    String style = img.attributes['style']!;

    return GalleryImage(
      url: img.attributes['src']!,
      height: double.parse(RegExp(r'height:(\d+)px').firstMatch(style)!.group(1)!),
      width: double.parse(RegExp(r'width:(\d+)px').firstMatch(style)!.group(1)!),
    );
  }

  static int _parseSearchTotalPageCount(Document document) {
    Element? tr = document.querySelector('.ptt > tbody > tr');
    Element? td = tr?.children[tr.children.length - 2];
    return int.parse(td?.querySelector('a')?.text ?? '0');
  }

  static Gallery _parseHomeGallery(Element tr) {
    LinkedHashMap<String, List<String>> tags = _parseHomeGalleryTags(tr);
    GalleryImage? cover = _parseHomeGalleryCover(tr);
    String galleryUrl = tr.querySelector('.gl3c.glname > a')?.attributes['href'] ?? '';
    List<String>? parts = galleryUrl.split('/');

    Gallery gallery = Gallery(
      gid: int.parse(parts[4]),
      token: parts[5],
      title: tr.querySelector('.glink')?.text ?? '',
      category: tr.querySelector('.cn')?.text ?? '',
      cover: cover!,
      pageCount: _parseHomeGalleryPageCount(tr),
      rating: _parseHomeGalleryRating(tr),
      hasRated: tr.querySelector('.gl2c > div:nth-child(2) > .ir.irb') != null ? true : false,
      isFavorite: tr.querySelector('.gl2c > div:nth-child(2) > [id][style]') != null ? true : false,
      favoriteTagIndex: _parseFavoriteTagIndex(tr),
      favoriteTagName: tr.querySelector('.gl2c > div:nth-child(2) > [id][style]')?.attributes['title'],
      galleryUrl: galleryUrl,
      tags: tags,
      language: tags['language']?[0],
      uploader: tr.querySelector('.gl4c.glhide > div > a')?.text ?? '',
      publishTime: tr.querySelector('.gl2c > div:nth-child(2) > [id]')?.text ?? '',
    );

    return gallery;
  }

  static LinkedHashMap<String, List<String>> _parseHomeGalleryTags(Element tr) {
    LinkedHashMap<String, List<String>> tags = LinkedHashMap();

    List<Element> tagDivs = tr.querySelectorAll('.gt').toList();
    for (Element tagDiv in tagDivs) {
      /// eg: language:english
      String pair = tagDiv.attributes['title'] ?? '';
      if (pair.isEmpty) {
        continue;
      }

      /// some tag doesn't has a type
      List<String> list = pair.split(':').toList();
      String type = list[0].isNotEmpty ? list[0] : 'temp';
      String text = list[1];

      tags.putIfAbsent(type, () => []).add(text);
    }
    return tags;
  }

  static GalleryImage? _parseHomeGalleryCover(Element tr) {
    Element? img = tr.querySelector('.gl2c > .glthumb > div > img');
    if (img == null) {
      return null;
    }
    String coverUrl = img.attributes['data-src'] ?? img.attributes['src'] ?? '';

    /// eg: height:296px;width:250px
    String? style = img.attributes['style'];
    if (style == null) {
      return null;
    }
    RegExp sizeReg = RegExp(r'(\d+)');
    List<RegExpMatch> sizes = sizeReg.allMatches(style).toList();

    String? height = sizes[0].group(0);
    String? width = sizes[1].group(0);
    if (height == null || width == null) {
      return null;
    }
    return GalleryImage(
      url: coverUrl,
      height: double.parse(height),
      width: double.parse(width),
    );
  }

  static int _parseHomeGalleryPageCount(Element tr) {
    List<Element> divs = tr.querySelectorAll('.gl4c.glhide > div');

    /// eg: '66 pages'
    String pageCountDesc = divs[1].text;
    return int.parse(pageCountDesc.split(' ')[0]);
  }

  static double _parseHomeGalleryRating(Element tr) {
    /// eg: style="background-position:-16px -1px;opacity:1"
    String style = tr.querySelector('.ir')?.attributes['style'] ?? '';
    if (style.isEmpty) {
      return 0;
    }

    RegExp offsetsReg = RegExp(r'-*(\d+)+px');
    List<RegExpMatch> offsets = offsetsReg.allMatches(style).toList();

    /// eg: '0px'  '-16px'  '-32px'
    String? xOffset = offsets[0].group(0);

    /// eg: '-1px'  '-21px'
    String? yOffset = offsets[1].group(0);

    if (xOffset == null || yOffset == null) {
      return 0;
    }

    int xOffsetInt = int.parse(xOffset.replaceAll('px', ''));
    int yOffsetInt = int.parse(yOffset.replaceAll('px', ''));

    double initValue = 5;
    initValue -= -xOffsetInt / 16;
    initValue -= yOffsetInt == -21 ? 0.5 : 0;

    return initValue;
  }

  static int? _parseFavoriteTagIndex(Element tr) {
    String? style = tr.querySelector('.gl2c > div:nth-child(2) > [id][style]')?.attributes['style'];
    if (style == null) {
      return null;
    }
    final String color = RegExp(r'border-color:#(\w{3});').firstMatch(style)?.group(1) ?? '';
    return ColorConsts.favoriteTagIndex[color]!;
  }

  static double _parseGalleryDetailsRealRating(Document document) {
    /// eg: 'Average: 4.76' 'Not Yet Rated'
    String raw = document.querySelector('#rating_label')?.text ?? '';
    return double.parse(RegExp(r'Average: (\d+.\d+\d+)').firstMatch(raw)?.group(1) ?? '0');
  }

  static int _parseGalleryDetailsFavoriteCount(Document document) {
    String? count = document.querySelector('#favcount')?.text;
    if (count == null || count == 'Never') {
      return 0;
    } else if (count == 'Once') {
      return 1;
    } else {
      return int.parse(count.split(' ')[0]);
    }
  }

  static List<GalleryComment> _parseGalleryDetailsComments(List<Element> commentElements) {
    return commentElements.map((element) {
      /// eg: 'Posted on 10 March 2022, 03:49 by: hibiki'
      String timeDesc = element.querySelector('.c2 > .c3')?.text ?? '';

      /// eg: '10 March 2022, 03:49'
      String timeString = RegExp(r'Posted on (.+, .+) by:').firstMatch(timeDesc)?.group(1) ?? '';
      final DateTime utcTime = DateFormat('dd MMMM yyyy, HH:mm', 'en_US').parseUtc(timeString).toLocal();
      final String localTime = DateFormat('yyyy-MM-dd HH:mm').format(utcTime);

      return GalleryComment(
        userName: element.querySelector('.c2 > .c3')?.children[0].text ?? '',
        score: element.querySelector('.c2 > .c5.nosel > span')?.text ?? '',
        content: element.querySelector('.c6')?.text ?? '',
        time: localTime,
      );
    }).toList();
  }

  static List<GalleryThumbnail> _parseGalleryDetailsThumbnails(List<Element> thumbNailElements) {
    return thumbNailElements.map((element) {
      String href = element.querySelector('div > a')?.attributes['href'] ?? '';
      String style = element.querySelector('div')?.attributes['style'] ?? '';

      return GalleryThumbnail(
        href: href,
        thumbUrl: RegExp(r'url\((.+)\)').firstMatch(style)?.group(1) ?? '',
        isLarge: false,
        thumbWidth: double.parse(RegExp(r'width:(\d+)?px').firstMatch(style)?.group(1) ?? '0'),
        thumbHeight: double.parse(RegExp(r'height:(\d+)?px').firstMatch(style)?.group(1) ?? '0') - 1,
        offSet: double.parse(RegExp(r'\) -(\d+)?px ').firstMatch(style)?.group(1) ?? '0'),
      );
    }).toList();
  }

  static String _parseApikey(Document document) {
    String script = document.querySelector('.gm')?.previousElementSibling?.text ?? '';
    return RegExp(r'var apikey = "(\w+)"').firstMatch(script)?.group(1) ?? '';
  }
}