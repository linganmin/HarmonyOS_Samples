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

import { Item, messageObj } from '../common/CommonConstants';

@Component
export struct ChatPage {
  private scroller: Scroller = new Scroller();
  @State messageList: Array<string> = [];
  @State inputMessage: string = '';
  @State isRefreshing: boolean = false;
  pathStack: NavPathStack = new NavPathStack();
  @State itemInfo: Item = {
    id: 0,
    image: $r('app.media.Public_avatar'),
    name: '',
    message: [],
    isNewMessage: false,
    time: '',
    isTop: false
  };
  @State itemMessage: messageObj[] = [];
  @State showItemMessage: messageObj[] = [];
  @State startIndex: number = 0;

  getLastTenElements(arr: messageObj[]) {
    this.startIndex = Math.max(0, this.startIndex -= 10);
    // Ensure that the array exists and its length is greater than or equal to 10.
    if (!Array.isArray(arr) || arr.length < 10 || this.startIndex === 0) {
      this.showItemMessage = arr;
      return;
    }
    // Use the slice() method to extract the last 10 elements.
    const lastTenElements = arr.slice(this.startIndex, this.startIndex + 10);
    this.showItemMessage.unshift(...lastTenElements);
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          // [Start Refresh]
          Refresh({ refreshing: $$this.isRefreshing }) {
            // [Start initialIndex_scrollEdge]
            List({ space: 10, scroller: this.scroller, initialIndex: this.itemInfo.message.length - 1 }) {
              ForEach(this.showItemMessage, (item: messageObj, index: number) => {
                ListItem() {
                  if (item.sender === 'others') {
                    Row() {
                      Image(this.itemInfo.image)
                        .width(36)
                        .height(36)
                        .margin({ right: 8 })

                      Text(item.msg)
                        .fontSize(16)
                        .constraintSize({ maxWidth: '70%' })
                        .backgroundColor('#F1F3F5')
                        .borderRadius(12)
                        .padding({
                          top: 8,
                          bottom: 8,
                          left: 12,
                          right: 12
                        })
                    }
                    .width('100%')
                    .constraintSize({ minHeight: 48 })
                    .justifyContent(FlexAlign.Start)
                  } else {
                    Row() {
                      Text(item.msg)
                        .fontSize(16)
                        .backgroundColor('#F1F3F5')
                        .borderRadius(12)
                        .padding({
                          top: 8,
                          bottom: 8,
                          left: 12,
                          right: 12
                        })
                      Image($r('app.media.Public_avatar'))
                        .width(36)
                        .height(36)
                        .margin({ left: 8 })
                    }
                    .width('100%')
                    .height(48)
                    .justifyContent(FlexAlign.End)
                  }
                }
              })
            }
            .onAppear(() => {
              // Initialize display to the bottom.
              this.scroller.scrollEdge(Edge.Bottom);
            })
            // [End initialIndex_scrollEdge]
            .scrollBar(BarState.Off)
            .contentEndOffset(8)
            .width('100%')
            .height('100%')
          }
          .width('100%')
          .height('100%')
          .refreshOffset(64)
          .pullToRefresh(true)
          .onRefreshing(() => {
            setTimeout(() => {
              this.getLastTenElements(this.itemMessage);
              this.isRefreshing = false;
            }, 1500)
          })

          // [End Refresh]
        }
        .width('100%')
        .height('calc(100% - 80vp)')
        .padding({
          left: 16,
          right: 16
        })
        .justifyContent(FlexAlign.Start)
        .expandSafeArea([SafeAreaType.KEYBOARD])

        Column() {
          Row() {
            Row({ space: 12 }) {
              Image($r('app.media.mic_filled'))
                .width(28)
                .height(28)

              Image($r('app.media.emoji'))
                .width(28)
                .height(28)
            }

            // [Start TextInput]
            TextInput({ placeholder: 'input your word...', text: this.inputMessage })
              .height(40)
              .width(200)
              .margin({
                left: 12,
                right: 12
              })
              .onBlur(() => {
                this.scroller.scrollEdge(Edge.Bottom);
              })
              .onChange((value) => {
                this.inputMessage = value;
              })
            // [End TextInput]

            Row() {
              Row({ space: 12 }) {
                Image($r('app.media.plus_circle'))
                  .width(28)
                  .height(28)
                // [Start SendMessage]
                Image(this.inputMessage === '' ? $r('app.media.send_off') : $r('app.media.send_on'))
                  .width(28)
                  .height(28)
                  .onClick(() => {
                    if (this.inputMessage.trim() === '') {
                      return;
                    }
                    this.itemMessage.push({
                      sender: 'myself',
                      msg: this.inputMessage
                    });
                    this.showItemMessage = this.itemMessage.slice(-10);
                    this.scroller.scrollEdge(Edge.Bottom);
                    this.inputMessage = '';
                  })
                // [End SendMessage]
              }
            }
          }
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .padding({
          top: 8,
          bottom: 8
        })
        .backgroundColor('#F1F3F5')
        .width('100%')
        .height(80)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .title(this.itemInfo.name)
    .height('100%')
    .width('100%')
    .onReady((content: NavDestinationContext) => {
      this.itemInfo = JSON.parse(JSON.stringify(content.pathInfo.param));
      this.itemMessage = this.itemInfo.message;
      this.startIndex = this.itemMessage.length - 10;
      this.showItemMessage = this.itemMessage.slice(-10);
    })
  }
}