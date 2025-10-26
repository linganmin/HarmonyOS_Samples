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

import { ICardInfo } from '../model/DataModel';

@Builder
function PageBuilder() {
  PageComponent()
}

@Component
struct PageComponent {
  @Consume('pageInfos') pageInfos: NavPathStack;
  cardList: ICardInfo[] = [];

  aboutToAppear(): void {
    this.cardList = [
      {
        'pageName': 'SequentialRecognition',
        'pageTitle': $r('app.string.sequential_recognition'),
      },
      {
        'pageName': 'CustomGestureJudgment',
        'pageTitle': $r('app.string.custom_gesture_judgment'),
      }
    ]
  }

  @Builder
  card(item: ICardInfo) {
    Column() {
      Button(item.pageTitle)
        .width('100%')
        .fontWeight(500)
        .fontSize(16)
        .margin({ top: 12 })
        .onClick(() => {
          this.pageInfos.pushPath({ name: item.pageName });
        })
    }
  }

  build() {
    NavDestination() {
      Column() {
        List({ space: 24 }) {
          ForEach(this.cardList, (item: ICardInfo) => {
            ListItem() {
              this.card(item);
            }
          }, (item: ICardInfo) => item.pageName)
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 16,
        right: 16,
        top: 20,
        bottom: 10
      })
    }
    .title($r('app.string.gesture_events'))
  }
}