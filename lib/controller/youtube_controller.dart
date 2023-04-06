// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'package:namida/class/video.dart';
import 'package:namida/core/constants.dart';

class YoutubeController {
  static final YoutubeController inst = YoutubeController();

  final currentYoutubeMetadata = Rxn<YTLVideo>();
  final currentSearchList = Rxn<VideoSearchList>();
  final comments = Rxn<NamidaCommentsList>();
  final _commentlistclient = Rxn<CommentsList>();
  final RxList<Channel> commentsChannels = <Channel>[].obs;
  final RxList<Channel> searchChannels = <Channel>[].obs;

  Future<void> prepareHomePage() async {
    final ytexp = YoutubeExplode(YoutubeHttpClient(NamidaClient()));
    currentSearchList.value = await ytexp.search.search('');

    /// Channels in search
    final search = currentSearchList.value;
    if (search == null) {
      return;
    }
    for (final ch in search) {
      searchChannels.add(await ytexp.channels.get(ch.channelId));
    }
    ytexp.close();
  }

  Future<void> updateCurrentVideoMetadata(String id, {bool forceReload = false}) async {
    currentYoutubeMetadata.value = null;
    currentYoutubeMetadata.value = await loadYoutubeVideoMetadata(id, forceReload: forceReload);

    if (currentYoutubeMetadata.value != null) {
      await updateCurrentComments(currentYoutubeMetadata.value!.video, forceReload: forceReload);
    }
  }

  Future<YTLVideo?> loadYoutubeVideoMetadata(String id, {bool forceReload = false}) async {
    if (id == '') {
      return null;
    }
    final videometafile = File('$k_DIR_YT_METADATA$id.txt');
    YTLVideo? vid;
    if (!forceReload && await videometafile.exists()) {
      String contents = await videometafile.readAsString();
      if (contents.isNotEmpty) {
        currentYoutubeMetadata.value = YTLVideo.fromJson(jsonDecode(contents));
        vid = YTLVideo.fromJson(jsonDecode(contents));
      }
    } else {
      final ytexp = YoutubeExplode(YoutubeHttpClient(NamidaClient()));
      final video = await ytexp.videos.get(id);
      final channel = await ytexp.channels.get(video.channelId);
      final ytlvideo = YTLVideo(video, channel);
      currentYoutubeMetadata.value = ytlvideo;
      final file = await videometafile.create();
      await file.writeAsString(json.encode(ytlvideo.toJson()));
      vid = ytlvideo;
      ytexp.close();
    }
    return vid;
  }

  Future<void> updateCurrentComments(Video video, {bool forceReload = false, bool loadNext = false}) async {
    final ytexp = YoutubeExplode(YoutubeHttpClient(NamidaClient()));
    if (!loadNext) {
      comments.value = null;
    }
    final videocommentfile = File('$k_DIR_YT_METADATA_COMMENTS${video.id}.txt');

    NamidaCommentsList? newcomm;
    final finalcomm = _commentlistclient.value?.map((p0) => p0).toList() ?? <Comment>[];

    /// Comments from cache
    if (!forceReload && await videocommentfile.exists()) {
      String contents = await videocommentfile.readAsString();
      if (contents.isNotEmpty) {
        newcomm = NamidaCommentsList.fromJson(Map<String, dynamic>.from(jsonDecode(contents)));
      }
    }

    /// comments from youtube
    else {
      if (loadNext) {
        final more = await _commentlistclient.value?.nextPage() ?? <Comment>[];
        finalcomm.addAll(more);
      } else {
        _commentlistclient.value = await ytexp.videos.commentsClient.getComments(video);
        finalcomm.assignAll(_commentlistclient.value?.map((p0) => p0) ?? []);
      }

      if (_commentlistclient.value != null) {
        newcomm = NamidaCommentsList(finalcomm, _commentlistclient.value?.totalLength ?? 0);
        final file = await videocommentfile.create();
        await file.writeAsString(json.encode(newcomm.toJson()));
      }
    }
    if (newcomm != null) {
      comments.value = newcomm;

      /// Comments Channels
      for (final ch in comments.value!.comments) {
        commentsChannels.add(await ytexp.channels.get(ch.channelId));
      }
    }
    ytexp.close();
  }
}

class NamidaClient extends http.BaseClient {
  final String? cookie;
  NamidaClient({this.cookie});

  final _client = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (cookie != null) {
      request.headers.addAll({'Cookie': cookie!});
    }
    printInfo(info: 'NamidaClient: $request');
    return _client.send(request);
  }

  @override
  void close() => _client.close();
}

// YSC; PREF; VISITOR_INFO; SID; HSID; SSID; APISID; SAPISID; LOGIN_INFO