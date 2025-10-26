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
import { componentSnapshot, promptAction, window } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit'
import CommonConstants from '../constants/CommonContants';
import { hilog } from '@kit.PerformanceAnalysisKit';

function getTimeStr(): string {
  const now: Date = new Date();
  const year: number = now.getFullYear();
  const month: number = now.getMonth() + 1;
  const day: number = now.getDate();
  const hours: number = now.getHours();
  const minutes: number = now.getMinutes();
  const seconds: number = now.getSeconds();
  return `${year}${month}${day}_${hours}${minutes}${seconds}`;
}

@Component
export struct SavePages {
  @State filePath: string = '';
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State nodeCount: number = 0;
  @State pixelMap: image.PixelMap | undefined = undefined;

  async aboutToAppear(): Promise<void> {
    try {
      let windowHeight: window.Window = await window.getLastWindow(this.getUIContext().getHostContext()!);
      await windowHeight.setPreferredOrientation(window.Orientation.UNSPECIFIED);
      await windowHeight.setWindowLayoutFullScreen(false);
      await windowHeight.setSpecificSystemBarEnabled('status', true);

      this.getUIContext()
        .getComponentSnapshot()
        .get(CommonConstants.NODE_CONTAINER_ID, async (error: Error, pixelMap: image.PixelMap) => {
          this.pixelMap = pixelMap;
        })
      const nodeCountArr = this.pageInfos.getParamByName('SavePages') as Array<number>;
      this.nodeCount = nodeCountArr[0];
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag', `init fail. code = ${err.code}, message = ${err.message}`);
    }
  }

  async aboutToDisappear(): Promise<void> {
    try {
      let windowHeight: window.Window = await window.getLastWindow(this.getUIContext().getHostContext()!);
      await windowHeight.setPreferredOrientation(window.Orientation.LANDSCAPE);
      await windowHeight.setWindowLayoutFullScreen(true);
      await windowHeight.setSpecificSystemBarEnabled('status', false);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag', `set windowHeight fail. code = ${err.code}, message = ${err.message}`);
    }
  }

  build() {
    NavDestination() {
      Column() {
        Image(this.pixelMap)
          .width(CommonConstants.FULL_SCREEN)

        Blank()

        Column() {
          Button($r('app.string.hand_writing_pack_to_file'), { buttonStyle: ButtonStyleMode.EMPHASIZED })
            .onClick(async () => {
              if (this.pixelMap != null) {
                this.filePath = await this.packToFile(this.getUIContext().getHostContext()!, this.pixelMap);
                const strMsg: string =
                  this.getUIContext()
                    .getHostContext()!.resourceManager.getStringSync($r('app.string.hand_writing_image_save_path').id) +
                  this.filePath;
                this.getUIContext().getPromptAction().showToast({
                  message: strMsg,
                  duration: CommonConstants.TOAST_DURATION
                });
              }
            })
            .height($r('app.integer.button_height'))
            .width(CommonConstants.FULL_SCREEN)
            .enabled(this.nodeCount > 0 ? true : false)
          Button($r('app.string.hand_writing_packing'), { buttonStyle: ButtonStyleMode.EMPHASIZED })
            .onClick(async () => {
              if (this.pixelMap != null) {
                this.filePath = await this.saveFile(this.getUIContext().getHostContext()!, this.pixelMap);
                const strMsg: string =
                  this.getUIContext()
                    .getHostContext()!.resourceManager.getStringSync($r('app.string.hand_writing_image_save_path').id) +
                  this.filePath;
                this.getUIContext().getPromptAction().showToast({
                  message: strMsg,
                  duration: CommonConstants.TOAST_DURATION
                });
              }
            })
            .height($r('app.integer.button_height'))
            .width(CommonConstants.FULL_SCREEN)
            .margin({ top: $r('app.integer.button_margin_top') })
            .enabled(this.nodeCount > 0 ? true : false)
        }
        .width(CommonConstants.FULL_SCREEN)

      }
      .width(CommonConstants.FULL_SCREEN)
      .height(CommonConstants.FULL_SCREEN)
      .padding({
        left: $r('app.integer.padding_24'),
        right: $r('app.integer.padding_24'),
        bottom: $r('app.integer.padding_16')
      })
    }
  }

  async packToFile(context: Context, pixelMap: PixelMap): Promise<string> {
    const imagePackerApi = image.createImagePacker();
    const options: image.PackingOption = { format: 'image/jpeg', quality: CommonConstants.IMAGE_QUALITY };
    const filePath: string = `${context.filesDir}/${getTimeStr()}.jpg`;

    try {
      const file: fileIo.File = await fileIo.open(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
      await imagePackerApi.packToFile(pixelMap, file.fd, options);
      fileIo.closeSync(file);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag', `packToFile fail. code = ${err.code}, message = ${err.message}`);
    }

    return filePath;
  }

  async saveFile(context: Context, pixelMap: PixelMap): Promise<string> {
    const imagePackerApi = image.createImagePacker();
    const options: image.PackingOption = { format: 'image/jpeg', quality: CommonConstants.IMAGE_QUALITY };
    const filePath: string = `${context.filesDir}/${getTimeStr()}.jpg`;

    try {
      const file: fileIo.File = await fileIo.open(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      const data: ArrayBuffer = await imagePackerApi.packToData(pixelMap, options);
      fileIo.writeSync(file.fd, data);
      fileIo.closeSync(file);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag', `file write fail. code = ${err.code}, message = ${err.message}`);
    }

    return filePath;
  }
}