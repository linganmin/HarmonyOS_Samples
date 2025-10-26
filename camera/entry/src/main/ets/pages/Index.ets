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

import { camera } from '@kit.CameraKit';
import CameraService from '../mode/CameraService';
import Logger from '../common/utils/Logger';
import { ModeComponent } from '../views/ModeComponent';
import { SlideComponent } from '../views/SlideComponent';
import { GlobalContext } from '../common/utils/GlobalContext';
import { Constants } from '../common/Constants';
import { FocusAreaComponent } from '../views/FocusAreaComponent';
import { FocusComponent } from '../views/FocusComponent';
import { FlashingLightComponent } from '../views/FlashingLightComponent';

const TAG = 'Index';

@Entry
@Component
struct Index {
  // Is the main page displayed.
  @StorageLink('isShow') isShow: boolean = false;
  @StorageLink('isOpenEditPage') isOpenEditPage: boolean = false;
  @StorageLink('cameraIndex') cameraIndex: number = 0;
  // Flash Mode
  @State flashMode: camera.FlashMode = camera.FlashMode.FLASH_MODE_CLOSE;
  @State focusPointBol: boolean = false;
  // Finger click coordinates in the exposure area.
  @State focusPointVal: Array<number> = [0, 0];
  @State xComponentAspectRatio: number = 1;
  private mXComponentController: XComponentController = new XComponentController();
  private defaultCameraDeviceIndex = 0;
  private surfaceId = '';

  aboutToAppear(): void {
    Logger.info(TAG, 'aboutToAppear');
  }

  async aboutToDisAppear(): Promise<void> {
    Logger.info(TAG, 'aboutToDisAppear');
    this.flashMode = camera.FlashMode.FLASH_MODE_CLOSE;
    await CameraService.releaseCamera();
  }

  async onPageShow(): Promise<void> {
    Logger.info(TAG, 'onPageShow');
    if (this.surfaceId !== '' && !this.isOpenEditPage) {
      await CameraService.initCamera(this.surfaceId, GlobalContext.get().getT<number>('cameraDeviceIndex'));
    }
    this.isOpenEditPage = false;
  }

  async onPageHide(): Promise<void> {
    Logger.info(TAG, 'onPageHide');
    this.flashMode = camera.FlashMode.FLASH_MODE_CLOSE;
    CameraService.hasFlashFn(this.flashMode);
  }

  build() {
    Stack() {
      if (this.isShow) {
        XComponent({
          id: 'componentId',
          type: XComponentType.SURFACE,
          controller: this.mXComponentController
        })
          .onLoad(async () => {
            Logger.info(TAG, 'onLoad is called');
            this.surfaceId = this.mXComponentController.getXComponentSurfaceId();
            GlobalContext.get().setObject('cameraDeviceIndex', this.defaultCameraDeviceIndex);
            GlobalContext.get().setObject('xComponentSurfaceId', this.surfaceId);
            let surfaceRect: SurfaceRect = {
              surfaceWidth: Constants.X_COMPONENT_SURFACE_HEIGHT,
              surfaceHeight: Constants.X_COMPONENT_SURFACE_WIDTH
            };
            this.mXComponentController.setXComponentSurfaceRect(surfaceRect);
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
          // The width and height of the surface are opposite to those of the XComponent.
          .width(this.getUIContext().px2vp(Constants.X_COMPONENT_SURFACE_HEIGHT))
          .height(this.getUIContext().px2vp(Constants.X_COMPONENT_SURFACE_WIDTH))
      }
      // Exposure frame and focus frame.
      FocusComponent({
        focusPointBol: $focusPointBol,
        focusPointVal: $focusPointVal
      })

      // Exposure focus finger click area.
      FocusAreaComponent({
        focusPointBol: $focusPointBol,
        focusPointVal: $focusPointVal,
        xComponentWidth: this.getUIContext().px2vp(Constants.X_COMPONENT_SURFACE_HEIGHT),
        xComponentHeight: this.getUIContext().px2vp(Constants.X_COMPONENT_SURFACE_WIDTH)
      })
      // slide
      SlideComponent()

      // photograph
      ModeComponent({
        flashMode: $flashMode
      })

      Row({ space: Constants.ROW_SPACE_24 }) {
        FlashingLightComponent({
          flashMode: $flashMode
        })
      }
      .margin({ left: Constants.CAPTURE_BUTTON_COLUMN_MARGIN })
      .alignItems(VerticalAlign.Top)
      .justifyContent(FlexAlign.Start)
      .position({
        x: Constants.FLASH_POSITION_X,
        y: Constants.FLASH_POSITION_Y
      })
      .visibility(this.cameraIndex === 0 ? Visibility.Visible : Visibility.Hidden)
    }
    .size({
      width: Constants.FULL_PERCENT,
      height: Constants.FULL_PERCENT
    })
    .backgroundColor(Color.Black)
  }
}