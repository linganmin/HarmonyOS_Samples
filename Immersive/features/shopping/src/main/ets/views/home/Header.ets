/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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

import { NAV_BAR_TEXTS } from '../../constants/Home';

@Component
export struct Header {
  @Builder
  NavBar() {
    List({ space: 14 }) {
      ForEach(NAV_BAR_TEXTS, (text: string, index: number) => {
        ListItem() {
          Text(text)
            .fontSize(index === 0 ? 24 : 18)
            .fontWeight(index === 0 ? 500 : FontWeight.Normal)
            .fontColor(index === 0 ? Color.Black : '#99000000')
        }
      }, (text: string) => text)
    }
    .width('100%')
    .height(50)
    .scrollBar(BarState.Off)
    .listDirection(Axis.Horizontal)
    .alignListItem(ListItemAlign.Center)
  }

  @Builder
  SearchBar() {
    Row() {
      TextInput({ placeholder: 'search...' })
        .layoutWeight(1)
      Image($r('app.media.ic_public_scan'))
        .width(24)
        .height(24)
        .margin({ left: 16 })
      Image($r('app.media.ic_public_comments'))
        .width(24)
        .height(24)
        .margin({ left: 16 })
    }
    .width('100%')
    .height(50)
  }

  build() {
    GridRow() {
      GridCol({ span: { sm: 12, md: 7 } }) {
        this.NavBar()
      }
      GridCol({ span: { sm: 12, md: 5 } }) {
        this.SearchBar()
      }
    }
  }
}