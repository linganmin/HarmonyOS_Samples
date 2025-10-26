/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { notificationManager } from '@kit.NotificationKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Styles
function itemStyle() {
  .width('100%')
  .height(56)
  .padding({
    top: 17,
    bottom: 17,
    left: 12,
    right: 12
  })
  .backgroundColor(Color.White)
  .borderRadius(24)
  .margin({ top: 12 })
}

@Extend(Text)
function textStyle() {
  .fontColor($r('app.color.text_normal'))
  .fontWeight(400)
  .fontFamily('HarmonyHeiTi')
  .fontSize(16)
}

@Entry
@Component
struct Index {
  @StorageLink('isBackground') isBackground: boolean = false;

  aboutToAppear() {
    try {
      notificationManager.requestEnableNotification(this.getUIContext().getHostContext() as common.UIAbilityContext);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'Index', `requestEnableNotification failed, error code=${err.code}, message=${err.message}`);
    }
  }

  build() {
    Navigation() {
      Scroll() {
        Column() {
          Row() {
            Text($r('app.string.background_tips'))
              .textStyle()
            Blank()
            Toggle({ type: ToggleType.Switch, isOn: this.isBackground })
              .height(24)
              .onChange((isOn: boolean) => {
                this.isBackground = isOn;
                AppStorage.setOrCreate('isBackground', isOn);
              })
          }
          .itemStyle()
          .margin({ top: 0 })

          this.CapabilityView($r('app.media.ic_upload'), $r('app.string.upload'), 'btn_upload', () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/Upload' });
          })
          this.CapabilityView($r('app.media.ic_download'), $r('app.string.download'), 'btn_download', () => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/Download' });
          })
        }
        .width('100%')
      }
      .padding({ left: 12, right: 12 })
      .height('100%')
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .hideBackButton(true)
    .titleMode(NavigationTitleMode.Mini)
    .backgroundColor($r('app.color.light_gray'))
    .title({
      main: this.getResourceString($r('app.string.EntryAbility_label')),
      sub: this.getResourceString($r('app.string.home_tips'))
    })
  }

  @Builder
  CapabilityView(image: Resource, text: Resource, id: string, onClick: () => void) {
    Row() {
      Image(image)
        .size({ width: 24, height: 24 })
        .objectFit(ImageFit.Cover)
      Text(text)
        .textStyle()
        .margin({ left: 12 })
    }
    .itemStyle()
    .id(id)
    .onClick(onClick)
  }

  getResourceString(resource: Resource) {
    let result = '';
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    try {
      result = context.resourceManager.getStringSync(resource.id);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'Index', `getStringSync failed, error code=${err.code}, message=${err.message}`);
    }
    return result;
  }
}