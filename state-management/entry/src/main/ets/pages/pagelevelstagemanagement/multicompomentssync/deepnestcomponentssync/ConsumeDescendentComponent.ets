/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { common } from '@kit.AbilityKit';
import ColorType from '../model/ColorType';
import { COLOR_SELECT_DATA } from '../data/ColorData';
import { getResourceString } from '../../../../utils/ResourceUtils';
import { ViewCodeText } from '../../../../commoncomponents/ViewCodeText';

@Component
export struct ConsumeDescendentComponent {
  // Initializes a color array of data.
  @State selectColors: ColorType[] = COLOR_SELECT_DATA;
  // And ye components bidirectional synchronous circular color.
  @Consume consumeCircleColor: Resource;
  // The Index value of bidirectional synchronization Select with the master component.
  @Consume currentSelectIndex: number;

  build() {
    Column() {
      // Click to view source code.
      ViewCodeText({ webSrc: $rawfile('ConsumeDescendentComponent.ets.html') })
      Row() {
        Select(this.selectColors)
          .selected(this.currentSelectIndex)
          .value(getResourceString(this.getUIContext().getHostContext() as common.UIAbilityContext,
            this.selectColors[this.currentSelectIndex].value))
          .fontColor($r('app.color.button_text_color'))
          .font({ size: $r('app.float.tips_font_size') })
          .selectedOptionFont({ size: $r('app.float.tips_font_size') })
          .optionFont({ size: $r('app.float.tips_font_size') })
          .id('grandsonCompB')
          .onSelect((index: number) => {
            // The data page of the child component @Consume is updated, and the data page of the child component @Provide is updated synchronously.
            this.currentSelectIndex = index;
            this.consumeCircleColor = this.selectColors[index].color;
          })
        Circle()
          .size({ width: $r('app.float.circle_size'), height: $r('app.float.circle_size') })
          .fill(this.consumeCircleColor)

      }.justifyContent(FlexAlign.SpaceAround)
      .width('100%')
      .margin({ bottom: 6 })

      Text($r('app.string.deepnest_descendent_titletwo'))
        .fontColor($r('app.color.tips_font_color'))
        .fontSize($r('app.float.button_text_size'))
        .width('100%')
        .textAlign(TextAlign.Center)
    }
    .padding(10)
    .border({ radius: $r('app.float.component_radius'), color: Color.Red, width: $r('app.float.border_width') })
  }
}