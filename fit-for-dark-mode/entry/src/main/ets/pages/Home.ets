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
import { TodoItem } from '../view/TodoItem';
import { FinishedTodoItem } from '../view/FinishedTodoItem';
import { TodoViewModel } from '../viewmodel/TodoViewModel';
// [Start media_start]
@Component
export struct Home {
  // [StartExclude media_start]
  @State todos: Todo[] = new TodoViewModel().getTodos();
  @StorageProp('currentColorMode') currentColorMode: number = 0;
  // [EndExclude media_start]

  build() {
    Scroll() {
      Column() {
        // [StartExclude media_start]
        Row() {
          Row() {
            SymbolGlyph($r('sys.symbol.person_fill'))
              .fontSize(24)
              .fontColor([$r('app.color.left_icon_color')])
          }
          .width(40)
          .height(40)
          .backgroundColor($r('app.color.icon_bg_color'))
          .borderRadius(20)
          .justifyContent(FlexAlign.Center)


          Search({ placeholder: $r('app.string.solution') })
            .layoutWeight(1)
            .margin({ left: 8, right: 8 })
            .placeholderColor(
              this.currentColorMode === 0 ?
              $r('sys.color.font_on_secondary') :
              $r('sys.color.font_secondary')
            )
            .searchIcon({
              color: this.currentColorMode === 0 ?
              $r('sys.color.icon_on_primary') :
              $r('sys.color.icon_primary')
            })

          Row() {
            SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
              .fontSize(24)
              .fontColor([$r('app.color.right_icon_color')])
          }
          .width(40)
          .height(40)
          .backgroundColor($r('app.color.icon_bg_color'))
          .borderRadius(20)
          .justifyContent(FlexAlign.Center)

        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 11 })
        // [EndExclude media_start]

        Stack({ alignContent: Alignment.TopStart }) {
          Image($r('app.media.banner'))
            .width('100%')
            .borderRadius(12)
            .objectFit(ImageFit.Cover)

          // [StartExclude media_start]
          Column() {
            Text($r('app.string.2d_subscene_solution'))
              .fontColor(Color.White)
              .fontSize(24)
              .fontWeight(700)
              .lineHeight(32)
              .textAlign(TextAlign.Start)

            Text($r('app.string.latest_news'))
              .fontColor(Color.White)
              .fontSize(24)
              .fontWeight(700)
              .lineHeight(32)
              .textAlign(TextAlign.Start)

            Text($r('app.string.multiple_solutions'))
              .fontColor($r('sys.color.comp_focused_secondary'))
              .fontSize(12)
              .fontWeight(400)
              .lineHeight(16)
              .textAlign(TextAlign.Start)
            // [EndExclude media_start]
          }
          // [StartExclude media_start]
          .width(300)
          .margin({ left: 16, top: 16 })
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .height(200)
        .borderRadius(12)
        .margin({ bottom: 13 })

        Row() {
          Text($r('app.string.today'))
            .fontColor($r('app.color.font_color'))
            .fontSize(16)
            .fontWeight(400)
            .lineHeight(21)
            .margin({ right: 8 })
          Text($r('app.string.lunar_september_fourth'))
            .fontColor($r('app.color.todo_date'))
            .fontSize(12)
            .fontWeight(400)
            .lineHeight(16)
        }
        .width('100%')
        .height(25)
        .padding({ left: 2 })
        .margin({ bottom: 8 })

        Swiper() {
          ForEach(this.todos, (todo: Todo) => {
            Column() {
              TodoItem({ todo })
            }
            .height(108)
          }, (todo: Todo) => todo.id)
        }
        .autoPlay(true)
        .loop(true)
        .indicator(new DotIndicator()
          .itemWidth(8)
          .itemHeight(8)
          .selectedItemWidth(12)
          .selectedItemHeight(8)
          .color($r('sys.color.comp_background_secondary'))
          .selectedColor($r('sys.color.comp_background_emphasize'))
          .maxDisplayCount(7)
        )

        Row() {
          Text($r('app.string.all'))
            .fontColor($r('app.color.font_color'))
            .fontSize(16)
            .fontWeight(400)
            .lineHeight(21)
            .margin({ right: 8 })
          Text($r('app.string.lunar_september_fourth'))
            .fontColor($r('app.color.todo_date'))
            .fontSize(12)
            .fontWeight(400)
            .lineHeight(16)
        }
        .width('100%')
        .height(25)
        .padding({ left: 2 })
        .margin({ top: 12, bottom: 8 })

        List({ space: 8 }) {
          ListItem() {
            FinishedTodoItem({ todo: this.todos[0] })
          }

          ForEach(this.todos, (todo: Todo) => {
            ListItem() {

              TodoItem({ todo })
            }
          }, (todo: Todo) => todo.id)
        }
        .width('100%')

        Row() {
        }
        .width('100%')
        .height(76)
        .backgroundColor(Color.Transparent)
        // [EndExclude media_start]
      }
    }
    // [StartExclude media_start]
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 16 })
    // [EndExclude media_start]
  }
}
// [End media_start]
