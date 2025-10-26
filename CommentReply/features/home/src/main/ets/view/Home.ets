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

import { HomeConstants } from "../constants/HomeConstants";
import { CommentKeyboard } from "./CommentKeyboard";
import { CommentList } from "./CommentList";
import { CommentSendDialog } from "./CommentSendDialog";
import { HomeContent } from "./HomeContent";

interface TabBar {
  icon?: Resource
  text?: ResourceStr
}

@Extend(Column)
function tabBarContainerStyle() {
  .width(HomeConstants.FULL_SIZE)
  .height(HomeConstants.FULL_SIZE)
  .justifyContent(FlexAlign.Center)
}

@Component
export struct Home {
  private tabBars: TabBar[] = [
    { text: HomeConstants.tabBarTitles[0] },
    { text: HomeConstants.tabBarTitles[1] },
    { icon: $r('app.media.add') },
    { text: HomeConstants.tabBarTitles[3] },
    { text: HomeConstants.tabBarTitles[4] }
  ]
  @State selectedTabIndex: number = 0
  @Provide navDialogPageInfos: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    this.navDialogPageInfos.disableAnimation(true)
  }

  @Builder
  TabBarTextBuilder(tabBarText: ResourceStr, tabIndex: number) {
    Column() {
      Text(tabBarText)
        .fontColor(Color.White)
        .opacity(
          this.selectedTabIndex === tabIndex ?
            $r('app.float.tab_bar_text_opacity_active') :
            $r('app.float.tab_bar_text_opacity')
        )
    }
    .tabBarContainerStyle()
  }

  @Builder
  TabBarIconBuilder(icon: Resource) {
    Column() {
      Image(icon)
        .width($r('app.float.tab_bar_icon_width'))
    }
    .tabBarContainerStyle()
  }

  @Builder
  NavDialogPageMap(name: string) {
    if (name === 'CommentKeyboard') {
      CommentKeyboard()
    } else if (name === 'CommentList') {
      CommentList()
    } else if (name === 'CommentSendDialog') {
      CommentSendDialog()
    }
  }

  onSelectedTabChange(index: number) {
    this.selectedTabIndex = index
  }
  // [Start home]
  // features/home/src/main/ets/view/Home.ets
  build() {
    Navigation(this.navDialogPageInfos) {
      // [StartExclude home]
      Tabs({ barPosition: BarPosition.End }) {
        ForEach(this.tabBars, (tabBar: TabBar, index) => {
          TabContent() {
            if (index === 0) {
              HomeContent()
            }
          }
          .tabBar(
            tabBar.icon ?
              this.TabBarIconBuilder(tabBar.icon) :
              this.TabBarTextBuilder(tabBar.text, index)
          )
        }, (tabBar: TabBar) => JSON.stringify(tabBar))
      }
      .barHeight(56)
      .backgroundColor(Color.Black)
      .padding({ bottom: 20 })
      .divider({ strokeWidth: 1, color: 'rgba(255, 255, 255, 0.20)' })
      .onChange((index: number) => {
        this.onSelectedTabChange(index)
      })
      // [EndExclude home]
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .navDestination(this.NavDialogPageMap)
  }
  // [End home]
}