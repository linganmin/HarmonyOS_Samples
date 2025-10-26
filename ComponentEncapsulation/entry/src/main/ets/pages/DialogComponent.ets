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
import { getResourceString } from '../model/GetResourceString';
// [Start dialog_component]
import { PopViewUtils } from '../model/PopViewUtils';
// [StartExclude dialog_component]
@Builder
export function DialogComponentBuilder() {
  DialogComponent()
}
// [Start build_text]
@Builder
export function buildText(_obj: Object) {
  Column({ space: 16 }) {
    Text($r('app.string.tips'))
      .fontSize($r('app.float.font_size_l'))
      .fontWeight(FontWeight.Bold)
    Text($r('app.string.content'))
      .fontSize($r('app.float.font_size_l'))
    Row() {
      Button($r('app.string.cancel'))
        .fontColor($r('app.color.blue'))
        .backgroundColor(Color.White)
        .margin({ right: $r('app.float.margin_right') })
        .width('42%')
        .onClick(() => {
          PopViewUtils.closePopView();
        })
      Button($r('app.string.confirm'))
        .width('42%')
        .onClick(() => {
          PopViewUtils.closePopView();
        })
    }
    .justifyContent(FlexAlign.Center)
    .width($r('app.float.dialog_width'))
  }
  .width($r('app.float.dialog_width'))
  .padding($r('app.float.padding_l'))
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
  .backgroundColor(Color.White)
  .borderRadius($r('app.float.border_radius'))
}
// [End build_text]
// [EndExclude dialog_component]
@Entry
@Component
struct DialogComponent {
  build() {
    NavDestination() {
      Column() {
        Button('Click me')
          .width('100%')
          .onClick(() => {
            PopViewUtils.showPopView<Object>(wrapBuilder(buildText), new Object(), { alignment: DialogAlignment.Center });
          })
      }
      .justifyContent(FlexAlign.End)
      .padding({
        left: $r('app.float.padding'),
        right: $r('app.float.padding'),
        bottom: $r('app.float.padding')
      })
      .width('100%')
      .height('100%')
    }
    .title(getResourceString($r('app.string.dialog'), this))
  }
}
// [End dialog_component]