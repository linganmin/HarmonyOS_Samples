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
  .fontColor($r('app.color.theme_color'))
  .textAlign(TextAlign.Center)
  .width($r('app.float.text_height'))
  .height(Constants.ONE_HUNDRED_PERCENT)
}

const TAG = 'TextBoxShowCursor';

@Entry
@Component
struct TextBoxShowCursor {
  @State codeText: string = '';
  @State opacityColumn: number = 0;
  @State flag: boolean = true;
  private arrArea: number[] = [0.0, 1, 0];
  private inputController: inputMethod.InputMethodController = inputMethod.getController();
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

  /**
   * Binding an Input Method and Subscribing to Input Method-related Events.
   */
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

  /**
   * Subscribe to the events of inserting and deleting leftward in the input method to obtain the input content of
   * the keyboard.
   */
  listen() {
    try {
      this.inputController.on('insertText', (text: string) => {
        if (this.codeText.length >= this.verifyCodeLength || isNaN(Number(text)) || text === ' ') {
          return;
        }
        this.codeText += text;
        if (this.codeText.length === this.verifyCodeLength) {
          this.flag = false;
        }
      })
      this.inputController.on('deleteLeft', () => {
        this.codeText = this.codeText.substring(0, this.codeText.length - 1);
        if (this.codeText.length !== this.verifyCodeLength) {
          this.flag = true;
        }
      })
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `listen failed. code=${err.code}, message=${err.message}`);
    }
  }

  /**
   * Unbinding.
   */
  detach() {
    this.isFirstOpenPage = false;
    this.registerCount = 1;
    this.windowClass.off('windowEvent');
    this.inputController.off('insertText');
    this.inputController.off('deleteLeft');
    this.inputController.detach((_err: BusinessError) => {
    })
  }

  /**
   * In some verification code scenarios, the functions of selecting and copying entered verification codes must be disabled.
   * Therefore, the Text component can be used.
   */
  @Builder
  buildVerifyCodeComponent() {
    Stack() {
      Row() {
        ForEach(this.codeIndexArray, (item: number) => {
          Text(this.codeText[item])
            .verifyCodeUnitStyle()
            .border({
              width: { bottom: $r('app.float.row_height_one') },
              color: {
                bottom: this.codeText[item] === undefined ? $r('app.color.line_divider') : $r('app.color.theme_color')
              },
              style: { bottom: BorderStyle.Solid }
            })
        }, (item: number) => item.toString())
      }
      // When the visible area changes, binding registration and unbinding are performed.
      .onVisibleAreaChange(this.arrArea, async (isVisible: boolean, currentRatio: number) => {
        if (isVisible && currentRatio >= 1) {
          this.opacityColumn = 1;
          this.attach();
        }
        if (!isVisible && currentRatio <= 0) {
          this.detach();
        }
      })
      .backgroundColor(Color.Transparent)
      .height($r('app.float.text_height'))
      .width($r('app.float.context_area'))
      .defaultFocus(true)
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        // When you click this component, the input method is displayed. Because the Text component is used here,
        // you need to re-attach it instead of directly using showSoftKeyboard.
        this.inputController.attach(true, this.textConfig);
      })

      Row() {
        Column() {
          Text()
            .opacity(this.opacityColumn)
            .width(Constants.TWO)
            .height($r('app.float.cursor_height'))
            .backgroundColor($r('app.color.theme_color'))
            .borderRadius($r('app.float.row_height_one'))
            .animation({
              duration: Constants.EIGHT_HUNDRED,
              curve: Curve.Rhythm,
              iterations: Constants.ITERATION,
              playMode: PlayMode.Alternate,
              expectedFrameRateRange: {
                min: Constants.TWENTY,
                max: Constants.ONE_HUNDRED_AND_TWENTY,
                expected: Constants.NINETY
              }
            })
        }
        .visibility(this.flag ? Visibility.Visible : Visibility.Hidden)
        .translate({
          x: this.codeText.length === Constants.ZERO ? Constants.ZERO :
            (((Constants.TOTAL_WIDTH - (Constants.ONE_TEXT_WIDTH * Constants.ALL_TEXT_COUNT)) /
            Constants.ALL_MARGIN_COUNT) + Constants.ONE_TEXT_WIDTH) * this.codeText.length
        })
        .hitTestBehavior(HitTestMode.Transparent)
        .onClick(() => {
          this.inputController.attach(true, this.textConfig);
        })
        .justifyContent(FlexAlign.Center)
        .width($r('app.float.text_height'))
        .height(Constants.ONE_HUNDRED_PERCENT)
        .borderWidth({ bottom: $r('app.float.text_border_width') })
        .borderColor($r('app.color.theme_color'))
      }
      .hitTestBehavior(HitTestMode.Transparent)
      .height($r('app.float.text_height'))
      .width($r('app.float.context_area'))
    }
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
        Text($r('app.string.phone_number'))
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
export function getShowCursor(name: string): void {
  if (name === 'TextBoxShowCursor') {
    NavDestination() {
      TextBoxShowCursor()
    }
  }
}

export const wrappedBuilderShowCursor: WrappedBuilder<[string, number]> = wrapBuilder(getShowCursor);