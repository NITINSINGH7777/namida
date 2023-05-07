import 'dart:io';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import 'package:namida/controller/backup_controller.dart';
import 'package:namida/controller/json_to_history_parser.dart';
import 'package:namida/controller/settings_controller.dart';
import 'package:namida/core/constants.dart';
import 'package:namida/core/enums.dart';
import 'package:namida/core/extensions.dart';
import 'package:namida/core/icon_fonts/broken_icons.dart';
import 'package:namida/core/translations/strings.dart';
import 'package:namida/main.dart';
import 'package:namida/ui/widgets/custom_widgets.dart';
import 'package:namida/ui/widgets/circular_percentages.dart';
import 'package:namida/ui/widgets/settings/extra_settings.dart';
import 'package:namida/ui/widgets/settings_card.dart';

class BackupAndRestore extends StatelessWidget {
  const BackupAndRestore({super.key});
  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      title: Language.inst.BACKUP_AND_RESTORE,
      subtitle: Language.inst.BACKUP_AND_RESTORE_SUBTITLE,
      icon: Broken.refresh_circle,
      child: Column(
        children: [
          Obx(
            () => CustomListTile(
              title: Language.inst.CREATE_BACKUP,
              icon: Broken.box_add,
              trailing: BackupController.inst.isCreatingBackup.value ? const LoadingIndicator() : null,
              onTap: () {
                void onItemTap(String item) {
                  if (SettingsController.inst.backupItemslist.contains(item)) {
                    SettingsController.inst.removeFromList(backupItemslist1: item);
                  } else {
                    SettingsController.inst.save(backupItemslist: [item]);
                  }
                }

                bool isActive(String item) => SettingsController.inst.backupItemslist.contains(item);

                Get.dialog(
                  Obx(
                    () => CustomBlurryDialog(
                      title: Language.inst.CREATE_BACKUP,
                      actions: [
                        const CancelButton(),
                        ElevatedButton(
                          onPressed: () {
                            Get.close(1);
                            BackupController.inst.createBackupFile();
                          },
                          child: Text(Language.inst.CREATE_BACKUP),
                        ),
                      ],
                      child: SizedBox(
                        height: Get.height / 2,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ListTileWithCheckMark(
                                active: isActive(k_FILE_PATH_TRACKS),
                                title: Language.inst.DATABASE,
                                icon: Broken.box_1,
                                onTap: () => onItemTap(k_FILE_PATH_TRACKS),
                              ),
                              const SizedBox(
                                height: 12.0,
                              ),
                              ListTileWithCheckMark(
                                active: isActive(k_DIR_PLAYLISTS) && isActive(k_PLAYLIST_PATH_FAVOURITES),
                                title: Language.inst.PLAYLISTS,
                                icon: Broken.music_library_2,
                                onTap: () {
                                  onItemTap(k_DIR_PLAYLISTS);
                                  onItemTap(k_PLAYLIST_PATH_FAVOURITES);
                                },
                              ),
                              const SizedBox(
                                height: 12.0,
                              ),
                              ListTileWithCheckMark(
                                active: isActive(k_PLAYLIST_PATH_HISTORY),
                                title: Language.inst.HISTORY,
                                icon: Broken.refresh,
                                onTap: () => onItemTap(k_PLAYLIST_PATH_HISTORY),
                              ),
                              const SizedBox(
                                height: 12.0,
                              ),
                              ListTileWithCheckMark(
                                active: isActive(k_FILE_PATH_SETTINGS),
                                title: Language.inst.SETTINGS,
                                icon: Broken.setting,
                                onTap: () => onItemTap(k_FILE_PATH_SETTINGS),
                              ),
                              const SizedBox(
                                height: 12.0,
                              ),
                              ListTileWithCheckMark(
                                active: isActive(k_DIR_WAVEFORMS),
                                title: Language.inst.WAVEFORMS,
                                icon: Broken.sound,
                                onTap: () => onItemTap(k_DIR_WAVEFORMS),
                              ),
                              const SizedBox(
                                height: 12.0,
                              ),
                              ListTileWithCheckMark(
                                active: isActive(k_DIR_LYRICS),
                                title: Language.inst.LYRICS,
                                icon: Broken.document,
                                onTap: () => onItemTap(k_DIR_LYRICS),
                              ),
                              const SizedBox(
                                height: 12.0,
                              ),
                              ListTileWithCheckMark(
                                active: isActive(k_DIR_QUEUES) && isActive(k_FILE_PATH_LATEST_QUEUE),
                                title: Language.inst.QUEUES,
                                icon: Broken.driver,
                                onTap: () {
                                  onItemTap(k_DIR_QUEUES);
                                  onItemTap(k_FILE_PATH_LATEST_QUEUE);
                                },
                              ),
                              const SizedBox(
                                height: 12.0,
                              ),
                              ListTileWithCheckMark(
                                active: isActive(k_DIR_PALETTES),
                                title: Language.inst.COLOR_PALETTES,
                                icon: Broken.colorfilter,
                                onTap: () => onItemTap(k_DIR_PALETTES),
                              ),
                              const SizedBox(
                                height: 12.0,
                              ),
                              ListTileWithCheckMark(
                                active: isActive(k_DIR_VIDEOS_CACHE),
                                title: Language.inst.VIDEO_CACHE,
                                icon: Broken.video,
                                onTap: () => onItemTap(k_DIR_VIDEOS_CACHE),
                              ),
                              const SizedBox(
                                height: 12.0,
                              ),
                              ListTileWithCheckMark(
                                active: isActive(k_DIR_ARTWORKS),
                                title: Language.inst.ARTWORKS,
                                icon: Broken.image,
                                onTap: () => onItemTap(k_DIR_ARTWORKS),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Obx(
            () => CustomListTile(
              title: Language.inst.RESTORE_BACKUP,
              icon: Broken.back_square,
              trailing: BackupController.inst.isRestoringBackup.value ? const LoadingIndicator() : null,
              onTap: () async {
                await Get.dialog(
                  CustomBlurryDialog(
                    normalTitleStyle: true,
                    title: Language.inst.RESTORE_BACKUP,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          CustomListTile(
                            title: Language.inst.AUTOMATIC_BACKUP,
                            subtitle: Language.inst.AUTOMATIC_BACKUP_SUBTITLE,
                            icon: Broken.autobrightness,
                            maxSubtitleLines: 22,
                            onTap: () => BackupController.inst.restoreBackupOnTap(true),
                          ),
                          CustomListTile(
                            title: Language.inst.MANUAL_BACKUP,
                            subtitle: Language.inst.MANUAL_BACKUP_SUBTITLE,
                            maxSubtitleLines: 22,
                            icon: Broken.hashtag,
                            onTap: () => BackupController.inst.restoreBackupOnTap(false),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Obx(
            () => CustomListTile(
              title: Language.inst.DEFAULT_BACKUP_LOCATION,
              icon: Broken.direct_inbox,
              subtitle: SettingsController.inst.defaultBackupLocation.value,
              onTap: () async {
                final path = await FilePicker.platform.getDirectoryPath();

                /// resets SAF in case folder was changed
                if (path != SettingsController.inst.defaultBackupLocation.value) {
                  await resetSAFPermision();
                }
                if (path != null) {
                  SettingsController.inst.save(defaultBackupLocation: path);
                }
              },
            ),
          ),
          CustomListTile(
            title: Language.inst.IMPORT_YOUTUBE_HISTORY,
            leading: StackedIcon(
              baseIcon: Broken.import_2,
              // secondaryIcon: Broken.video_square,
              // secondaryIconColor: Colors.red.withAlpha(200),
              smallChild: ClipRRect(
                borderRadius: BorderRadius.circular(12.0.multipliedRadius),
                child: Image.asset(
                  'assets/icons/youtube.png',
                  width: 12,
                  height: 12,
                ),
              ),
            ),
            trailing: const SizedBox(
              height: 32.0,
              child: ParsingJsonPercentage(
                size: 32.0,
                source: TrackSource.youtube,
                forceDisplay: false,
              ),
            ),
            onTap: () => Get.dialog(
              CustomBlurryDialog(
                title: Language.inst.GUIDE,
                actions: [
                  ElevatedButton(
                    onPressed: () async {
                      Get.close(1);
                      final jsonfile = await FilePicker.platform.pickFiles(allowedExtensions: ['json'], type: FileType.custom);

                      if (jsonfile != null) {
                        final RxBool isMatchingTypeLink = true.obs;
                        final RxBool matchYT = true.obs;
                        final RxBool matchYTMusic = true.obs;
                        Get.dialog(
                          CustomBlurryDialog(
                            title: Language.inst.CONFIGURE,
                            actions: [
                              ElevatedButton(
                                onPressed: () async {
                                  Get.close(1);
                                  JsonToHistoryParser.inst.showParsingProgressDialog();
                                  await JsonToHistoryParser.inst.parseYTHistoryJson(File(jsonfile.files.first.path!));
                                  await JsonToHistoryParser.inst.addFileSourceToNamidaHistory(
                                    File(k_FILE_PATH_YOUTUBE_STATS),
                                    TrackSource.youtube,
                                    isMatchingTypeLink: isMatchingTypeLink.value,
                                    matchYT: matchYT.value,
                                    matchYTMusic: matchYTMusic.value,
                                  );
                                },
                                child: Text(Language.inst.CONFIRM),
                              )
                            ],
                            child: Obx(
                              () => Column(
                                children: [
                                  CustomListTile(
                                    title: Language.inst.SOURCE,
                                    largeTitle: true,
                                  ),
                                  ListTileWithCheckMark(
                                    active: matchYT.value,
                                    title: Language.inst.YOUTUBE,
                                    onTap: () => matchYT.value = !matchYT.value,
                                  ),
                                  const SizedBox(height: 12.0),
                                  ListTileWithCheckMark(
                                    active: matchYTMusic.value,
                                    title: Language.inst.YOUTUBE_MUSIC,
                                    onTap: () => matchYTMusic.value = !matchYTMusic.value,
                                  ),
                                  CustomListTile(
                                    title: Language.inst.MATCHING_TYPE,
                                    largeTitle: true,
                                  ),
                                  ListTileWithCheckMark(
                                    active: !isMatchingTypeLink.value,
                                    title: [Language.inst.TITLE, Language.inst.ARTIST].join(' & '),
                                    onTap: () => isMatchingTypeLink.value = !isMatchingTypeLink.value,
                                  ),
                                  const SizedBox(height: 12.0),
                                  ListTileWithCheckMark(
                                    active: isMatchingTypeLink.value,
                                    title: Language.inst.LINK,
                                    onTap: () => isMatchingTypeLink.value = !isMatchingTypeLink.value,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(Language.inst.CONFIRM),
                  ),
                ],
                child: NamidaSelectableAutoLinkText(
                  text: Language.inst.IMPORT_YOUTUBE_HISTORY_GUIDE.replaceFirst('_TAKEOUT_LINK_', 'https://takeout.google.com'),
                ),
              ),
            ),
          ),
          CustomListTile(
            title: Language.inst.IMPORT_LAST_FM_HISTORY,
            leading: StackedIcon(
              baseIcon: Broken.import_2,
              smallChild: ClipRRect(
                borderRadius: BorderRadius.circular(12.0.multipliedRadius),
                child: Image.asset(
                  'assets/icons/lastfm.png',
                  width: 12,
                  height: 12,
                ),
              ),
            ),
            trailing: const SizedBox(
              height: 32.0,
              child: ParsingJsonPercentage(
                size: 32.0,
                source: TrackSource.lastfm,
                forceDisplay: false,
              ),
            ),
            onTap: () => Get.dialog(
              CustomBlurryDialog(
                title: Language.inst.GUIDE,
                actions: [
                  ElevatedButton(
                    onPressed: () async {
                      Get.close(1);
                      final csvFiles = await FilePicker.platform.pickFiles(allowedExtensions: ['csv'], type: FileType.custom);
                      final csvFilePath = csvFiles?.files.first.path;
                      if (csvFiles != null && csvFilePath != null) {
                        JsonToHistoryParser.inst.showParsingProgressDialog();

                        await Future.delayed(const Duration(milliseconds: 300));
                        JsonToHistoryParser.inst.addFileSourceToNamidaHistory(File(csvFilePath), TrackSource.lastfm);
                      }
                    },
                    child: Text(Language.inst.CONFIRM),
                  ),
                ],
                child: NamidaSelectableAutoLinkText(
                  text: Language.inst.IMPORT_LAST_FM_HISTORY_GUIDE.replaceFirst('_LASTFM_CSV_LINK_', 'https://benjaminbenben.com/lastfm-to-csv/'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}