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

@Component
export struct Comment {
  aboutToAppear(): void {
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
  }

  aboutToDisappear(): void {
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET);
  }

  listData: string[] = ['Comment1', 'Comment2', 'Comment3', 'Comment4'];

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        Column() {
          Text($r('app.string.comment_title'))
            .fontSize($r('app.float.font_size_20'))
            .fontWeight(FontWeight.Medium)
            .margin({ top: $r('app.float.margin_16') })
        }

        List() {
          ForEach(this.listData, (item: string) => {
            ListItem() {
              Row() {
                Image($r('app.media.avatar_purple'))
                  .width($r('app.float.image_height_40'))
                  .margin($r('app.float.margin_12'))
                Column() {
                  Text($r('app.string.commenter_name'))
                    .fontSize($r('app.float.font_size_16'))
                    .margin({ top: $r('app.float.margin_12') })
                    .fontColor(Color.Black)
                  Text($r('app.string.comment_time'))
                    .fontSize($r('app.float.font_size_14'))
                    .margin({ bottom: $r('app.float.margin_16') })
                    .fontColor(Color.Gray)
                  Text(item)
                    .fontSize($r('app.float.font_size_14'))
                    .margin({ bottom: $r('app.float.margin_8') })

                  Row() {
                    Image($r('app.media.like'))
                      .width($r('app.float.image_height_16'))
                      .height($r('app.float.image_height_16'))
                      .margin({ right: $r('app.float.margin_12') })
                    Image($r('app.media.dislike'))
                      .width($r('app.float.image_height_16'))
                      .height($r('app.float.image_height_16'))
                  }
                  .margin({ bottom: $r('app.float.margin_8') })
                }
                .alignItems(HorizontalAlign.Start)
              }
              .alignItems(VerticalAlign.Top)
            }
          }, (item: string) => item)
        }
        .divider({ strokeWidth: $r('app.float.border_weight_1'), color: $r('app.color.contact_background') })
        .scrollBar(BarState.Off)
        .height(Const.FULL_SIZE)
        .width(Const.FULL_SIZE)
        .layoutWeight(Const.LAYOUT_WEIGHT)

        Column() {
          TextInput({ placeholder: 'Please input content' })
            .height($r('app.float.text_height_40'))
            .width(Const.FULL_SIZE)
        }
        .padding({
          bottom: $r('app.float.margin_24'),
          left: $r('app.float.margin_8'),
          right: $r('app.float.margin_8')
        })
      }
      .width(Const.FULL_SIZE)
      .height(Const.HEIGHT_OR_WIDTH_75)
      .backgroundColor(Color.White)
      .borderRadius({ topLeft: $r('app.float.border_radius_20'), topRight: $r('app.float.border_radius_20') })
    }
    .height(Const.FULL_SIZE)
    .width(Const.FULL_SIZE)
  }
}