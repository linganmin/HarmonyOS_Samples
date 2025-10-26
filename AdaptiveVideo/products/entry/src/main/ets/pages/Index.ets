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
 *
 */
import { Home } from 'adaptive_video_component';
import { deviceInfo } from '@kit.BasicServicesKit';
import { CommonConstants } from 'base';
import { window } from '@kit.ArkUI';

@Extend(Button)
function buttonStyles() {
  .width('100%')
  .constraintSize({ maxWidth: 448 })
  .type(deviceInfo.deviceType === '2in1' ? ButtonType.Normal : ButtonType.Capsule)
  .borderRadius(8)
  .backgroundColor($r('app.color.button_background'))
}

@Entry
@Component
struct Index {
  @Provide('pathStack') pathStack: NavPathStack = new NavPathStack();
  @StorageProp(CommonConstants.NAVIGATION_INDICATOR_HEIGHT) bottomRectHeight: number = 0;
  windowStage: window.WindowStage = AppStorage.get(CommonConstants.WINDOW_STAGE) as window.WindowStage;

  @Builder
  PagesMap(name: string) {
    if (name == 'Home') {
      Home()
    }
  }

  build() {
    Navigation(this.pathStack) {
      Column({ space: 12 }) {
        Button($r('app.string.index_btn_adaptive_immersion_rotation'))
          .buttonStyles()
          .onClick(() => {
            this.pathStack.pushPathByName('Home', 0);
          })
        Button($r('app.string.index_btn_high_level_media_components'))
          .buttonStyles()
          .onClick(() => {
            this.pathStack.pushPathByName('Home', 1);
          })
      }
      .padding({ left: 20, right: 20, bottom: 16 + this.bottomRectHeight })
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.End)
    }
    .mode(NavigationMode.Stack)
    .hideToolBar(true)
    .hideTitleBar(true)
    .hideBackButton(true)
    .width('100%')
    .height('100%')
    .navDestination(this.PagesMap)
    .backgroundColor($r('app.color.index_background'))
  }
}