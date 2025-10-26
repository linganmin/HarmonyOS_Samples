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
import { Constants } from "../common/constant/Constants";

@Component
export default struct SearchBarComponent {
  @State changeValue: string = '';

  build() {
    Row() {
      Stack() {
        TextInput({ placeholder: $r('app.string.search_placeholder') })
          .height(40)
          .width(Constants.FULL_WIDTH)
          .fontSize(16)
          .placeholderColor(Color.Grey)
          .placeholderFont({ size: 16, weight: FontWeight.Normal })
          .borderStyle(BorderStyle.Solid)
          .backgroundColor($r('app.color.search_bar_input_color'))
          .padding({ left: 35, right: 66 })
          .onChange((currentContent) => {
            this.changeValue = currentContent;
          })
        Row() {
          Image($r('app.media.ic_search')).width(20).height(20)
          Button($r('app.string.search'))
            .padding({ left: 20, right: 20 })
            .height(36)
            .fontColor($r('app.color.search_bar_button_color'))
            .fontSize(16)
            .backgroundColor($r('app.color.search_bar_input_color'))

        }.width(Constants.FULL_WIDTH)
        .hitTestBehavior(HitTestMode.None)
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: 10, right: 2 })
      }.alignContent(Alignment.Start)
      .width(Constants.FULL_WIDTH)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({top:10,left:10,right:10})
    .width(Constants.FULL_WIDTH)
    .height('100%')
    .backgroundColor($r('app.color.out_tab_bar_background_color'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
}