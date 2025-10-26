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

import player from 'libplayer.so';
import { resourceManager } from '@kit.LocalizationKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Builder
export function XComponentBuilder() {
  XComponentPlayer();
}

@Component
struct XComponentPlayer {
  pathStack: NavPathStack = new NavPathStack();
  aboutToDisappear(): void {
    player.stopNative();
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Row() {
            XComponent({
              id: 'XComponent',
              type: XComponentType.SURFACE,
              libraryname: 'player'
            })
              .height(200)
              .width('100%')
          }
        }
        .width('100%')

        Blank()
        Column() {
          Button($r('app.string.play'))
            .onClick(() => {
              this.getUIContext().getHostContext()?.resourceManager.getRawFd('sample.mp4',
                (error: BusinessError, value: resourceManager.RawFileDescriptor) => {
                  if (error != null) {
                    return;
                  }
                  player.playNative(value.fd, value.offset, value.length, 'XComponent');
                });
            })
            .size({
              width: '100%',
            })
        }
        .padding({ left: 16, right: 16, bottom: 16 })
        .width('100%')
        .justifyContent(FlexAlign.End)
      }
      .height('100%')
      .width('100%')
    }
    .title($r('app.string.xcomponent_title'))
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }
}