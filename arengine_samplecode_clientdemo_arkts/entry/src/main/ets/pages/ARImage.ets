/*
 * Copyright (c) 2024-2025 Huawei Device Co., Ltd.
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
import { Logger } from '../utils/Logger';

@Builder
export function ARImageBuilder(): void {
  ARImage();
}

@Component
struct ARImage {
  pageInfos: NavPathStack = new NavPathStack();

  build(): void {
    NavDestination() {
      Column() {
        Button($r('app.string.choose_local_image'), { type: ButtonType.Normal, stateEffect: true })
          .borderRadius(8)
          .width('50%')
          .height('5%')
          .onClick(() => {
            this.chooseImageToTrack();
          })

        Button($r('app.string.load_local_database'), { type: ButtonType.Normal, stateEffect: true })
          .borderRadius(8)
          .width('50%')
          .height('5%')
          .onClick(() => {
            this.loadDatabaseToTrack();
          })
      }
      .justifyContent(FlexAlign.SpaceEvenly)
      .width('100%')
      .height('100%')
    }
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
    .hideTitleBar(true)
    .hideBackButton(true)
    .hideToolBar(true)
  }

  private chooseImageToTrack(): void {
    try {
      let photoOption: photoAccessHelper.PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoOption.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoOption.maxSelectNumber = 50; // Default
      photoOption.isEditSupported = false;
      let photoPicker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker();

      photoPicker.select(photoOption).then((photoResult) => {
        if (photoResult.photoUris.length > 0 && photoResult.photoUris[0].length > 0) {
          this.pageInfos.pushDestinationByName('ARImageByAdd', photoResult.photoUris);
        }
      })
    } catch (error) {
      Logger.error(`Failed to select by photoPicker. Code: ${error.code}.`);
    }
  }

  private loadDatabaseToTrack(): void {
    this.pageInfos.pushDestinationByName('ARImageByDatabase', null);
  }
}
