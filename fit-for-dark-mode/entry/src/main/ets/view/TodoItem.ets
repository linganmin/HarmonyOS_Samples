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

import { Todo } from '../viewmodel/Todo';

@Component
export struct TodoItem {
  @Prop todo: Todo;

  build() {
    Row() {
      Column() {
        SymbolGlyph($r('sys.symbol.bell'))
          .fontSize(24)
          .fontColor([$r('app.color.font_color')])
        Column().width(1).height(7).backgroundColor($r('app.color.horizon_box')).borderRadius(100)
        Row()
          .width(5)
          .height(5)
          .borderRadius(2.5)
          .border({
            width: 1.5,
            color: '#7A6FEB'
          })
          .margin({ top: 2 })

        Text(this.todo?.time)
          .fontColor($r('app.color.font_color'))
          .fontSize(12)
          .fontWeight(500)
          .lineHeight(16)
      }
      .width(38)
      .height(54)
      .margin({ right: 12 })

      Column() {
        Text(this.todo.text)
          .fontColor($r('app.color.font_color'))
          .fontSize(16)
          .fontWeight(500)
          .lineHeight(21)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.todo.date)
          .fontColor($r('app.color.todo_date'))
          .fontSize(14)
          .fontWeight(400)
          .lineHeight(19)
      }
      .padding({ top: 5, bottom: 5 })
      .layoutWeight(1)
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(HorizontalAlign.Start)

      Toggle({ type: ToggleType.Switch, isOn: this.todo.finished })
    }
    .width('100%')
    .height(76)
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .borderRadius(16)
    .backgroundColor($r('app.color.item_box'))
    .padding({
      left: 12,
      top: 11,
      bottom: 11,
      right: 19
    })
    .shadow({
      radius: 20,
      color: '#0D000000'
    })
  }
}