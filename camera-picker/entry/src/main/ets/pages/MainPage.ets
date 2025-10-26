/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import { cameraPicker } from '@kit.CameraKit';
import { camera } from '@kit.CameraKit';
import { BusinessError } from '@ohos.base';
import { hilog } from '@kit.PerformanceAnalysisKit'
import { CommonConstants as Const } from '../common/constants/CommonConstants';

@Entry
@Component
struct ImagePickerPage {
  @State uri: Resource | string | undefined = undefined;
  private cameraPosition: Array<camera.CameraPosition> = [
    camera.CameraPosition.CAMERA_POSITION_UNSPECIFIED, camera.CameraPosition.CAMERA_POSITION_BACK,
    camera.CameraPosition.CAMERA_POSITION_FRONT
  ];
  private mediaType: Array<cameraPicker.PickerMediaType> = [
    cameraPicker.PickerMediaType.PHOTO, cameraPicker.PickerMediaType.VIDEO
  ];

  build() {
    Row() {
      Column() {
        Image(this.uri)
          .height($r('app.float.image_height'))
          .alt($r('app.media.startIcon'))

      Button($r('app.string.capture'))
        .width($r('app.float.button_width'))
        .margin({ top: $r('app.float.margin') })
        .onClick(async () => {
          try {
            // Configure to launch the rear camera
            let pickerProfile: cameraPicker.PickerProfile = { cameraPosition: this.cameraPosition[1] };
            // Configure to photo mode
            let pickerResult: cameraPicker.PickerResult = await cameraPicker.pick(this.getUIContext().getHostContext(),
              [this.mediaType[0]], pickerProfile);
            // Get video URI
            this.uri = pickerResult.resultUri;
            hilog.info(0x0000, ' ', "the pick pickerResult is:" + JSON.stringify(pickerResult));
          } catch (error) {
            let err = error as BusinessError;
            hilog.error(0x0000, '', `the pick call failed. error code: ${err.code}`);
          }
        })
      }
      .width(Const.FULL_SIZE)
    }
    .height(Const.FULL_SIZE)
  }
}