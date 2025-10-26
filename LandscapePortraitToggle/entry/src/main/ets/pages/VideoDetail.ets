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

import { VideoPlayView } from '../views/VideoPlayView';
import { BottomView } from '../views/BottomView';
import { RelatedListView } from '../views/RelatedListView';
import { CommentsView } from '../views/CommentsView';

@Entry
@Component
struct VideoDetail {
  build() {
    Column() {
      VideoPlayView()

      Scroll() {
        Column() {
          RelatedListView()
          CommentsView()
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .padding({ bottom: 16 })

      BottomView()
    }
    .height('100%')
    .width('100%')
    .backgroundColor(Color.White)
  }
}