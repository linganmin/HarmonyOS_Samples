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
import { vibrator } from '@kit.SensorServiceKit';
import Constants, { CONFIGURATION } from '../common/Constants';
import Logger from '../../../common/Logger';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Component
export struct PageVibrateEffect {
  @State translateX: number = 0;
  @State confirm: boolean = false;
  uiContext: UIContext | undefined = undefined;

  aboutToAppear() {
    this.uiContext = this.getUIContext?.();
  }

  build() {
    Column() {
      Row()
        .width(Constants.LAYOUT_MAX_PERCENT)
        .height($r('app.integer.elements_height'))
        .backgroundColor($r('app.color.ohos_id_color_background'))

      Scroll() {
        Column({ space: CONFIGURATION.MARGIN_VERTICAL }) {
          Row() {
            Image($r('app.media.icon_home'))
              .width($r('app.integer.image_size'))
              .height($r('app.integer.image_size'))
          }
          .justifyContent(FlexAlign.Center)
          .backgroundColor($r('app.color.ohos_fa_emphasize'))
          .width($r('app.integer.home_image_size'))
          .height($r('app.integer.home_image_size'))
          .borderRadius($r('app.integer.comm_border_radius'))

          Text($r('app.string.phone_number'))
            .fontSize($r('app.integer.phone_number_font_size'))
            .fontWeight(FontWeight.Bold)

          Column() {
            Row() {
              Button() {
                Image(this.confirm ? $r('app.media.ic_ok') : $r('app.media.ic_default'))
                  .height($r('app.integer.circle_icon_size'))
                  .width($r('app.integer.circle_icon_size'))
              }
              .onClick(() => {
                this.confirm = !this.confirm;
              })
              .height($r('app.integer.circle_elements_height'))
              .width($r('app.integer.circle_elements_width'))
              .backgroundColor($r('app.color.ohos_id_color_background'))

              Text() {
                Span($r('app.string.read_and_agreed'))
                  .fontColor($r('app.color.ohos_id_color_text_secondary'))
                  .fontSize($r('app.integer.comm_font_size'))
                Span($r('app.string.services_and_policies'))
                  .fontColor($r('app.color.ohos_id_color_palette8'))
                  .fontSize($r('app.integer.comm_font_size'))
                  .onClick(() => {
                    try {
                      this.getUIContext().getPromptAction().showToast({
                        message: $r('app.string.prompt_text')
                      });
                    } catch (err) {
                      let error = err as BusinessError;
                      hilog.error(0x0000, 'PageVibrateEffect', `error code=${error.code}, message=${error.message}`);
                    }
                  })
                Span($r('app.string.and'))
                  .fontColor($r('app.color.ohos_id_color_text_secondary'))
                  .fontSize($r('app.integer.comm_font_size'))
                Span($r('app.string.service_agreement'))
                  .fontColor($r('app.color.ohos_id_color_palette8'))
                  .fontSize($r('app.integer.comm_font_size'))
                  .onClick(() => {
                    try {
                      this.getUIContext().getPromptAction().showToast({
                        message: $r('app.string.prompt_text')
                      });
                    } catch (err) {
                      let error = err as BusinessError;
                      hilog.error(0x0000, 'PageVibrateEffect', `error code=${error.code}, message=${error.message}`);
                    }
                  })
                Span($r('app.string.privacy_policy'))
                  .fontColor($r('app.color.ohos_id_color_palette8'))
                  .fontSize($r('app.integer.comm_font_size'))
                  .onClick(() => {
                    try {
                      this.getUIContext().getPromptAction().showToast({
                        message: $r('app.string.prompt_text')
                      });
                    } catch (err) {
                      let error = err as BusinessError;
                      hilog.error(0x0000, 'PageVibrateEffect', `error code=${error.code}, message=${error.message}`);
                    }
                  })
              }
              .flexShrink(CONFIGURATION.FLEX_SHRINK)
            }
            .width(Constants.LAYOUT_MAX_PERCENT)
            .alignItems(VerticalAlign.Top)

            Stack() {
              if (!this.confirm) {
                Column() {
                  Image($r('app.media.login_popup'))
                    .width($r('app.integer.image_size2'))
                    .height($r('app.integer.image_size2'))
                    .position({
                      x: CONFIGURATION.POPUP_POSITION_X,
                      y: CONFIGURATION.POPUP_POSITION_Y
                    })
                    .opacity(CONFIGURATION.OPACITY_VALUE)

                  Text($r('app.string.read_and_check'))
                    .fontColor($r('app.color.ohos_id_color_background'))
                    .fontSize($r('app.integer.read_check_font_size'))
                    .textAlign(TextAlign.Center)
                    .backgroundColor($r('app.color.ohos_id_color_foreground'))
                    .width(120)
                    .height(30)
                    .position({
                      x: CONFIGURATION.MARK_POSITION_X,
                      y: CONFIGURATION.MARK_POSITION_Y
                    })
                    .borderRadius($r('app.integer.read_check_border_radius_size'))
                    .opacity(CONFIGURATION.OPACITY_VALUE)
                }
                .width($r('app.integer.elements_height'))
                .height($r('app.integer.total_mark_height'))
                .position({
                  x: this.translateX,
                  y: CONFIGURATION.POSITION_ZERO
                })
              }
            }
            .alignContent(Alignment.Start)
            .height($r('app.integer.total_mark_height'))
            .width(Constants.LAYOUT_MAX_PERCENT)
          }

          // [Start invoke_animation]
          Button($r('app.string.login_in'))
            .type(ButtonType.Normal)
            .borderRadius($r('app.integer.comm_border_radius'))
            .fontColor($r('app.color.ohos_id_color_background'))
            .fontSize($r('app.integer.login_button_font_size'))
            .width(Constants.LAYOUT_MAX_PERCENT)
            .onClick(() => {
              if (!this.confirm) {
                this.startVibrate();
                this.startAnimation();
              } else {
                try {
                  this.getUIContext().getPromptAction().showToast({
                    message: $r('app.string.login_text')
                  });
                } catch (err) {
                  let error = err as BusinessError;
                  hilog.error(0x0000, 'PageVibrateEffect', `error code=${error.code}, message=${error.message}`);
                }
              }
            })
          // [End invoke_animation]

          Text($r('app.string.other_login_methods'))
            .fontColor($r('app.color.ohos_id_color_palette8'))
            .fontSize($r('app.integer.other_login_font_size'))
            .backgroundColor($r('app.color.ohos_id_color_background'))
            .onClick(() => {
              try {
                this.getUIContext().getPromptAction().showToast({
                  message: $r('app.string.prompt_text')
                });
              } catch (err) {
                let error = err as BusinessError;
                hilog.error(0x0000, 'PageVibrateEffect', `error code=${error.code}, message=${error.message}`);
              }
            })
        }
        .width(Constants.LAYOUT_MAX_PERCENT)
      }
      .scrollBar(BarState.Off)
    }
    .width(Constants.LAYOUT_MAX_PERCENT)
    .height(Constants.LAYOUT_MAX_PERCENT)
    .padding($r('app.integer.ohos_id_default_padding'))
  }

  startVibrate() {
    try {
      vibrator.startVibration({
        type: 'time',
        duration: CONFIGURATION.VIBRATION_TIME,
      }, {
        id: Constants.COMM_INIT,
        usage: 'alarm',
      }, (error: BusinessError) => {
        if (error) {
          Logger.error(`Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
          return;
        }
      });
    } catch (err) {
      Logger.error(`An unexpected error occurred. Code: ${err.code}, message: ${err.message}`);
    }
  }

  // [Start keyframe_animate_to]
  startAnimation() {
    if (!this.uiContext) {
      return;
    }
    this.translateX = CONFIGURATION.POSITION_ZERO;
    this.uiContext.keyframeAnimateTo({ iterations: CONFIGURATION.PLAYBACK_COUNT }, [
      {
        duration: CONFIGURATION.ANIMATION_TIME,
        event: () => {
          this.translateX = CONFIGURATION.TRANSLATE_OFFSET_X;
        }
      },
      {
        duration: CONFIGURATION.ANIMATION_TIME,
        event: () => {
          this.translateX = CONFIGURATION.POSITION_ZERO;
        }
      }
    ]);
  }

  // [End keyframe_animate_to]
}

@Builder
export function getPageVibrateEffect(name: string): void {
  if (name === 'PageVibrateEffect') {
    NavDestination() {
      PageVibrateEffect()
    }
  }
}

export const wrappedBuilderVibrateEffect: WrappedBuilder<[string, number]> = wrapBuilder(getPageVibrateEffect);