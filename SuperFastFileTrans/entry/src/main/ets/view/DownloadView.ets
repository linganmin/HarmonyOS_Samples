/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { CONSTANTS_CONFIG } from '../common/ConstantsConfig';
import { DownloadItem } from '../components/DownloadItem';
import { FileItem } from '../model/FileItem';

@Component
export struct DownloadView {
  @State regularList: Array<FileItem> =
    [new FileItem(0, '中国.mp4', CONSTANTS_CONFIG.urls.ordinaryDownloadUrlExampleOne, 1),
      new FileItem(1, '外国历史.mp4', CONSTANTS_CONFIG.urls.ordinaryDownloadUrlExampleTwo, 1)];
  @State multiList: Array<FileItem> =
    [new FileItem(2, '流行音乐.mp4', CONSTANTS_CONFIG.urls.multiDownloadUrlExampleOne, 4),
    new FileItem(3, '影视剧.mp4', CONSTANTS_CONFIG.urls.multiDownloadUrlExampleTwo, 4)];
  @State @Watch('onDownloadingListSizeChanged') downloadingList: Set<number> = new Set();
  @Link isAllDownload: boolean;

  /**
   * 根据downloadList的大小触发对应逻辑：改变“全部下载/暂停”图标及当前下载状态
   */
  onDownloadingListSizeChanged() {
    if (this.downloadingList.size == this.multiList.length) {
      this.isAllDownload = true;
      AppStorage.setOrCreate('isPauseAll', false);
    }
    if (this.downloadingList.size == 0) {
      this.isAllDownload = false;
      AppStorage.setOrCreate('isDownloadAll', false);
    }
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.regularDownload'))
          .fontSize(14)
          .fontColor(Color.Black)
          .opacity(0.6)
      }
      .width(328)
      .height(20)
      .justifyContent(FlexAlign.Start)

      Column() {
        ForEach(this.regularList, (item: FileItem, index: number) => {
          DownloadItem({
            itemKey: item.fileKey,
            fileName: item.fileName,
            url: item.urlOrPath,
            downloadTaskList: this.regularList,
            downloadingList: this.downloadingList
          })
        }, (item: string, index: number) => item);
      }
      .margin({ top: 8 })

      Row() {
        Text($r('app.string.multiDownload'))
          .fontSize(14)
          .fontColor(Color.Black)
          .opacity(0.6)
      }
      .width(328)
      .height(20)
      .margin({ top: 212 - this.regularList.length * 86 })
      .justifyContent(FlexAlign.Start)

      Column() {
        ForEach(this.multiList, (item: FileItem, index: number) => {
          DownloadItem({
            itemKey: item.fileKey,
            fileName: item.fileName,
            url: item.urlOrPath,
            isResumable: true,
            concurrency: item.concurrency,
            downloadTaskList: this.multiList,
            downloadingList: this.downloadingList
          })
        }, (item: string, index: number) => item);
      }
      .margin({ top: 8 })
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Start)
  }
}