/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import CameraService from '../mode/CameraService';
import Logger from '../common/utils/Logger';
import { ModeComponent } from '../views/ModeComponent';
import { GlobalContext } from '../common/utils/GlobalContext';
import { Constants } from '../common/Constants';
import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'PhotoPage';

@Entry
@Component
struct PhotoPage {
  @StorageLink('isShow') isShow: boolean = false;
  @StorageLink('isOpenEditPage') isOpenEditPage: boolean = false;
  @State xComponentAspectRatio: number = 1;
  private mXComponentController: XComponentController = new XComponentController();
  private defaultCameraDeviceIndex = 0;
  private surfaceId = '';
  private aiController: ImageAnalyzerController = new ImageAnalyzerController();
  private options: ImageAIOptions = {
    types: [ImageAnalyzerType.SUBJECT, ImageAnalyzerType.TEXT],
    aiController: this.aiController
  }
  private windowClass: window.Window | undefined = undefined;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear(): void {
    Logger.info(TAG, 'aboutToAppear');
  }

  async aboutToDisAppear(): Promise<void> {
    Logger.info(TAG, 'aboutToDisAppear');
  }

  async onPageShow(): Promise<void> {
    Logger.info(TAG, 'onPageShow');
    try {
      this.windowClass = this.context.windowStage.getMainWindowSync();
      let SystemBarProperties: window.SystemBarProperties = {
        statusBarContentColor: '#ffffff',
      };
      this.windowClass.setWindowSystemBarProperties(SystemBarProperties)
        .then(() => {
          Logger.info('setWindowSystemBarProperties success');
        })
        .catch((err: BusinessError) => {
          Logger.error(`setWindowSystemBarProperties failed, code=${err.code}, message=${err.message}`)
        })
    } catch (exception) {
      console.error(`Failed to obtain the window. Cause code: ${exception.code}, message: ${exception.message}`);
    }
    this.isOpenEditPage = false;
    if (this.surfaceId !== '' && !this.isOpenEditPage) {
      await CameraService.initCamera(this.surfaceId, GlobalContext.get().getT<number>('cameraDeviceIndex'));
    }
  }

  async onPageHide(): Promise<void> {
    Logger.info(TAG, 'onPageHide');
    if (!this.windowClass) {
      return;
    }
    let SystemBarProperties: window.SystemBarProperties = {
      statusBarContentColor: '#000000',
    };
    this.windowClass.setWindowSystemBarProperties(SystemBarProperties)
      .then(() => {
        Logger.info('setWindowSystemBarProperties success');
      })
      .catch((err: BusinessError) => {
        Logger.error(`setWindowSystemBarProperties failed, code=${err.code}, message=${err.message}`)
      })
    await CameraService.releaseCamera();
  }

  build() {
    Column() {
      if (this.isShow) {
        // [Start single_segment_photography]
        XComponent({
          type: XComponentType.SURFACE,
          controller: this.mXComponentController,
          imageAIOptions: this.options
        })
          .onLoad(async () => {
            Logger.info(TAG, 'onLoad is called');
            this.surfaceId = this.mXComponentController.getXComponentSurfaceId();
            GlobalContext.get().setObject('cameraDeviceIndex', this.defaultCameraDeviceIndex);
            GlobalContext.get().setObject('xComponentSurfaceId', this.surfaceId);
            Logger.info(TAG, `onLoad surfaceId: ${this.surfaceId}`);
            await CameraService.initCamera(this.surfaceId, this.defaultCameraDeviceIndex);
          })
          .border({
            width: {
              top: Constants.X_COMPONENT_BORDER_WIDTH,
              bottom: Constants.X_COMPONENT_BORDER_WIDTH
            },
            color: Color.Black
          })
          .width('100%')
          .height(523)
          .margin({ top: 75, bottom: 72 })
        // [End single_segment_photography]
      }
      // Take picture
      ModeComponent()
    }
    .size({
      width: Constants.FULL_PERCENT,
      height: Constants.FULL_PERCENT
    })
    .backgroundColor(Color.Black)
  }
}
