/*
 *
 *  * Copyright (c) 2025 Huawei Device Co., Ltd.
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */

import { CommonConstants as Const } from 'common';

@CustomDialog
export default struct UserPrivacyDialog {
  controller: CustomDialogController = new CustomDialogController({ builder: '' });
  cancel: Function = () => {
  };
  confirm: Function = () => {
  };

  build() {
    Column() {
      Text($r('app.string.privacy_title'))
        .fontFamily(Const.HARMONY_HEI_TI)
        .fontWeight(FontWeight.Normal)
        .fontColor($r(`sys.color.font_primary`))
        .fontSize($r('app.float.default_14'))
        .width(Const.THOUSANDTH_1000)
        .lineHeight($r('app.float.default_20'))
        .margin({
          top: $r('app.float.default_8')
        })

      Text($r('app.string.privacy_desc'))
        .fontFamily(Const.HARMONY_HEI_TI)
        .fontWeight(FontWeight.Normal)
        .fontColor($r(`sys.color.font_primary`))
        .fontSize($r('app.float.default_14'))
        .width(Const.THOUSANDTH_1000)
        .lineHeight($r('app.float.default_20'))
        .margin({
          top: $r('app.float.default_8')
        })
        .opacity($r('app.float.opacity_6'))

      Row() {
        Button($r('app.string.cancel'))
          .backgroundColor($r('sys.color.background_primary'))
          .fontColor($r('sys.color.comp_background_emphasize'))
          .onClick(() => {
            this.controller.close();
            this.cancel();
          })

        Divider()
          .vertical(true)
          .height($r('app.float.default_22'))
          .opacity($r('app.float.opacity_6'))

        Button($r('app.string.confirm'))
          .backgroundColor($r('sys.color.background_primary'))
          .fontColor($r('sys.color.comp_background_emphasize'))
          .onClick(() => {
            this.controller.close();
            this.confirm();
          })
      }
      .width(Const.THOUSANDTH_1000)
      .margin({
        top: $r('app.float.default_22')
      })
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .padding($r('app.float.default_16'))
  }
}