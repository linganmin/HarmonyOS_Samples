/*
 *   Copyright (c) 2024 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

@Component
export struct ConfirmDialog {
  title: string = '';
  content: string = '';
  leftButtonName: string = '';
  rightButtonName: string = '';
  leftButtonFunc = () => { };
  rightButtonFunc = () => { };

  build() {
    Column() {
      Text(this.title)
        .fontSize(25)
        .fontWeight(FontWeight.Bold)
        .margin({top: 20});
      Text(this.content)
        .fontSize(15)
        .fontColor($r('app.color.confirm_dialog_text_font_color'))
        .margin({top: 30, bottom: 30});
      Row() {
        Button(this.leftButtonName, {buttonStyle: ButtonStyleMode.TEXTUAL})
          .width('45%')
          .fontColor($r('app.color.confirm_dialog_button_font_color_1'))
          .fontSize(18)
          .onClick(this.leftButtonFunc);

        Divider().vertical(true).height(22).color($r('app.color.app_page_background')).opacity(0.3);

        Button(this.rightButtonName, {buttonStyle: ButtonStyleMode.TEXTUAL})
          .width('45%')
          .fontColor($r('app.color.confirm_dialog_button_font_color_2'))
          .fontSize(18)
          .onClick(this.rightButtonFunc);
      }
      .margin({bottom: 20})
      .borderRadius(40);
    }
    .width(328)
    .backgroundColor($r('app.color.confirm_dialog_background_color'))
    .borderRadius(20);
  }
}