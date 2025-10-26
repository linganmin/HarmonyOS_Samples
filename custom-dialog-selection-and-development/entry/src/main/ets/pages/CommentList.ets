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

import { NavigationDialog } from './NavigationDialog';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { PromptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

class Person {
  image: ResourceStr = '';
  nickName: ResourceStr = '';
  comment: ResourceStr = '';
  place: ResourceStr = '';
  number: string = '';
}

let personList: Array<Person> = [
  {
    image: $r('app.media.friend_1'),
    nickName: $r('app.string.nick_name_1'),
    comment: $r('app.string.comment_1'),
    place: $r('app.string.place_1'),
    number: '876'
  },
  {
    image: $r('app.media.friend_2'),
    nickName: $r('app.string.nick_name_2'),
    comment: $r('app.string.comment_2'),
    place: $r('app.string.place_2'),
    number: '323'
  },
  {
    image: $r('app.media.friend_1'),
    nickName: $r('app.string.nick_name_3'),
    comment: $r('app.string.comment_3'),
    place: $r('app.string.place_3'),
    number: '666'
  },
  {
    image: $r('app.media.friend_2'),
    nickName: $r('app.string.nick_name_4'),
    comment: $r('app.string.comment_4'),
    place: $r('app.string.place_4'),
    number: '999'
  },
  {
    image: $r('app.media.friend_1'),
    nickName: $r('app.string.nick_name_5'),
    comment: $r('app.string.comment_5'),
    place: $r('app.string.place_5'),
    number: '111'
  },
  {
    image: $r('app.media.friend_1'),
    nickName: $r('app.string.nick_name_1'),
    comment: $r('app.string.comment_1'),
    place: $r('app.string.place_1'),
    number: '876'
  },
  {
    image: $r('app.media.friend_2'),
    nickName: $r('app.string.nick_name_2'),
    comment: $r('app.string.comment_2'),
    place: $r('app.string.place_2'),
    number: '323'
  }
];

@Component
export struct CommentList {
  uiContext: UIContext = this.getUIContext();
  promptAction: PromptAction = this.uiContext.getPromptAction();

  private operateButtonIcons: Resource[] = [
    $r('app.media.paper_plane')
  ]
  @Consume('NavPathStack') pageStack: NavPathStack;

  aboutToDisappear(): void {
    AppStorage.setOrCreate('commentListHeight', 0);
  }

  closeCommentList = () => {
    this.pageStack.pop();
  }
  onCommentListAreaChange = (oldArea: Area, newArea: Area) => {
    AppStorage.setOrCreate('commentListHeight', newArea.height);
    hilog.info(0x0001, "dialog", JSON.stringify(oldArea));
  }

  @Builder
  TitleBar() {
    Row() {
      Text($r('app.string.comment_list_title'))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
      Blank()
      Button() {
        Image($r('app.media.cancel'))
          .width(18)
      }
      .padding(10)
      .backgroundColor('rgba(0, 0, 0, 0.05)')
      .onClick(this.closeCommentList)
    }
    .padding(15)
    .width('100%')
  }

  @Builder
  ToolBar() {
    Row({ space: 10 }) {
      Button($r('app.string.comment_button_text'))
        .layoutWeight(1)
        .align(Alignment.Start)
        .backgroundColor('rgba(0, 0, 0, 0.05)')
        .fontColor('rgba(0, 0, 0, 0.6)')
        .onClick(()=>{
          this.promptAction.openToast({
            message: $r('app.string.ui_display'),
            duration: 3000,
          }).catch((error: BusinessError) => {
              hilog.error(0x0000,'CommentList',`openToast error code is ${error.code}, message is ${error.message}`);
            })
        })
      ForEach(this.operateButtonIcons, (icon: Resource) => {
        Image(icon)
          .width(24)
      })
    }
    .padding(10)
  }

  build() {
    NavigationDialog() {
      Column() {
        this.TitleBar()
        List() {
          ForEach(personList, (item: Person) => {
            ListItem() {
              Column() {
                Row() {
                  Row() {
                    Image(item.image)
                      .width(36)
                      .height(36)
                    Text(item.nickName)
                      .fontSize(14)
                      .margin({ left: 12 })
                  }

                  Row() {
                    Text(item.number)
                      .fontSize(12)
                      .fontColor(Color.Gray)
                    Image($r('app.media.heart'))
                      .width(16)
                      .height(16)
                      .margin({ left: 8 })
                  }
                }
                .width('100%')
                .justifyContent(FlexAlign.SpaceBetween)

                Column() {
                  Text(item.comment)
                    .margin({ left: 48 })
                  Text() {
                    Span(item.place)
                      .fontColor(Color.Gray)
                      .margin({ right: 8 })
                    Span($r('app.string.reply'))
                  }
                  .margin({ left: 48, top: 12 })
                  .fontSize(12)
                }
                .alignItems(HorizontalAlign.Start)
                .width('100%')
              }
              .height(100)
            }
          }, (item: Person) => JSON.stringify(item))
        }
        .padding({
          left: 16,
          right: 16
        })
        .width('100%')
        .height('auto')

        this.ToolBar()
      }
      .padding({ bottom: 32 })
      .borderRadius({
        topLeft: 16,
        topRight: 16
      })
      .backgroundColor(Color.White)
      .onAreaChange(this.onCommentListAreaChange)
    }
  }
}