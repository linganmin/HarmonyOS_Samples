/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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


import { ObservedArray } from '../utils/ObservedArray';
import { SongInfoItem } from '../model/LearningResource';
import { ArticleCardView } from '../components/ArticleCardView';
import Constants from '../constants/Constants';
import PageViewModel from '../components/PageViewModel';


@Entry
@Component
export struct ForEachListPage {
  @State articleList: SongInfoItem[] = PageViewModel.getItems();
  @State collectedIds: ObservedArray<string> = ['1', '2', '3', '4', '5', '6'];
  @State likedIds: ObservedArray<string> = ['1', '2', '3', '4', '5', '6'];
  @State isListReachEnd: boolean = false;

  isCollected(resourceId: string): boolean {
    return this.collectedIds.some((id: string) => id === resourceId);
  }

  isLiked(resourceId: string): boolean {
    return this.likedIds.some((id: string) => id === resourceId);
  }


  build() {
    Column() {
      Header()
      List({ space: Constants.SPACE_16 }) {
        ForEach(this.articleList, (item: SongInfoItem) => {
            ListItem() {
              Column({ space: Constants.SPACE_12 }) {
                ArticleCardView({ articleItem: item })
              }
            }
        })
      }
      .width(Constants.FULL_SCREEN)
      .height(Constants.FULL_SCREEN)
      .padding({ left: 10, right: 10 })
      .layoutWeight(1)
    }
    .backgroundColor($r('app.color.text_background'))
  }
}

@Builder
function Header() {
  Row() {
    Text($r('app.string.foreach'))
      .fontSize($r('app.float.header_font_size'))
      .fontWeight(FontWeight.Bold)
      .textAlign(TextAlign.Start)
      .width('100%')
      .fontFamily('HarmonyHeiTi-Bold')
      .padding({ left: $r('app.float.md_padding_margin') })
  }
  .height($r('app.float.top_navigation_height'))
  .margin({ top: $r('app.float.lg_padding_margin') })
}
