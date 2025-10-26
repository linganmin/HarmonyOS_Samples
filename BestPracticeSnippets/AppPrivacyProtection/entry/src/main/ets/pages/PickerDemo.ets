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

// [Start picker_demo]
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../utils/Logger';

@Entry
@Component
struct PickerDemo {
  @State imageUri: string = '';

  build() {
    RelativeContainer() {
      Image(this.imageUri)
      // [StartExclude picker_demo]
        .width('60%')
        .margin({ bottom: 12 })
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
      // [EndExclude picker_demo]
      Button($r('app.string.select_picture'))
      // [StartExclude picker_demo]
        .height(40)
        .width('100%')
        .margin({ bottom: 44 })
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Bottom },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        // [EndExclude picker_demo]
        .onClick(() => {
          const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
          photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
          photoSelectOptions.maxSelectNumber = 5;
          const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
          photoViewPicker.select(photoSelectOptions).then(photoSelectResult => {
            this.imageUri = photoSelectResult.photoUris[0];
            Logger.info(`PhotoViewPicker.select successfully, imageUri: ${this.imageUri}`)
          }).catch((err: BusinessError) => {
            Logger.error(`PhotoViewPicker.select failed with err: ${JSON.stringify(err)}`)
          })
        })
    }
    // [StartExclude picker_demo]
    .height('100%')
    .width('100%')
    .padding(16)
    // [EndExclude picker_demo]
  }
}
// [End picker_demo]