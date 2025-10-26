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
import { Chat, chatList } from '../viewmodel/ChatData';

// [Start Contact_page]
@Entry
@Component
export struct ContactPage {
  // [StartExclude Contact_page]
  @State avatar: Resource | undefined = undefined;
  @State name: string = '';
  @Consume('NavPathStack') pageStack: NavPathStack;
  // [EndExclude Contact_page]

  build() {
    Row() {
      Column() {
        Row() {
          // [StartExclude Contact_page]
          Row() {
            Image($r('app.media.arrow_left'))
              .height($r('app.float.image_height_24'))
              .margin({
                bottom: $r('app.float.margin_16'),
                right: $r('app.float.margin_16')
              })
              .onClick(() => {
                this.pageStack.pop();
              })

            Text(this.name)
              .width($r('app.float.text_width'))
              .height($r('app.float.text_height_28'))
              .fontSize($r('app.float.font_size_20'))
              .fontWeight(Const.FONT_WEIGHT_700)
              .fontColor($r('app.color.contact_font_color'))
              .margin({ bottom: $r('app.float.margin_15') })
          }
          .width(Const.FULL_SIZE)
          .height($r('app.float.top_bar_height'))
          .alignItems(VerticalAlign.Bottom)
          .padding({ left: $r('app.float.padding_24') })
          // [EndExclude Contact_page]
        }
        // [StartExclude Contact_page]
        .width("100%")
        // [EndExclude Contact_page]
        .height('12%')
        // [StartExclude Contact_page]
        .alignItems(VerticalAlign.Bottom)
        // [EndExclude Contact_page]
        .expandSafeArea([SafeAreaType.KEYBOARD])
        .zIndex(1)
        // [StartExclude Contact_page]
        .backgroundColor($r('app.color.contact_background'))
        // [EndExclude Contact_page]

        List() {
          // [StartExclude Contact_page]
          ForEach(chatList, (item: Chat) => {
            ListItem() {
              Row() {
                if (item.sender === 'others') {
                  Image(this.avatar)
                    .height($r('app.float.image_height_40'))
                    .margin({ right: $r('app.float.margin_8') })

                  Row() {
                    Text(item.message)
                      .fontSize($r('app.float.font_size_16'))
                      .lineHeight($r('app.float.line_height'))
                  }
                  .width(item.message.length > Const.MESSAGE_LENGTH_13 ?
                  $r('app.float.chat_width') : `${Const.FONT_WIDTH * item.message.length + Const.PADDING}` + Const.VP)
                  .height(item.message.length > Const.MESSAGE_LENGTH_26 ?
                  $r('app.float.chat_height_line3') :
                    (item.message.length > Const.MESSAGE_LENGTH_13 ? $r('app.float.chat_height_line2') :
                    $r('app.float.chat_height_line1')))
                  .borderRadius({
                    topLeft: $r('app.float.border_radius_4'),
                    topRight: $r('app.float.border_radius_24'),
                    bottomLeft: $r('app.float.border_radius_24'),
                    bottomRight: $r('app.float.border_radius_24')
                  })
                  .padding({
                    top: $r('app.float.padding_8'),
                    bottom: $r('app.float.padding_8'),
                    left: $r('app.float.padding_12'),
                    right: $r('app.float.padding_12')
                  })
                  .backgroundColor(Color.White)
                } else {
                  Row() {
                    Text(item.message)
                      .fontSize($r('app.float.font_size_16'))
                      .lineHeight($r('app.float.line_height'))
                  }
                  .width(item.message.length > Const.MESSAGE_LENGTH_39 ?
                  $r('app.float.chat_width') : `${Const.FONT_WIDTH * item.message.length + Const.PADDING}` + Const.VP)
                  .height(item.message.length > Const.MESSAGE_LENGTH_78 ?
                  $r('app.float.chat_height_line3') :
                    (item.message.length > Const.MESSAGE_LENGTH_39 ? $r('app.float.chat_height_line2') :
                    $r('app.float.chat_height_line1')))
                  .borderRadius({
                    topLeft: $r('app.float.border_radius_4'),
                    topRight: $r('app.float.border_radius_24'),
                    bottomLeft: $r('app.float.border_radius_24'),
                    bottomRight: $r('app.float.border_radius_24')
                  })
                  .padding({
                    top: $r('app.float.padding_8'),
                    bottom: $r('app.float.padding_8'),
                    left: $r('app.float.padding_12'),
                    right: $r('app.float.padding_12')
                  })
                  .margin({ right: $r('app.float.margin_8') })
                  .backgroundColor($r('app.color.chat_background'))

                  Image($r('app.media.avatar_blue'))
                    .height($r('app.float.image_height_40'))
                }
              }
              .width(Const.FULL_SIZE)
              .height(item.message.length > Const.MESSAGE_LENGTH_26 ?
              $r('app.float.chat_height_line3') :
                (item.message.length > Const.MESSAGE_LENGTH_13 ? $r('app.float.chat_height_line2') :
                $r('app.float.chat_height_line1')))
              .justifyContent(item.sender === 'others' ? FlexAlign.Start : FlexAlign.End)
            }
            .width(Const.FULL_SIZE)
            .margin({ bottom: $r('app.float.margin_12') })
          }, (item: Chat) => JSON.stringify(item))
          // [EndExclude Contact_page]
        }
        .height('76%')
        // [StartExclude Contact_page]
        .width("100%")
        .padding({
          left: $r('app.float.padding_12'),
          right: $r('app.float.padding_12')
        })
        // [EndExclude Contact_page]

        Column() {
          // [StartExclude Contact_page]
          Row() {
            TextInput()
              .width(Const.TEXT_INPUT_WIDTH)
              .height($r('app.float.text_input_height'))
              .margin({ right: $r('app.float.margin_16') })

            Image($r('app.media.ic_send'))
              .height($r('app.float.image_height_24'))
              .opacity(Const.OPACITY)
              .onClick(() => {
                this.getUIContext().getPromptAction().showToast({
                  message: $r('app.string.prompt_text2'),
                  duration: Const.DURATION
                })
              })
          }
          .width(Const.FULL_SIZE)
          .height($r('app.float.top_bar_height'))
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({
            top: $r('app.float.padding_8'),
            left: $r('app.float.padding_24'),
            right: $r('app.float.padding_16')
          })
          // [EndExclude Contact_page]
        }
        .height('12%')
        // [StartExclude Contact_page]
        .width("100%")
        .borderRadius($r('app.float.border_radius_20'))
        .backgroundColor(Color.White)
        // [EndExclude Contact_page]
      }
      .width('100%')
      // [StartExclude Contact_page]
      .height("100%")
      .backgroundColor($r('app.color.contact_background'))
      // [EndExclude Contact_page]
    }
    .height('100%')
  }
}
// [End Contact_page]
