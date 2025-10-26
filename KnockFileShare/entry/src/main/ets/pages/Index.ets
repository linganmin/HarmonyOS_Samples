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
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import { filePreview } from '@kit.PreviewKit';
import { BreakpointConstants } from '../constants/BreakpointConstants';
import { FileData, IMAGE_DATA, VIDEO_SOURCES } from '../model/FileData'
import { KnockController } from '../controller/KnockController';
import { BreakpointType } from '../utils/BreakpointSystem';
import { FileUtil } from '../utils/FileUtil';

@Entry
@Component
struct Index {
  @StorageLink('KnockFileShare_videoDataList') dataList: FileData[] = VIDEO_SOURCES;
  @StorageLink('KnockFileShare_fileShare') fileShare: number[] = [];
  @StorageLink(BreakpointConstants.BREAKPOINT_NAME) currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @State isEdit: boolean = true;
  private knockController: KnockController | undefined = undefined;
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear(): void {
    this.handleFileInit();

    this.knockController = KnockController.getInstance(this.context);
    if (deviceInfo.deviceType === '2in1') {
      this.knockController.immersiveListeningPC();
      this.knockController.dataReceiveListeningPC();
    } else {
      this.knockController.immersiveListening();
    }
  }

  aboutToDisappear(): void {
    if (deviceInfo.deviceType === '2in1') {
      this.knockController?.immersiveDisableListeningPC();
      this.knockController?.dataReceiveDisableListeningPC();
    } else {
      this.knockController?.immersiveDisableListening();
    }
  }

  build() {
    Navigation() {
      List({ space: 16 }) {
        ForEach(this.dataList, (item: FileData, index: number) => {
          ListItem() {
            Stack() {
              Column() {
                Image(item.thumbnail)
                  .width('100%')
                  .aspectRatio(1)
                  .borderRadius(10)
                  .onClick(() => {
                    let uiContext = this.getUIContext().getHostContext();
                    let displayInfo: filePreview.DisplayInfo = {
                      x: 100,
                      y: 100,
                      width: 800,
                      height: 800
                    };
                    let fileInfo: filePreview.PreviewInfo = {
                      title: item.name,
                      uri: item.url,
                      mimeType: FileUtil.getMimeTypeFromPath((item.url))
                    };
                    filePreview.openPreview(uiContext, fileInfo, displayInfo, (err) => {
                      if (err && err.code) {
                        hilog.error(0x0000, 'KnockFileShare', `Failed to open preview. ${JSON.stringify(err)}`);
                        return;
                      }
                      hilog.info(0x0000, 'KnockFileShare', 'Success in opening preview');
                    });
                  })
              }
              Column() {
                Checkbox({ name: index + '', group: 'checkboxGroup'})
                  .select(false)
                  .selectedColor('#0A59F7')
                  .unselectedColor(Color.White)
                  .shape(CheckBoxShape.CIRCLE)
                  .margin({
                    right: 10
                  })
                  .onChange((value: boolean) => {
                    if (value) {
                      this.fileShare.push(index);
                    } else {
                      this.fileShare.splice(this.fileShare.indexOf(index), 1);
                    }
                  })
              }
              .layoutWeight(1)
            }
            .alignContent(Alignment.BottomEnd)
          }
        }, (item: FileData, index: number) => index + JSON.stringify(item))
      }
      .lanes(new BreakpointType({
        sm: 2,
        md: 4,
        lg: 6
      }).getValue(this.currentBreakpoint), 8)
      .margin({
        left: new BreakpointType({
          sm: 16,
          md: 24,
          lg: 32
        }).getValue(this.currentBreakpoint),
        right: new BreakpointType({
          sm: 16,
          md: 24,
          lg: 32
        }).getValue(this.currentBreakpoint)
      })
    }
    .title($r('app.string.app_title'))
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
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
    } catch (e) {
      hilog.error(0x0000, 'KnockFileShare', `unlinkSync error ${JSON.stringify(e)}`);
    }
    for (const item of this.dataList) {
      let file: fileIo.File | undefined = undefined;
      try {
        let url = this.context.filesDir + '/' + item.url;
        file = fileIo.openSync(url, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
        let writeLen =
          fileIo.writeSync(file.fd, (this.context.resourceManager.getRawFileContentSync(item.url) as Uint8Array).buffer);
        hilog.info(0x0000, 'KnockFileShare', `write data to file succeed and size is : ${writeLen}`);
        item.url = fileUri.getUriFromPath(url);
      } catch (err) {
        hilog.error(0x0000, 'KnockFileShare', `Failed to save image. ${JSON.stringify(err)}`);
      } finally {
        try {
          fileIo.close(file);
        } catch (e) {
          hilog.error(0x0000, 'KnockFileShare', `close error ${JSON.stringify(e)}`);
        }
      }
      try {
        let url = this.context.filesDir + '/' + item.thumbnail;
        file = fileIo.openSync(url, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
        let writeLen = fileIo.writeSync(file.fd,
          (this.context.resourceManager.getMediaContentSync(IMAGE_DATA[item.index].id) as Uint8Array).buffer);
        hilog.info(0x0000, 'KnockFileShare', `write data to file success and size is : ${writeLen}`);
        item.thumbnail = fileUri.getUriFromPath(url);
      } catch (err) {
        hilog.error(0x0000, 'KnockFileShare', `Failed to save image. ${JSON.stringify(err)}`);
      } finally {
        try {
          fileIo.close(file);
        } catch (e) {
          hilog.error(0x0000, 'KnockFileShare', `close error ${JSON.stringify(e)}`);
        }
      }
    }
  }
}