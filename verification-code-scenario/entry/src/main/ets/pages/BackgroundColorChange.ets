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

import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { inputMethod } from '@kit.IMEKit';
import { window } from '@kit.ArkUI';
import Constants from '../common/Constants';

@Extend(Text)
function verifyCodeUnitStyle() {
  .fontSize($r('app.float.font_size'))
  .fontWeight(FontWeight.Bold)
  .textAlign(TextAlign.Center)
  .width($r('app.float.text_height'))
  .aspectRatio(Constants.LINE_HEIGHT)
  .margin({
    left: $r('app.float.text_margin'),
    right: $r('app.float.text_margin')
  })
  .borderRadius($r('app.float.row_width'))
}

const TAG = 'BackgroundColorChange';

@Entry
@Component
struct BackgroundColorChange {
  @State codeText: string = '';
  private inputController: inputMethod.InputMethodController = inputMethod.getController();
  private arrArea: number[] = [0.0, 1, 0];
  private verifyCodeLength: number = 6;
  private codeIndexArray: Array<number> = Array.from([0, 1, 2, 3, 4, 5]);
  private textConfig: inputMethod.TextConfig = {
    inputAttribute: {
      textInputType: inputMethod.TextInputType.NUMBER,
      enterKeyType: inputMethod.EnterKeyType.GO
    }
  };
  private windowClass: window.Window = AppStorage.get('windowClass') as window.Window;
  private isFirstOpenPage: boolean = true;
  private registerCount: number = 1;

  aboutToDisappear(): void {
    this.detach();
  }

  async attach() {
    if (this.isFirstOpenPage) {
      await this.inputController.attach(true, this.textConfig).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG, `attach failed. code=${err.code}, message=${err.message}`);
      });
      this.listen();
      return;
    }
    try {
      this.windowClass.on('windowEvent', async (windowState) => {
        if (windowState === window.WindowEventType.WINDOW_ACTIVE && this.registerCount === 1) {
          this.registerCount++;
          await this.inputController.attach(true, this.textConfig);
          this.listen();
        }
      });
    } catch (error) {
      hilog.error(0x0000, TAG, `failed to getWindowState callback, error code : ${error.code}`);
    }
  }

  listen() {
    try {
      this.inputController.on('insertText', (text: string) => {
        if (this.codeText.length >= this.verifyCodeLength || isNaN(Number(text)) || text === ' ') {
          return;
        }
        this.codeText += text;
      })
      this.inputController.on('deleteLeft', () => {
        this.codeText = this.codeText.substring(0, this.codeText.length - 1);
      })
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `listen failed. code=${err.code}, message=${err.message}`);
    }
  }

  detach(): void {
    this.isFirstOpenPage = false;
    this.registerCount = 1;
    this.windowClass.off('windowEvent');
    this.inputController.off('insertText');
    this.inputController.off('deleteLeft');
    this.inputController.detach((_err: BusinessError) => {
    });
  }

  @Builder
  buildVerifyCodeComponent() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
      ForEach(this.codeIndexArray, (item: number) => {
        Text(this.codeText[item])
          .verifyCodeUnitStyle()
          .backgroundColor(this.codeText[item] === undefined ? $r('app.color.index_background') :
            $r('app.color.theme_color_m'))
      }, (item: number) => JSON.stringify(item))
    }
    .onVisibleAreaChange(this.arrArea, async (isVisible: boolean, currentRatio: number) => {
      if (isVisible && currentRatio >= 1.0) {
        this.attach();
      }
      if (!isVisible && currentRatio <= 0.0) {
        this.detach();
      }
    })
    .backgroundColor(Color.Transparent)
    .height($r('app.float.text_height'))
    .margin({
      left: $r('app.float.background_margin'),
      right: $r('app.float.background_margin')
    })
    .defaultFocus(true)
    .onClick(() => {
      this.inputController.attach(true, this.textConfig);
    })
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.enter_the_verification_code'))
          .fontSize($r('app.float.font_size_l'))
          .fontWeight(FontWeight.Medium)
      }
      .height($r('app.float.list_padding_top'))

      Row() {
        Text($r('app.string.Verification_code_sent_to'))
          .fontSize($r('app.float.font_size_m'))
          .fontColor($r('app.color.phone_color'))
          .fontWeight(FontWeight.Regular)
        Text($r('app.string.phone_number1'))
          .fontSize($r('app.float.font_size_m'))
          .fontColor($r('app.color.theme_color'))
          .fontWeight(FontWeight.Regular)
      }
      .margin({
        top: $r('app.float.row_width'),
        bottom: $r('app.float.margin_bottom')
      })

      this.buildVerifyCodeComponent()

      Row() {
        Text($r('app.string.reacquire'))
          .fontSize($r('app.float.font_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.theme_color'))
      }
      .width(Constants.NINETY_PERCENT)
      .margin({ top: $r('app.float.row_margin') })
      .justifyContent(FlexAlign.End)
    }
    .padding({ top: Constants.LINE_WIDTH })
    .height(Constants.ONE_HUNDRED_PERCENT)
    .width(Constants.ONE_HUNDRED_PERCENT)
  }
}

@Builder
export function getColorChange(name: string): void {
  if (name === 'BackgroundColorChange') {
    NavDestination() {
      BackgroundColorChange()
    }
  }
}

export const wrappedBuilderColorChange: WrappedBuilder<[string, number]> = wrapBuilder(getColorChange);