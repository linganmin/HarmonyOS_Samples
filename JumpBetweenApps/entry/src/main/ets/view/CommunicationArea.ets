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

import { Message, MessageViewModel } from '../viewmodel/MessageViewModel';
import { MessageItem } from './MessageItem';

@Builder
function AppGalleryShareBox() {
  Row() {
    Column() {
      Text($r('app.string.huawei_reader'))
        .fontColor(Color.Black)
        .fontFamily('思源黑体')
        .fontSize(14)
        .fontWeight(500)
        .lineHeight(20)
        .letterSpacing(0)
        .textAlign(TextAlign.Start)
        .margin({ bottom: 8 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      Text($r('app.string.read_des'))
        .fontColor('rgba(0,0,0,0.6)')
        .fontFamily('思源黑体')
        .fontSize(12)
        .fontWeight(400)
        .lineHeight(17)
        .letterSpacing(0)
        .textAlign(TextAlign.Start)
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .height(92)
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .margin({ right: 12 })
    .layoutWeight(1)

    Image($r('app.media.hwread'))
      .width(93)
      .height(92)
      .borderRadius(12)
  }
  .width(210)
  .height(116)
  .padding({
    left: 11,
    top: 12,
    right: 10,
    bottom: 12
  })
}

@Builder
function NavigationMessageBox() {
  Stack() {
    Image($r('app.media.map'))
      .width(189)
      .height(103)
      .borderRadius(24)
      .objectFit(ImageFit.Cover)
    Image($r('app.media.position_cursor'))
      .width(35)
      .height(44.84)
  }
  .width(210)
  .height(127)
}

@Builder
function GoodsBox() {
  Column() {
    Text($r('app.string.goods_detail'))
      .fontColor(Color.Black)
      .fontFamily('思源黑体')
      .fontSize(12)
      .fontWeight(500)
      .lineHeight(17)
      .letterSpacing(0)
      .textAlign(TextAlign.Start)
    Row() {
      Text($r('app.string.goods_name'))
        .layoutWeight(1)
        .fontColor('rgba(0, 0, 0, 0.6)')
        .fontFamily('思源黑体')
        .fontSize(12)
        .fontWeight(500)
        .lineHeight(17)
        .letterSpacing(0)
        .textAlign(TextAlign.Start)
      Image($r('app.media.goods'))
        .width(61.84)
        .height(61.07)
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Bottom)
  }
  .width(210)
  .height(116)
  .padding({
    left: 11,
    top: 7,
    right: 14,
    bottom: 16
  })
}

@Component
export default struct CommunicationArea {
  UIContext = this.getUIContext()
  @State messages: Message[] = new MessageViewModel(this.UIContext).getMessages();
  private contentBuilders: Map<string, () => void> = new Map();

  aboutToAppear(): void {
    this.contentBuilders.set('001', AppGalleryShareBox);
    this.contentBuilders.set('002', NavigationMessageBox);
    this.contentBuilders.set('003', GoodsBox);
  }

  build() {
    Column() {
      List({ space: 24 }) {
        ForEach(this.messages, (message: Message) => {
          if (this.contentBuilders.has(message.getId())) {
            MessageItem({ message, contentBuilder: this.contentBuilders.get(message.getId()) })
          } else {
            MessageItem({ message })
          }
        }, (message: Message) => message.getId())
      }
      .width('100%')
      .height('100%')
      .padding({ left: 12, top: 124 })
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}