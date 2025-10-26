/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 0x0000;

@Builder
export function PhotoViewPickerBuild() {
  PhotoViewPicker();
}

@Component
export struct PhotoViewPicker {
  @Consume('pageInfo') pageStack: NavPathStack;
  // Selected images
  @State selectUris: Array<string> = new Array<string>();
  // The currently selected image
  @State currentUri: string = '';

  aboutToAppear() {
    try {
      let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      PhotoSelectOptions.isEditSupported = false;
      PhotoSelectOptions.subWindowName = '111';
      PhotoSelectOptions.maxSelectNumber = 1;
      let photoPicker = new photoAccessHelper.PhotoViewPicker();
      photoPicker.select(PhotoSelectOptions).then((PhotoSelectResult: photoAccessHelper.PhotoSelectResult) => {
        if (PhotoSelectResult.photoUris.length > 0) {
          this.selectUris.push(PhotoSelectResult.photoUris[0]);
          this.currentUri = PhotoSelectResult.photoUris[0];
          if (this.selectUris.length > 0) {
            this.pageStack.replacePath({ name: 'Preview', param: this.selectUris[0] });
          }
        } else {
          this.pageStack.clear();
        }
      }).catch((err: BusinessError) => {
        hilog.error(TAG, 'PhotoViewPicker', `PhotoViewPicker.select failed with err: ${err.code}, ${err.message}`);
      });
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      hilog.error(TAG, 'PhotoViewPicker', `PhotoViewPicker failed with err: ${err.code}, ${err.message}`);
    }
  }

  build() {
    NavDestination() {
    }.title($r('app.string.select_picture'))
  }
}