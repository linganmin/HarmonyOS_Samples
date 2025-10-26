/*
* Copyright (C) 2025 Huawei Device Co., Ltd.
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
import { Contact, contactList, contactIndex } from '../viewmodel/ContactData';

@Component
export struct ChatListPage {
  @Consume('NavPathStack') pageStack: NavPathStack;
  @State isSearch: boolean = false;

  build() {
    Row() {
      Column() {
        Row() {
          Row() {
            if (!this.isSearch) {
              Text($r('app.string.Address_book'))
                .height($r('app.float.text_height_33'))
                .fontSize($r('app.float.font_size_24'))
                .fontWeight(Const.FONT_WEIGHT_700)
                .fontColor($r('app.color.contact_font_color'))
                .margin({ bottom: $r('app.float.margin_11') })

              Image($r('app.media.ic_search'))
                .height($r('app.float.image_height_24'))
                .margin({ bottom: $r('app.float.margin_16') })
                .onClick(() => {
                  this.isSearch = !this.isSearch;
                })
            } else {
              Image($r('app.media.arrow_left'))
                .height($r('app.float.image_height_24'))
                .margin({ bottom: $r('app.float.margin_16') })
                .onClick(() => {
                  this.isSearch = !this.isSearch;
                })

              Search({ placeholder: $r('app.string.Search_text') })
                .width($r('app.float.search_width'))
                .height($r('app.float.search_height'))
                .margin({ bottom: $r('app.float.margin_8') })
                .onSubmit(() => {
                  this.getUIContext().getPromptAction().showToast({
                    message: $r('app.string.prompt_text'),
                    duration: Const.DURATION
                  })
                })
            }
          }
          .width(Const.FULL_SIZE)
          .height($r('app.float.top_bar_height'))
          .alignItems(VerticalAlign.Bottom)
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({
            left: $r('app.float.padding_24'),
            right: $r('app.float.padding_24')
          })
        }
        .height(Const.TOP_BAR_HEIGHT)
        .alignItems(VerticalAlign.Bottom)

        Stack() {
          List() {
            ForEach(contactList, (item: Contact) => {
              ListItem() {
                Row() {
                  if (item.avatar !== undefined) {
                    Image(item.avatar)
                      .height($r('app.float.image_height_40'))
                      .margin({ right: $r('app.float.margin_12') })
                  }

                  Text(item.name)
                    .height(item.avatar === undefined ? $r('app.float.text_height_19') : $r('app.float.text_height_22'))
                    .fontSize(item.avatar === undefined ? $r('app.float.font_size_14') : $r('app.float.font_size_16'))
                    .fontWeight(Const.FONT_WEIGHT_500)
                    .fontColor($r('app.color.contact_font_color'))
                }
                .width(Const.FULL_SIZE)
                .height(item.avatar === undefined ? $r('app.float.row_height_48') : $r('app.float.row_height_64'))
              }
              .onClick(() => {
                if(!this.isSearch) {
                  if (item.avatar !== undefined) {
                    this.pageStack.pushPathByName('ContactPage', { avatar: item.avatar, name: item.name } as Contact)
                  }
                } else {
                  this.isSearch = !this.isSearch;
                }
              })
            }, (item: Contact) => JSON.stringify(item))
          }
          .width(Const.FULL_SIZE)
          .height(Const.LIST_HEIGHT_88)
          .padding({
            left: $r('app.float.padding_24'),
            right: $r('app.float.padding_24')
          })
          .backgroundColor(this.isSearch ? $r('app.color.list_background_color_search') : $r('app.color.contact_background'))

          List() {
            ForEach(contactIndex, (item: string) => {
              ListItem() {
                Text(item)
                  .fontSize($r('app.float.font_size_12'))
                  .fontColor(item === 'A' ? $r('app.color.index_font_color_selected') : Color.Gray)
                  .width($r('app.float.text_height_16'))
                  .height($r('app.float.text_height_16'))
                  .borderRadius($r('app.float.border_radius_4'))
                  .backgroundColor(item === 'A' ? $r('app.color.index_background_color_selected') : (this.isSearch ? $r('app.color.index_background_color_search') : Color.White))
                  .textAlign(TextAlign.Center)
              }
            })
          }
          .width($r('app.float.list_width'))
          .height($r('app.float.list_height'))
          .padding({
            left: $r('app.float.padding_4'),
            right: $r('app.float.padding_4')
          })
          .onClick(() => {
            if (this.isSearch) {
              this.isSearch = !this.isSearch;
            }
          })
        }
        .alignContent(Alignment.End)
      }
      .width(Const.FULL_SIZE)
    }
    .backgroundColor($r('app.color.contact_background'))
    .height(Const.FULL_SIZE)
  }
}
