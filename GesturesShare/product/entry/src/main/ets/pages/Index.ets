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

import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BreakpointConstants } from '@ohos/common';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { FileData, IMAGE_DATA, FILE_SOURCES } from '@ohos/share';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  @StorageLink('GesturesShare_pageInfos') pageInfos: NavPathStack = new NavPathStack();
  @StorageLink(BreakpointConstants.BREAKPOINT_NAME) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink('GesturesShare_isShareLink') isShareLink: boolean = false;
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private dataList: FileData[] = FILE_SOURCES;

  aboutToAppear(): void {
    this.handleFileInit();
  }

  // [Start jumpLinkSharePage]
  onPageShow(): void {
    if (this.isShareLink) {
      this.pageInfos.pushPathByName('LinkSharePage', null, true);
    }
  }
  // [Start jumpLinkSharePage]

  build() {
    Navigation(this.pageInfos) {
      Column({ space: 12 }) {
        Button($r('app.string.gestures_share_file'))
          .width('100%')
          .constraintSize({
            maxWidth: 448
          })
          .onClick(async () => {
            this.pageInfos.pushPathByName('FileSharePage', null, true);
          })

        Button($r('app.string.gestures_share_link'))
          .width('100%')
          .constraintSize({
            maxWidth: 448
          })
          .onClick(async () => {
            this.pageInfos.pushPathByName('LinkSharePage', null, true);
          })
      }
      .justifyContent(FlexAlign.End)
      .width('100%')
      .height('100%')
      .padding({
        left: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? 32 : 24,
        right: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? 32 : 24,
        bottom: 16,
      })
    }
    .title($r('app.string.index_title'))
    .mode(NavigationMode.Stack)
    .backgroundColor($r('sys.color.container_modal_unfocus_background'))
  }

  /**
   * Initialize operations to process files.
   */
  handleFileInit() {
    let filesDir = this.context.filesDir;
    try {
      let fileList = fileIo.listFileSync(filesDir);
      for (let index = 0; index < fileList.length; index++) {
        const fileName = fileList[index];
        fileIo.unlinkSync(filesDir + '/' + fileName);
      }
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'GesturesShare', `listFileSync unlinkSync error. ${error.code} ${error.message}`);
    }
    for (const item of this.dataList) {
      let file: fileIo.File | undefined = undefined;
      try {
        let url = this.context.filesDir + '/' + item.url;
        file = fileIo.openSync(url, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
        let writeLen =
          fileIo.writeSync(file.fd, (this.context.resourceManager.getRawFileContentSync(item.url) as Uint8Array).buffer);
        hilog.info(0x0000, 'GesturesShare', `write data to file succeed and size is : ${writeLen}`);
        item.url = fileUri.getUriFromPath(url);
      } catch (err) {
        let error = err as BusinessError;
        hilog.error(0x0000, 'GesturesShare', `Failed to save file. ${error.code} ${error.message}`);
      } finally {
        fileIo.close(file).catch((error: BusinessError) => {
          hilog.error(0x0000, 'GesturesShare', `Failed to close file. ${error.code} ${error.message}`);
        });
      }
      try {
        let url = this.context.filesDir + '/' + item.thumbnail;
        file = fileIo.openSync(url, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
        let writeLen = fileIo.writeSync(file.fd,
          (this.context.resourceManager.getMediaContentSync(IMAGE_DATA[item.index].id) as Uint8Array).buffer);
        hilog.info(0x0000, 'GesturesShare', `write data to file success and size is : ${writeLen}`);
        item.thumbnail = fileUri.getUriFromPath(url);
      } catch (err) {
        let error = err as BusinessError;
        hilog.error(0x0000, 'GesturesShare', `Failed to save image. ${error.code} ${error.message}`);
      } finally {
        fileIo.close(file).catch((error: BusinessError) => {
          hilog.error(0x0000, 'GesturesShare', `Failed to close file. ${error.code} ${error.message}`);
        });
      }
    }
  }
}