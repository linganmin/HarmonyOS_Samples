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

import { AvplayerView } from '../view/AvplayerView';
import { WatchLiveDecorationView } from '../view/WatchLiveDecorationView';

@Builder
export function WatchLiveStreamBuilder() {
  WatchLiveStream();
}

export class CommentDataModel {
  public name: string | Resource = '';
  public comment: string | Resource = '';
}

@Component
struct WatchLiveStream {
  @Consume('pageStack') pageStack: NavPathStack;
  @State liveList: Array<CommentDataModel> = [];
  @State isLiked: boolean = false;
  @State filePath: string = '';
  @State isFollowed: boolean = false;
  scroller: Scroller = new Scroller();

  build() {
    NavDestination() {
      Stack() {
        AvplayerView({
          filePath: this.filePath
        })

        WatchLiveDecorationView({
          isFollowed: this.isFollowed,
          isLiked: this.isLiked,
          liveList: this.liveList
        })
          .hitTestBehavior(HitTestMode.Transparent)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.Black)
    }
    .onBackPressed(() => {
      this.pageStack.pop();
      return true;
    })
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.filePath = context.pathInfo.param as string;
    })
    .expandSafeArea()
  }
}