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

import { router } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import CameraService from '../mode/CameraService';
import Logger from '../common/utils/Logger';
import { GlobalContext } from '../common/utils/GlobalContext';
import { Constants } from '../common/Constants';
import { image } from '@kit.ImageKit';

const TAG: string = 'ModeComponent';

@Component
export struct ModeComponent {
  @StorageLink('isOpenEditPage') @Watch('changePageState') isOpenEditPage: boolean = false;
  @State isRecording: boolean = false;
  @State isClick: boolean = false;

  changePageState(): void {
    if (this.isOpenEditPage) {
      this.onJumpClick();
    }
  }

  aboutToAppear(): void {
    Logger.info(TAG, 'aboutToAppear');
    CameraService.setSavePictureCallback(this.handleSavePicture);
  }

  // [Start handle_save_picture]
  handleSavePicture = (photoAsset: photoAccessHelper.PhotoAsset | image.PixelMap): void => {
    Logger.info(TAG, 'handleSavePicture');
    this.setImageInfo(photoAsset);
    AppStorage.set<boolean>('isOpenEditPage', true);
    Logger.info(TAG, 'setImageInfo end');
  }

  setImageInfo(photoAsset: photoAccessHelper.PhotoAsset | image.PixelMap): void {
    Logger.info(TAG, 'setImageInfo');
    GlobalContext.get().setObject('photoAsset', photoAsset);
  }
  // [End handle_save_picture]

  onJumpClick(): void {
    this.getUIContext().getRouter().pushUrl({ url: 'pages/EditPage' }, router.RouterMode.Single, (err) => {
      if (err) {
        Logger.error(TAG, `Invoke pushUrl failed, code is ${err.code}, message is ${err.message}`);
        return;
      }
      this.isClick = false
      Logger.info(TAG, 'Invoke pushUrl succeeded.');
    });
  }

  build() {
    Column() {
      Column() {
        Row() {}
        .width(54)
        .height(54)
        .backgroundColor(this.isClick ? 'rgb(232, 64, 38)' : 'rgb(255, 255, 255)')
        .borderRadius(27)
        .onClick(async () => {
          this.isClick = true;
          await CameraService.takePicture();
        })
      }
      .width(80)
      .height(80)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .border({
        width: 1,
        color: Color.White,
        radius: 40
      })
    }
    .width(Constants.FULL_PERCENT)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .height(Constants.TEN_PERCENT)
    .padding({
      left: Constants.CAPTURE_BUTTON_COLUMN_PADDING,
      right: Constants.CAPTURE_BUTTON_COLUMN_PADDING
    })
  }
}