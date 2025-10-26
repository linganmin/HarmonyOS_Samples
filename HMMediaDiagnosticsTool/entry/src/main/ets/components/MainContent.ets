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

import { AppStore } from '../common/store/AppStore';

@Component
export struct MainContent {
  @Prop checkPoint: string[] = [];
  @Prop bestExperience: string[] = [];
  @Prop stepTips: string[] = [];
  private isMultiStep: boolean = false;
  private currentStepIndex: number = 0;
  @StorageLink('isCapturering') isCapturering: boolean = false;

  aboutToAppear(): void {
    this.isMultiStep = AppStore.getInstance().isMultiStep;
    this.currentStepIndex = AppStore.getInstance().currentStepIndex;
  }

  setStepOn(index: number) {
    return index < this.currentStepIndex;
  }

  build() {
    Column() {
      Column() {
        Text($r('app.string.home_title_1'))
          .width('100%')
          .fontSize(18)
          .fontWeight(700)
          .lineHeight(20)
          .padding({ top: 18 });

        ForEach(this.checkPoint, (item: string) => {
          Text(item)
            .width('100%')
            .fontSize(14)
            .lineHeight(24)
            .fontColor($r('app.color.text'))
            .opacity(0.6)
            .textAlign(TextAlign.Start);
        }, (item: string, index: number) => item + index);
      }
      .padding({
        top: 18,
        bottom: 8
      })
      .margin({ bottom: 8 });

      Column() {
        Text($r('app.string.home_title_2'))
          .width('100%')
          .fontSize(18)
          .fontWeight(700)
          .lineHeight(20)
          .padding({ top: 18 });

        ForEach(this.bestExperience, (item: string) => {
          Text(item)
            .width('100%')
            .fontSize(14)
            .lineHeight(24)
            .fontColor($r('app.color.text'))
            .opacity(0.6)
            .textAlign(TextAlign.Start);
        }, (item: string, index: number) => item + index);
      }
      .padding({
        top: 18,
        bottom: 8
      })
      .margin({ bottom: 8 });

      Column() {
        Text($r('app.string.home_title_3'))
          .width('100%')
          .fontSize(18)
          .fontWeight(700)
          .lineHeight(20)
          .padding({ top: 18 });

        ForEach(this.stepTips, (item: string, index: number) => {
          Row() {
            Text(item)
              .layoutWeight(1)
              .fontSize(14)
              .lineHeight(24)
              .fontColor($r('app.color.text'))
              .opacity(0.6)
              .textAlign(TextAlign.Start);

            if (this.isMultiStep) {
              Image(this.setStepOn(index) ? $r('app.media.right') : $r('app.media.skip'))
                .width(20)
                .height(20)
                .margin({
                  left: 2,
                  right: 14
                });
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween);
        }, (item: string, index: number) => item + index);
      }
      .padding({ top: 18 });
    }
    .width('100%')
    .margin({ top: 12 });
  }
}