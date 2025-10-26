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

/**
 *  最佳实践：点击响应优化
 */
import { OptChatItemView } from '../view/OptChatItemView';
import ChatModel from '../model/ChatModel';
import hiTraceMeter from '@ohos.hiTraceMeter';

@Entry
@Component
struct ChatListPage {
  @State private listData: ChatModel[] = []
  private COUNT: number = 128

  // [Start pagetransition]
  // Page A transition animation settings
  pageTransition() {
    PageTransitionEnter({ type: RouteType.None, duration: 400 })
      .slide(SlideEffect.Left)
    PageTransitionExit({ type: RouteType.None, duration: 400 })
      .slide(SlideEffect.Left)
  }

  // [End pagetransition]

  onPageShow() {
    hiTraceMeter.finishTrace("clickChat", 1);
  }

  randomData() {
    this.listData = []
    for (let i: number = 0; i < this.COUNT; i++) {
      this.listData.push(new ChatModel(i));
    }
  }

  aboutToAppear() {
    this.listData = []
    for (let i: number = 0; i < this.COUNT; i++) {
      this.listData.push(new ChatModel(i));
    }
  }

  build() {
    Column() {
      Stack() {
        Row() {
          Text('留言（' + this.listData.length + '）')
            .textAlign(TextAlign.Center)
            .fontSize(16)
            .border({ width: 0 })
            .padding(10)
            .height(65)
        }.width('100%').justifyContent(FlexAlign.Center)

        Row() {
          Image($r('app.media.ic_public_search'))
            .width(26).height(26)
            .fillColor('#99000000')
            .margin(10)
        }.width('100%').justifyContent(FlexAlign.End)
      }

      Divider().strokeWidth(1).color('#F1F3F5').opacity(0.8)
      Scroll() {
        Column() {
          ForEach(this.listData, (item: ChatModel) => {
            OptChatItemView({ itemData: item })
              .padding({
                left: 24,
                right: 24
              })
              .height(74)
            Divider().height(1).color('#F1F3F5').opacity(0.8).margin({ left: 72, right: 0 })
          }, (item: ChatModel) => JSON.stringify(item))
        }
      }
    }
  }
}
