/*
 *
 *  * Copyright (c) 2025 Huawei Device Co., Ltd.
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */

import { CommonConstants as Const } from 'common';
import { HomeTopComponent } from './home/HomeTopComponent';
import { TaskListComponent } from './home/TaskListComponent';
import { AchievementStore } from '../viewmodel/AchievementStore';
import { HomeStore, initCurrentDateInfo } from '../viewmodel/HomeStore';

const WHITE_COLOR_0X = 255;

@Component
export struct HomeComponent {
  @Provide('pathStack') pageStack: NavPathStack = new NavPathStack();
  @Provide homeStore: HomeStore = new HomeStore([], -1, '', []);
  @Consume achievementStore: AchievementStore;
  @State naviAlpha: number = 0;
  @State flag: boolean = false;
  private scroller: Scroller = new Scroller();
  private yOffset: number = 0;

  // change navigator alpha when scrolling the Scroll component
  onScrollAction() {
    this.yOffset = this.scroller.currentOffset().yOffset;
    if (this.yOffset > Const.DEFAULT_56) {
      this.naviAlpha = 1;
    } else {
      this.naviAlpha = this.yOffset / Const.DEFAULT_56;
    }
  }

  async aboutToAppear() {
    this.homeStore = await initCurrentDateInfo(new Date());
    this.flag = true;
  }

  build() {
    Navigation(this.pageStack) {
      if (this.flag) {
        Stack() {
          Text($r('app.string.healthy_life'))
            .fontFamily($r(Const.HARMONY_HEI_TI_MEDIUM))
            .fontWeight(FontWeight.Regular)
            .fontColor($r(`sys.color.font_primary`))
            .fontSize($r('app.float.default_24'))
            .width(Const.THOUSANDTH_1000)
            .height($r('app.float.default_56'))
            .padding({
              left: Const.THOUSANDTH_66
            })
            .position({
              x: $r('app.float.default_0'),
              y: $r('app.float.default_0')
            })
            .zIndex(Const.HOME_COMPONENT_Z_INDEX)
            .backgroundColor(`rgba(${WHITE_COLOR_0X},${WHITE_COLOR_0X},${WHITE_COLOR_0X},${this.naviAlpha})`)

          // top and task list area of enable scroll
          Scroll(this.scroller) {
            Column() {
              HomeTopComponent()

              Text($r('app.string.task_list'))
                .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
                .fontWeight(FontWeight.Regular)
                .fontColor($r(`sys.color.font_primary`))
                .fontSize($r('app.float.default_16'))
                .width(Const.THOUSANDTH_1000)
                .padding({
                  top: Const.THOUSANDTH_15,
                  bottom: Const.THOUSANDTH_15,
                  left: Const.THOUSANDTH_33
                })

              TaskListComponent()
            }
          }
          .width(Const.THOUSANDTH_1000)
          .height(Const.THOUSANDTH_1000)
          .align(Alignment.Top)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, {
            alwaysEnabled: false,
            effectEdge: EffectEdge.END
          })
          .onWillScroll(() => {
            this.onScrollAction();
          })

          Button({
            type: ButtonType.Circle,
            stateEffect: false
          }) {
            Image($r('app.media.ic_home_add'))
              .borderRadius(Const.BORDER_RADIUS_PERCENT_50)
          }
          .width($r('app.float.default_48'))
          .height($r('app.float.default_48'))
          .position({
            x: Const.THOUSANDTH_830,
            y: Const.THOUSANDTH_880
          })
          .zIndex(Const.HOME_COMPONENT_Z_INDEX)
          .onClick(() => {
            if (this.homeStore.checkCurrentDay()) {
              this.pageStack.pushPathByName('AddTaskComponent', '');
            }
          })
        }
        .width(Const.THOUSANDTH_1000)
        .height(Const.THOUSANDTH_1000)
        .backgroundColor($r('sys.color.background_secondary'));
      }
    }
    .mode(NavigationMode.Stack)
  }
}