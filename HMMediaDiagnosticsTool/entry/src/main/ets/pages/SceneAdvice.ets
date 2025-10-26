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
import { DataConfig } from '../common/store/DataInterface';

@HMRouter({ pageUrl: 'SceneAdvice', singleton: true })
@Preview
@Component
export struct SceneAdvice {
  @StorageLink('configSource') configSource: Array<DataConfig> | undefined = AppStorage.get('configSource')!;
  private sceneIndex: number = 0;

  aboutToAppear(): void {
    this.sceneIndex = Number(HMRouterMgr.getCurrentParam());
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.back'))
          .width(40)
          .height(40)
          .margin({ right: 8 })
          .onClick(() => {
            HMRouterMgr.pop();
          });
        Text($r('app.string.optimization_guide'))
          .fontSize(20)
          .fontWeight(700);
      }
      .width('100%')
      .height(56);

      Text($r('app.string.optimization_schemes'))
        .fontSize(18)
        .fontWeight(700)
        .width('100%')
        .margin({
          top: 24,
          bottom: 16
        });

      Column() {
        Text(this.configSource![this.sceneIndex].optimization)
          .width('100%')
          .fontSize(14)
          .lineHeight(19)
          .fontColor($r('app.color.text'))
          .opacity(0.6)
          .margin({ bottom: 20 });
        Text($r('app.string.optimization_reference'))
          .width('100%')
          .fontColor($r('app.color.text'))
          .opacity(0.6)
          .fontSize(14)
          .lineHeight(19);
        ForEach(this.configSource![this.sceneIndex].adviceLink, (item: string, index: number) => {
          Row() {
            Text(`${(index + 1)}`)
              .fontColor($r('app.color.text'))
              .opacity(0.6)
              .fontSize(14)
            Text($r("app.string.dons"))
            Hyperlink(item)
              .layoutWeight(1);
          }.padding({ top: 5 })
          .alignItems(VerticalAlign.Top)
        }, (item: string, index: number) => item + index);
      }
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(12)
      .padding(16);
    }
    .padding({
      top: 30,
      left: 20,
      right: 20
    })
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}