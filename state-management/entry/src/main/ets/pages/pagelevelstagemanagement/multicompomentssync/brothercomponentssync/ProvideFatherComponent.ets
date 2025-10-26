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

import ColorType from '../model/ColorType';
import { COLOR_SELECT_DATA } from '../data/ColorData';
import { ConsumeBrotherOneComponent } from './ConsumeBrotherOneComponent';
import { ConsumeBrotherTwoComponent } from './ConsumeBrotherTwoComponent';
import { ViewCodeText } from '../../../../commoncomponents/ViewCodeText';

@Component
export struct ProvideFatherComponent {
  // Initializes a color array.
  @State selectColors: ColorType[] = COLOR_SELECT_DATA;
  // The co-parent component initializes the circular color using @Provide.
  @Provide consumeCircleColor: Resource = $r('app.color.circle_blue');
  // Initialize the Index of the Select component to 0.
  @Provide currentSelectIndex: number = 0;

  build() {
    Column({ space: 10 }) {
      // Click to view source code.
      ViewCodeText({ webSrc: $rawfile('ProvideFatherComponent.ets.html') })
      Text($r('app.string.parent_titletwo'))
        .fontSize($r('app.float.tips_font_size'))
        .fontColor($r('app.color.tips_font_color'))
        .width('100%')
        .textAlign(TextAlign.Center)
      // Bidirectional synchronous component A with parent component.
      ConsumeBrotherOneComponent()
      // Bidirectional synchronous component B with parent component.
      ConsumeBrotherTwoComponent()
    }.padding(10)
    .border({ radius: $r('app.float.component_radius'), color: Color.Grey, width: $r('app.float.border_width') })
  }
}

