/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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

import { DataCache } from '@hadss/datacache';
import ListPage from './ListPage';
import * as Const from '../common/constant/CommonConstants';
import { TabType } from '../common/types/CommonTypes';
import { common } from '@kit.AbilityKit';

@Component
export default struct TabBar {
  @State tabBarArray: TabType[] = Const.TAB_TYPES;
  @State currentIndex: number = 0;
  @State currentPage: number = 1;
  private controller: TabsController = new TabsController();
  context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  build() {
    Column() {
      Row() {
        Row() {
          ForEach(this.tabBarArray, (item: TabType, index: number) => {
            Text(item.name)
              .padding({ left: Const.TAB_PADDING, right: Const.TAB_PADDING })
              .fontSize(this.currentIndex === index ? Const.TAB_ACTIVE_FONT_SIZE : Const.TAB_FONT_SIZE)
              .fontWeight(this.currentIndex === index ? Const.TAB_ACTIVE_FONT_WEIGHT : Const.TAB_FONT_WEIGHT)
              .fontColor($r('app.color.tab_fontColor'))
              .onClick(() => {
                this.controller.changeIndex(index);
                this.currentIndex = index;
              })
          }, (item: TabType) => JSON.stringify(item));
        }
        Button($r('app.string.clear'))
          .padding({ left: Const.CLEAR_PADDING, right: Const.CLEAR_PADDING })
          .backgroundColor($r('app.color.transparent'))
          .borderColor($r('app.color.clear_fontcolor'))
          .borderWidth(Const.CLEAR_BORDER_WIDTH)
          .fontColor($r('app.color.clear_fontcolor'))
          .height(Const.CLEAR_HEIGHT)
          .fontSize(Const.CLEAR_FONT_SIZE)
          .fontWeight(Const.CLEAR_FONT_WEIGHT)
          .onClick(() => {
            DataCache.getInstance(this.context).clear().then(() => {
              this.getUIContext().getPromptAction().showToast({
                message: $r('app.string.clear_success'),
                duration: Const.ANIMATION_DURATION
              });
            });
          })
      }
      .position({ left: Const.LIST_MARGIN_LEFT as Dimension, top: 0})
      .zIndex(Const.TAB_Z_INDEX)
      .height(Const.TAB_HEIGHT)
      .align(Alignment.Start)
      .width(Const.LIST_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)

      Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
        ForEach(this.tabBarArray, () => {
          TabContent() {
            Column() {
              ListPage()
            }
          }
        }, (item: TabType) => `${item.id}`);
      }
      .barMode(BarMode.Scrollable)
      .barWidth(Const.FULL_WIDTH)
      .onAnimationStart((_: number, targetIndex: number) => {
        this.currentIndex = targetIndex;
        this.currentPage = 1;
      })
    }
  }
}