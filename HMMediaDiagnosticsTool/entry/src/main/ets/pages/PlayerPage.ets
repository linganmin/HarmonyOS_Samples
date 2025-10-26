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

import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { Header } from '../components/Header';

@HMRouter({ pageUrl: 'PlayerPage', singleton: true })
@Component
export struct PlayerPage {
  private readonly description: ResourceStr = $r('app.string.detection_description');
  private selection: boolean = true;

  build() {
    Column() {
      Column() {
        Header({ description: this.description })
          .margin({ bottom: 30 });

        Text($r('app.string.select_app'))
          .width('100%')
          .height(24)
          .margin({ bottom: 10 })
          .fontSize(14)
          .fontColor($r('app.color.text'))
          .opacity(0.6)
          .lineHeight(24)
          .textAlign(TextAlign.Start);

        Row() {
          Toggle({ type: ToggleType.Checkbox, isOn: true })
            .onChange((isOn: boolean) => {
              this.selection = isOn;
            });
          Text($r('app.string.audio_app'))
            .margin({ left: 10 })
            .fontSize(14)
            .fontColor($r('app.color.text'))
            .opacity(0.6);
        }
        .width('100%')
        .height(48)
        .padding({
          left: 8,
          right: 8
        })
        .justifyContent(FlexAlign.Start);
      }
      .padding({ bottom: 10 });

      Column() {
        Button($r('app.string.common_next'), { type: ButtonType.Capsule, stateEffect: false })
          .width('100%')
          .onClick(() => {
            if (!this.selection) {
              this.getUIContext().getPromptAction().showToast({ message: $r('app.string.common_select') });
              return;
            }
            HMRouterMgr.push({
              pageUrl: 'SceneHome'
            });
          });
      };
    }
    .width('100%')
    .height('100%')
    .padding({
      left: 16,
      right: 16,
      bottom: 16
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('app.color.page_background'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}