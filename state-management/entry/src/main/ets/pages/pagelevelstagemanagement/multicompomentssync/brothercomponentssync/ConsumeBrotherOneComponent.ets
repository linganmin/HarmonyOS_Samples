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
export struct ConsumeBrotherOneComponent {
  @State selectColors: ColorType[] = COLOR_SELECT_DATA;
  // Bidirectional synchronous circular color with parent component and child component B.
  @Consume consumeCircleColor: Resource;
  // Bidirectional synchronization with parent component and child component B Indicates the Index value of the Select component.
  @Consume currentSelectIndex: number;

  build() {
    Column({ space: 10 }) {
      // Click to view source code.
      ViewCodeText({ webSrc: $rawfile('ConsumeBrotherOneComponent.ets.html') })
      Text($r('app.string.consume_brothers_title'))
        .fontSize($r('app.float.tips_font_size'))
        .fontColor($r('app.color.tips_font_color'))
        .width('100%')
        .textAlign(TextAlign.Center)
      Row() {
        Select(this.selectColors)
          .id('consumeSelectCompA')
          .selected(this.currentSelectIndex)
          .value(getResourceString(this.getUIContext().getHostContext() as common.UIAbilityContext,
            this.selectColors[this.currentSelectIndex].value))
          .fontColor($r('app.color.button_text_color'))
          .font({ size: $r('app.float.select_font_size') })
          .selectedOptionFont({ size: $r('app.float.select_font_size') })
          .optionFont({ size: $r('app.float.select_font_size') })
          .onSelect((index: number) => {
            // The data page of this component @Consume is updated, and the data page of the sibling component @Consume is updated simultaneously.
            this.currentSelectIndex = index;
            this.consumeCircleColor = this.selectColors[index].color;
          })
        Circle()
          .size({ width: $r('app.float.circle_size'), height: $r('app.float.circle_size') })
          .fill(this.consumeCircleColor)
      }.justifyContent(FlexAlign.SpaceAround)
      .width('100%')
    }
    .padding(10)
    .border({ radius: $r('app.float.component_radius'), color: Color.Blue, width: $r('app.float.border_width') })
  }
}