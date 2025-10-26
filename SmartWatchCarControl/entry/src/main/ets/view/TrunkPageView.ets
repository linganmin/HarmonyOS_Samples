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

import { display } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

let alignRus: AlignRuleOption = {
  'center': { 'anchor': '__container__', 'align': VerticalAlign.Center },
  'middle': { 'anchor': '__container__', 'align': HorizontalAlign.Center }
};

let openAlignRus: AlignRuleOption = {
  'center': { 'anchor': '__container__', 'align': VerticalAlign.Top },
  'middle': { 'anchor': '__container__', 'align': HorizontalAlign.Center }
};

let closeAlignRus: AlignRuleOption = {
  'center': { 'anchor': '__container__', 'align': VerticalAlign.Bottom },
  'middle': { 'anchor': '__container__', 'align': HorizontalAlign.Center }
};

@Builder
export function trunkPageBuilder() {
  TrunkPageView()
}

/**
 * Trunk Control Page
 */
@Component
struct TrunkPageView {
  @State tempValue: number = 0;
  @State offsetX: number = 0;
  @State offsetY: number = 0;
  @State positionX: number = 0;
  @State positionY: number = 0;
  private high: number = 0;
  private dpi: number = 0;
  private pabOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.Down });
  pathStack: NavPathStack = new NavPathStack();

  onPageShow(): void {
    let displayClass: display.Display | null = null;
    try {
      displayClass = display.getDefaultDisplaySync();
      this.high = displayClass.height;
      this.dpi = displayClass.densityDPI;
    } catch (err) {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to get display class. Cause: %{public}s', JSON.stringify(err) ?? '');
      }
    }
  }

  build() {
    NavDestination() {
      Column() {
        RelativeContainer() {
          Progress({ value: this.tempValue, total: 100, type: ProgressType.Capsule })
            .width(53)
            .height('100%')
            .color(Color.Blue)
            .backgroundColor('#ff838282')
            .rotate({ angle: 180 })
            .id('pro')
            .alignRules(alignRus)
            .gesture(
              PanGesture(this.pabOption)
                .onActionStart(() => {

                })
                .onActionUpdate((event: GestureEvent) => {
                  if (event) {
                    this.offsetY = event.offsetY;
                    let dis = event.offsetY * this.dpi / 160;
                    this.tempValue = dis / this.high * 100 + 18;
                  }
                })
                .onActionEnd(() => {
                  if (this.tempValue < 100) {
                    this.tempValue = 0;
                  } else {
                    this.pathStack.replacePathByName('SafeCodePage', null);
                  }
                })
            )
          Image($r('app.media.trunk_open'))
            .width(25)
            .height(25)
            .alignRules(openAlignRus)
            .margin({ top: 50 })
          Image($r('app.media.trunk_close'))
            .width(25)
            .height(25)
            .alignRules(closeAlignRus)
            .margin({ bottom: 50 })
        }
        .width('100%')
        .height('80%')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .width('100%')
    .height('100%')
    .borderRadius('50%')
    .backgroundColor(Color.Black)
    .hideTitleBar(true)
    .hideToolBar(true)
  }
}