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

@CustomDialog
export struct GenerateFile {
  cancel?: () => void;
  confirm?: () => void;
  controller: CustomDialogController;

  build() {
    Column() {
      Text($r('app.string.common_hint'))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 });
      Text($r('app.string.export_csv_hint'))
        .fontSize(16)
        .margin({ top: 20 })
        .width('90%')
        .textAlign(TextAlign.Center);

      Row() {
        Button($r('app.string.common_cancel'), { buttonStyle: ButtonStyleMode.TEXTUAL })
          .onClick(() => {
            this.controller.close();
            if (this.cancel) {
              this.cancel();
            }
          })
          .margin({
            top: 20,
            bottom: 20
          })
          .width('45%')
          .fontColor($r('app.color.primary_button'))
          .fontWeight(FontWeight.Bold);

        Button($r('app.string.common_confirm'), { buttonStyle: ButtonStyleMode.TEXTUAL })
          .onClick(() => {
            this.controller.close();
            if (this.confirm) {
              this.confirm();
            }
          })
          .margin({
            top: 20,
            bottom: 20
          })
          .width('45%')
          .fontColor($r('app.color.primary_button'))
          .fontWeight(FontWeight.Bold);
      };
    };
  }
}