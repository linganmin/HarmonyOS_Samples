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

import { AVPlayerController } from '../controller/AVPlayerController';
import { ImageUtil } from '../utils/ImageUtil';
import { common } from '@kit.AbilityKit';
import { deferredLink } from '@kit.AppLinkingKit';
import { Logger } from '../utils/Logger';
import { url } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'Index';

// [Start deferred_link]
@Entry
@Component
struct Index {
  // [StartExclude deferred_link]
  @StorageLink('avPlayerController') avPlayerController?: AVPlayerController = undefined;
  // [EndExclude deferred_link]
  aboutToAppear(): void {
    // [StartExclude deferred_link]
    const context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
    ImageUtil.saveImage(context);
    // [EndExclude deferred_link]
    //Get the deferred link parameter and go to video play page
    deferredLink.popDeferredLink()
      .then((link: string) => {
        Logger.info(TAG, `Succeeded in getting deferred link, result: ${link}`);
        const videoIndex = url.URL.parseURL(link)?.params?.get('videoIndex') as string;
        if (videoIndex) {
          this.getUIContext().getRouter().pushUrl({
            url: 'pages/VideoPlay',
            params: { videoIndex }
          });
        }
      }).catch((error: BusinessError) => {
        Logger.error(TAG, `Failed to get deferred link. code: ${error.code}, message: ${error.message}`);
      });
  }
  // [StartExclude deferred_link]
  build() {
    Column() {
      Row() {
        Text($r('app.string.title'))
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
      }
      .height(112)
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        bottom: 8
      })
      .alignItems(VerticalAlign.Bottom)

      Column() {
        Row() {
          Image($r('app.media.video_cover_0'))
            .height('100%')
            .width(156)
            .borderRadius(10)
          Column() {
            Text($r('app.string.local_video'))
              .fontColor($r('sys.color.font_primary'))
              .fontSize(14)
              .margin({
                bottom: 2
              })
            Text($r('app.string.local_video_describe'))
              .fontColor($r('sys.color.font_primary'))
              .fontSize(12)
          }
          .height('100%')
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Start)
          .layoutWeight(1)
          .padding({ left: 8 })
        }
        .onClick(() => {
          this.getUIContext().getRouter().pushUrl({
            url: 'pages/VideoPlay'
          });
        })
        .width('100%')
        .height(88)
        .margin({
          bottom: 12,
          top: 12
        })
      }
      .alignItems(HorizontalAlign.Start)
      .padding({
        left: 16,
        right: 16,
      })
      .width('100%')
      .layoutWeight(1)
      .backgroundColor($r('sys.color.background_primary'))
    }
  }
  // [EndExclude deferred_link]
}
// [End deferred_link]