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

import { UploadItem } from '../components/UploadItem';
import { FileItem } from '../model/FileItem';
import { common } from '@kit.AbilityKit';

@Component
export struct UploadView {
  private context = AppStorage.get('context') as common.UIAbilityContext;
  private filesDir = this.context.filesDir;
  @State ordinaryList: Array<FileItem> = [new FileItem(0, '中国.mp4', this.filesDir + '/中国.mp4'),
    new FileItem(1, '外国历史.mp4', this.filesDir + '/外国历史.mp4')];
  @State chunkList: Array<FileItem> = [new FileItem(2, '流行音乐.mp4', this.filesDir + '/流行音乐.mp4'),
    new FileItem(3, '影视剧.mp4', this.filesDir + '/影视剧.mp4')];
  @State @Watch('onUploadingListSizeChanged') uploadingList: Set<number> = new Set();
  @Link isAllUpload: boolean;

  /**
   * 根据uploadingList的大小触发对应逻辑：改变“全部上传/暂停”图标及当前上传状态
   */
  onUploadingListSizeChanged() {
    if (this.uploadingList.size == this.chunkList.length) {
      this.isAllUpload = true;
      AppStorage.setOrCreate('pauseAllUpload', false);
    }
    if (this.uploadingList.size == 0) {
      this.isAllUpload = false;
      AppStorage.setOrCreate('isUploadAll', false);
    }
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.regularUpload'))
          .fontSize(14)
          .fontColor(Color.Black)
          .opacity(0.6)
      }
      .width(328)
      .height(20)
      .justifyContent(FlexAlign.Start)

      Column() {
        ForEach(this.ordinaryList, (item: FileItem, _index: number) => {
          UploadItem({
            itemKey: item.fileKey,
            fileName: item.fileName,
            filePath: item.urlOrPath,
            uploadTaskList: this.ordinaryList,
            isChunk: false,
            uploadingList: this.uploadingList
          })
        }, (item: string, _index: number) => item);
      }
      .margin({ top: 8 })

      Row() {
        Text($r('app.string.chunkUpload'))
          .fontSize(14)
          .fontColor(Color.Black)
          .opacity(0.6)
      }
      .width(328)
      .height(20)
      .margin({ top: 212 - this.ordinaryList.length * 86 })
      .justifyContent(FlexAlign.Start)

      Column() {
        ForEach(this.chunkList, (item: FileItem, _index: number) => {
          UploadItem({
            itemKey: item.fileKey,
            fileName: item.fileName,
            filePath: item.urlOrPath,
            uploadTaskList: this.chunkList,
            isChunk: true,
            uploadingList: this.uploadingList
          })
        }, (item: string, _index: number) => item);
      }
      .margin({ top: 8 })
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Start)
  }
}