/*
 *
 *  * Copyright (c) 2025 Huawei Device Co., Ltd.
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */

import { ComponentContent } from '@kit.ArkUI';
import { AchievementList } from '../../model/AchievementModel';
import { CommonConstants as Const, PromptActionClass } from 'common';
import { AchievementDialogParams } from '../../viewmodel/dialog/AchievementDialogParams';

export function openAchievementCustomDialog(uIContext: UIContext, index: number): void {
  PromptActionClass.setContext(uIContext);
  let params = new AchievementDialogParams(uIContext, index, Const.ANIMATE_OPACITY_0, Const.ANIMATE_ANGLE_0,
    Const.ANIMATE_SCALE_0);
  let taskInfoDialogNode = new ComponentContent(uIContext, wrapBuilder(taskInfoDialogBuilder), params);
  PromptActionClass.setContentNode(taskInfoDialogNode);
  PromptActionClass.openDialog();
}

@Builder
export function taskInfoDialogBuilder(param: AchievementDialogParams) {
  Column() {
    Image(AchievementList[param.index].iconOn)
      .width(Const.THOUSANDTH_560)
      .height(Const.THOUSANDTH_400)
      .objectFit(ImageFit.Contain)

    Text($r('app.string.achievement_level', AchievementList[param.index].name))
      .fontFamily(Const.HARMONY_HEI_TI)
      .fontWeight(FontWeight.Regular)
      .fontColor($r('sys.color.font_on_primary'))
      .fontSize($r('app.float.default_24'))
      .margin({
        top: $r('app.float.default_12')
      })
  }
  .height(Const.THOUSANDTH_333)
  .width(Const.THOUSANDTH_500)
  .justifyContent(FlexAlign.Center)
  .scale({
    x: param.scaleValue,
    y: param.scaleValue
  })
  .rotate({
    x: Const.ANIMATE_ROTATE_0,
    y: Const.ANIMATE_ROTATE_1,
    z: Const.ANIMATE_ROTATE_0,
    angle: param.angle
  })
  .opacity(param.opacityValue)
  .onAppear(() => {
    param.uiContext?.animateTo({
      duration: Const.DURATION_800,
      curve: Curve.EaseOut,
      delay: Const.DURATION_100,
      iterations: Const.ANIMATE_ITERATIONS_1
    }, () => {
      PromptActionClass.contentNode.update(
        new AchievementDialogParams(param.uiContext, param.index, Const.ANIMATE_OPACITY_1, Const.ANIMATE_ANGLE_360,
          Const.ANIMATE_SCALE_1));
    });
  })
}