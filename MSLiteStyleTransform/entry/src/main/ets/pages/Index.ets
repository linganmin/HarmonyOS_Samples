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


import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import NavigationParam from '../model/NavigationParam';
import Logger from '../utils/Logger';

@Entry
@Component
struct Index {
  pathStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.pathStack) {
      RelativeContainer() {
        Button($r('app.string.home_btn_text'))
          .id('id_home_btn')
          .alignRules({
            left: { anchor: '__container__', align: HorizontalAlign.Start},
            right: { anchor: '__container__', align: HorizontalAlign.End},
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom},
          })
          .margin({ bottom: 16, left: 16, right: 16})
          .onClick(() => {
            // 1. Create Image-Video Type File Selection Option Instance
            let photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();

            // 2. Filter and select media file type as IMAGE
            photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
            photoSelectOptions.maxSelectNumber = 1;// Maximum number of media files to select

            // 3. Create an instance of the gallery selector and call the select() interface to launch the gallery interface for file selection. upon successful file selection. return the photoSelectResult result ret.
            let photoPicker = new photoAccessHelper.PhotoViewPicker();
            photoPicker.select(photoSelectOptions, async (err: BusinessError, photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
              if (err) {
                Logger.error('MS_LITE_ERR, photoViewPicker.select failed with err:' + JSON.stringify(err));
                return;
              }
              Logger.info('MS_LITE_LOG: PhotoViewPicker.select successfully, ' + `photoSelectResult uri + ${JSON.stringify(photoSelectResult.photoUris)}`);
              let param = new NavigationParam(photoSelectResult.photoUris[0]);
              if (param && param.photoUri.length > 0) {
                this.pathStack.pushPath({ name: 'Result', param});
              }
            });
          })
      }
      .id('id_home_navigation')
      .height('100%')
      .width('100%')
    }
    .title({ builder: this.titleBuilder, height: 112})
    .mode(NavigationMode.Stack)
    .backgroundColor($r('app.color.window_background'))
  }

  @Builder
  titleBuilder() {
    Column() {
      Text($r('app.string.home_navbar_title'))
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .lineHeight(40)
        .fontColor('rgba(0,0,0,0.9)')
        .margin({
          left: 16,
          right: 16,
          top: 64,
          bottom: 8
        })
    }
    .height(112)
  }
}