/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { request } from '@kit.BasicServicesKit';
import {
  ItemRestriction,
  SegmentButton,
  SegmentButtonOptions,
  SegmentButtonTextItem
} from '@kit.ArkUI';
import { FileDownloadItem } from '../view/FileDownloadItem';
import { Constants } from '../constants/Constants';

const NO_TASK: number = 0;

// [Start config]
function downloadConfig(downloadUrl: string): request.agent.Config {
  const config: request.agent.Config = {
    action: request.agent.Action.DOWNLOAD,
    url: downloadUrl,
    overwrite: true,
    method: 'GET',
    saveas: './',
    mode: request.agent.Mode.BACKGROUND,
    gauge: true,
    retry: false
  };
  return config;
}
// [End config]

@Entry
@Component
struct MultipleFilesDownload {
  /**
   * enter the download urls
   */
  private downloadUrlArray: string[] = [];
  @State downloadConfigArray: request.agent.Config[] = [];
  @State isStartAllDownload: boolean = false;
  @State downloadCount: number = 0;
  @State downloadFailCount: number = 0;
  @State tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: $r('app.string.multiple_files_download_file_upload') },
      { text: $r('app.string.multiple_files_download_list') }, {
        text: $r('app.string.multiple_files_download_album_backup')
      }] as ItemRestriction<SegmentButtonTextItem>,
    backgroundBlurStyle: BlurStyle.BACKGROUND_THICK,
    selectedFontSize: $r('sys.float.ohos_id_text_size_body2'),
    selectedFontColor: $r('sys.color.ohos_id_color_text_primary'),
    selectedBackgroundColor: $r('sys.color.ohos_id_color_foreground_contrary'),
    fontSize: $r('sys.float.ohos_id_text_size_body2'),
    fontColor: $r('sys.color.ohos_id_color_text_secondary'),
    backgroundColor: $r('sys.color.ohos_id_color_button_normal'),
    textPadding: {
      top: $r('app.integer.tab_padding'),
      right: $r('app.integer.tab_padding'),
      bottom: $r('app.integer.tab_padding'),
      left: $r('app.integer.tab_padding'),
    }
  });
  @State @Watch('onSelectedChange') tabSelectedIndexes: number[] = [1];
  @State downloadPageOpacity: number = 1;
  @State isDownloadPageEnabled: boolean = true;

  onSelectedChange(): void {
    if (this.tabSelectedIndexes[0] === 1) {
      this.downloadPageOpacity = 1;
      this.isDownloadPageEnabled = true;
    } else {
      this.downloadPageOpacity = 0;
      this.isDownloadPageEnabled = false;
    }
  }

  aboutToAppear(): void {
    for (let i = 0; i < this.downloadUrlArray.length; i++) {
      const config: request.agent.Config = downloadConfig(this.downloadUrlArray[i]);
      this.downloadConfigArray.push(config);
    }
    this.downloadCount = this.downloadUrlArray.length;
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.multiple_files_download_transfer_list'))
          .fontWeight(FontWeight.Bold)
          .fontSize($r('app.integer.title_font_size'))
          .width(Constants.FULL_WIDTH)
          .fontColor($r('app.color.text_color'))
      }
      .alignItems(VerticalAlign.Bottom)
      .width(Constants.INDEX_CONTENT_WIDTH)
      .height(Constants.INDEX_TITLE_HEIGHT)

      Row() {
        SegmentButton({ options: this.tabOptions, selectedIndexes: $tabSelectedIndexes })
      }
      .height($r('app.integer.segment_height'))
      .margin({
        left: Constants.MARGIN_SIXTEEN,
        right: Constants.MARGIN_SIXTEEN,
        top: $r('app.integer.segment_margin_top')
      })

      Row() {
        Row() {
          Text($r('app.string.multiple_files_download_queue'))
            .fontSize($r('app.integer.multiple_files_download_text_font_size_fourteen'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        }.width($r('app.string.multiple_files_download_row_width'))

        Row() {
          Text(this.isStartAllDownload && this.downloadCount > NO_TASK ? $r('app.string.pause_all') :
          $r('app.string.start_all'))
            .fontSize($r('app.integer.multiple_files_download_text_font_size_fourteen'))
            .fontWeight(Constants.FONT_500)
            .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
            .textAlign(TextAlign.End)
            .width($r('app.string.multiple_files_download_row_text_width'))
            .onClick(() => {
              if (this.downloadCount === NO_TASK) {
                this.getUIContext().showAlertDialog({
                  message: $r('app.string.multiple_files_download_completed'),
                  alignment: DialogAlignment.Center
                });
                return;
              }
              this.isStartAllDownload = !this.isStartAllDownload;
            })
        }.width($r('app.string.multiple_files_download_row_width'))
      }
      .opacity(this.downloadPageOpacity)
      .enabled(this.isDownloadPageEnabled)
      .margin({
        left: Constants.MARGIN_SIXTEEN,
        right: Constants.MARGIN_SIXTEEN,
        top: $r('app.integer.multiple_files_download_margin_top_twenty_eight'),
        bottom: $r('app.integer.margin_eight')
      })

      List() {
        // [Start forEach]
        ForEach(this.downloadConfigArray, (item: request.agent.Config) => {
          ListItem() {
            FileDownloadItem({
              downloadConfig: item,
              isStartAllDownload: this.isStartAllDownload,
              downloadCount: this.downloadCount,
              downloadFailCount: this.downloadFailCount
            })
          }
        }, (item: request.agent.Config) => JSON.stringify(item))
        // [End forEach]
      }
      .opacity(this.downloadPageOpacity)
      .enabled(this.isDownloadPageEnabled)
      .width(Constants.FULL_WIDTH)
      .height(Constants.FULL_HEIGHT)
    }
    .focusable(false)
  }
}

@Builder
export function getMultipleFilesDownload(): void {
  MultipleFilesDownload();
}
