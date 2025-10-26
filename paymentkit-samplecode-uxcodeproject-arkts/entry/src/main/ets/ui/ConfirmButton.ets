/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

@Component
@Preview
export struct ConfirmButton {
  @Prop text: ResourceStr = '';

  build() {
    Column() {
      Row() {
        Button(this.text) {
          Row() {
            Text(this.text)
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
              .fontFamily('HarmonyHeiTi-Medium')
              .fontColor($r('sys.color.ohos_fa_text_contrary'))
              .textAlign(TextAlign.Center)
              .textOverflow({
                overflow: TextOverflow.Ellipsis
              })
              .maxLines(1)
          }
          .alignItems(VerticalAlign.Center)
          .justifyContent(FlexAlign.Center)
        }
        .focusOnTouch(true)
        .type(ButtonType.Normal)
        .borderRadius(20)
        .backgroundColor($r('sys.color.ohos_id_color_floating_button_bg_normal'))
        .constraintSize({
          minWidth: '100%',
          maxWidth: '100%',
          minHeight: 40,
          maxHeight: 40,
        })
        .padding({
          top: 4,
          bottom: 4,
          left: 16,
          right: 16,
        })
        .opacity(1)
        .stateEffect(true)
      }
      .onClick(() => {
        // Button click event
      })
    }.width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}