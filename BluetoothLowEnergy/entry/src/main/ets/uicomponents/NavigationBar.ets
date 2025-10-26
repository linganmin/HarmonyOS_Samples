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

import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { Logger } from '../utils/Logger';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');

const context: Context = uiContext?.getHostContext()!;

export interface Action {
  id: string;
  event: (event?: ClickEvent) => void;
}

@Component
export default struct NavigationBar {
  @Consume('NavPathStack') pathStack: NavPathStack;
  private title?: ResourceStr;
  private showIndicator?: boolean;
  private darkMode?: boolean;
  private actions?: Array<Action>;
  private windowClass = (context as common.UIAbilityContext).windowStage.getMainWindowSync();

  setOrientation(orientation: number) {
    this.windowClass.setPreferredOrientation(orientation).then(() => {
      Logger.info('setWindowOrientation Succeeded');
    }).catch((err: BusinessError) => {
      Logger.error(`setWindowOrientation Failed. Cause:${JSON.stringify(err)}`);
    })
  }

  build() {
    Row() {
      if (this.showIndicator) {
        Row() {
          Image($r('app.media.chevron_left'))
            .objectFit(ImageFit.Contain)
            .width(28)
            .aspectRatio(1)
        }
        .id('iv_back')
        .backgroundColor(Color.White)
        .borderRadius(40)
        .margin({ left: 16, right: 8 })
        .width(40)
        .height(40)
        .aspectRatio(1)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.setOrientation(window.Orientation.PORTRAIT);
          this.pathStack.pop();
        })
      }

      Text(this.title ?? '')
        .fontColor(this.darkMode ? '#FFFFFF' : '#E6000000')
        .fontSize(16)
        .margin({ left: this.showIndicator ? 0 : 16 })

      Blank()
        .layoutWeight(1)

      ForEach(this.actions, (item: Action) => {
        Row() {
          Image($r('app.media.link_slash'))
            .objectFit(ImageFit.Contain)
            .width(24)
            .aspectRatio(1)
        }
        .id('iv_link_slash')
        .backgroundColor(Color.White)
        .borderRadius(40)
        .margin({ right: 8 })
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .onClick(item.event)
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#00000000')
  }
}