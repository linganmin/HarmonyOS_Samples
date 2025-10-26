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
 */

import { hilog } from "@kit.PerformanceAnalysisKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { common } from "@kit.AbilityKit";
import { CommonConstants } from "../common/constants/CommonConstants";

const TAG = '[SetBrightness]'

@Component
export struct SetBrightness {
  @Prop @Watch('onScreenBrightnessChange') screenBrightness: number = 5;
  @Prop visible: boolean = false;

  private uiAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private mainWin = this.uiAbilityContext.windowStage.getMainWindowSync();

  onScreenBrightnessChange () {
    try {
      this.mainWin.setWindowBrightness(this.screenBrightness, (err: BusinessError) => {
        if (err.code) {

          hilog.error(CommonConstants.LOG_DOMAIN, TAG,
            `Failed to set the brightness. code is ${err.code}, message is ${err.message}, current brightness is ${this.screenBrightness}`);
          return;
        }
        hilog.info(CommonConstants.LOG_DOMAIN, TAG, 'Succeeded in setting the brightness.');
      });
    } catch (exception) {
      hilog.error(CommonConstants.LOG_DOMAIN, TAG,
        `Failed to set the brightness. code is ${exception.code}, message is ${exception.message}, other`);
    }

  }



  build() {
    Column() {
      Stack() {
        Slider({
          value: this.screenBrightness,
          min: 0,
          max: 1,
          step: 0.05,
          style: SliderStyle.NONE,
          direction: Axis.Vertical,
          reverse: true
        })
          .height(160)
          .selectedColor(Color.White)
          .trackColor('#80000000')
          .trackThickness(40)

        Image($r('app.media.sun_max_fill'))
          .margin({ top: 120 })
          .width(20)
          .height(20)
      }
      .visibility(this.visible ? Visibility.Visible : Visibility.Hidden)
      .margin({
        top: 0,
        right: 0
      })
    }.width('100%')
    .alignItems(HorizontalAlign.End)
    .justifyContent(FlexAlign.Center)
    .padding({
      right: 30,
      bottom: 20
    })
  }
}
// [End set_volume_component]