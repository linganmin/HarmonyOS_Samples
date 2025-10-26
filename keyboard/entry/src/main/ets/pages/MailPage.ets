/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
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

import { CommonConstants as Const } from '../common/constants/CommonConstants';
import { KeyboardAvoidMode } from '@kit.ArkUI';

// [Start Mail_page]
@Component
export struct MailPage {
  // [StartExclude Mail_page]
  // [Start about_to_appear_set_keyboard_avoid_mode]
  aboutToAppear(): void {
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
  }

  aboutToDisappear(): void {
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET);
  }
  // [End about_to_appear_set_keyboard_avoid_mode]
  // [EndExclude Mail_page]

  build() {
    Column() {
      this.NavigationTitle()
      this.EmailContent()
      this.BottomToolbar()
    }
    // [StartExclude Mail_page]
    .width(Const.FULL_SIZE)
    .height(Const.FULL_SIZE)
    .backgroundColor("#F1F3F5")
    // [EndExclude Mail_page]
  }

  @Builder
  NavigationTitle() {
    Row() {
      // [StartExclude Mail_page]
      Row() {
        Image($r('app.media.arrow_left'))
          .width($r('app.float.image_height_24'))
          .height($r('app.float.image_height_24'))
          .margin({ right: $r('app.float.margin_16') })

        Text($r('app.string.new_email'))
          .fontSize($r('app.float.font_size_20'))
          .fontWeight(FontWeight.Bold)

      }
      Image($r('app.media.paperplane'))
        .width("24vp")
        .height("24vp")
      // [EndExclude Mail_page]
    }
    .width('100%')
    .height("56vp")
    // [StartExclude Mail_page]
    .margin({ top: Const.TOP_BAR_HEIGHT })
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({
      left: $r('app.float.padding_24'),
      right: $r('app.float.padding_24')
    })
    // [EndExclude Mail_page]
  }

  @Builder
  BottomToolbar() {
    Row({ space: 12 }) {
      // [StartExclude Mail_page]
      Image($r('app.media.folder'))
        .width($r('app.float.image_height_24'))
        .height($r('app.float.image_height_24'))
      Image($r('app.media.picture'))
        .width($r('app.float.image_height_24'))
        .height($r('app.float.image_height_24'))
      Image($r('app.media.arrow_up_circle'))
        .width($r('app.float.image_height_24'))
        .height($r('app.float.image_height_24'))
      Image($r('app.media.share'))
        .width($r('app.float.image_height_24'))
        .height($r('app.float.image_height_24'))
      // [EndExclude Mail_page]
    }
    .width('100%')
    .height("56vp")
    // [StartExclude Mail_page]
    .padding({ left: $r('app.float.padding_24'), right: $r('app.float.padding_24') })
    .border({
      width: { top: $r('app.float.border_weight_1') },
      color: '#E8EBED'
    })
    // [EndExclude Mail_page]
  }

  @Builder
  EmailContent() {
    Column() {
      // [StartExclude Mail_page]
      Row() {
        Text($r('app.string.from'))
          .fontColor($r('app.color.text_font_color'))
          .fontSize($r('app.float.font_size_16'))
        TextInput({ placeholder: Const.EMAIL_ADDRESS })
          .type(InputType.Email)
          .width(Const.FULL_SIZE)
          .backgroundColor($r('app.color.contact_background'))
      }
      .width('100%')
      .height("48vp")
      .border({
        width: { top: "1vp" },
        color: "#E8EBED"
      })

      Row() {
        Text("To")
          .fontColor("#6F7780")
          .fontSize("16vp")
        TextInput({ placeholder: Const.EMAIL_ADDRESS })
          .type(InputType.Email)
          .width(Const.FULL_SIZE)
          .backgroundColor("#F1F3F5")
      }
      .width(Const.FULL_SIZE)
      .height("48vp")
      .border({
        width: { top: "1vp" },
        color: "#E8EBED"
      })


      Row() {
        Text("Subject")
          .fontColor("#6F7780")
          .fontSize("16vp")
        TextInput({ placeholder: 'Subject' })
          .width('100%')
          .backgroundColor("#F1F3F5")
      }
      .width('100%')
      .height("48vp")
      .border({
        width: { top: "1vp" },
        color: "#E8EBED"
      })

      Row() {
        TextArea({ placeholder: 'Entry content' })
          .height('100%')
          .backgroundColor("#F1F3F5")
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Top)
      .width('100%')
      .margin({ top: "12vp" })
      // [EndExclude Mail_page]
    }
    .width('100%')
    .layoutWeight(1)
    // [StartExclude Mail_page]
    .padding({ left: $r('app.float.padding_24'), right: $r('app.float.padding_24')})
    .margin({ top: $r('app.float.margin_8') })
    // [EndExclude Mail_page]
  }
}
// [End Mail_page]