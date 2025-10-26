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

import { initTabTuData } from '../viewmodel/TabViewModel';
import { BottomTabModel } from '../viewmodel/TabItem';
import { Constants } from '../common/Constants';

@Entry
@Component
struct RudderStyleTab {
  @State tabArray: Array<BottomTabModel> = initTabTuData();
  @State currentIndex: number = 0;
  @State iconOffset: number = 0;
  @State initNumber: number = 0;
  private controller: TabsController = new TabsController();

  // [Start Builder_tab]
  @Builder
  Tab(selectImage: Resource, defaultImage: Resource, title: string | Resource, middleMode: boolean, index: number) {
    Column() {
      if (index === Constants.TAB_INDEX_TWO) {
        Image(defaultImage)
          .size({ width: 56, height: 56 })
          .offset({ y: -15 })
      } else {
        Image(this.currentIndex === index ? selectImage : defaultImage)
          .size({ width: 22, height: 22 })
          .offset({
            y: (this.currentIndex === index && this.currentIndex !== Constants.TAB_INDEX_TWO)
              ? this.iconOffset : this.initNumber
          })
          .objectFit(ImageFit.Contain)
          .animation({
            duration: Constants.ANIMATION_DURATION,
            curve: Curve.Ease,
            playMode: PlayMode.Normal
          })
      }

      if (!middleMode) {
        Text(title)
          .fontSize(10)
          .margin({ top: 6 })
          .fontColor(this.currentIndex === index ? '#3388ff' : '#E6000000')
      }
    }
    .padding({ top: 11 })
    .width('100%')
    .backgroundColor('#F3F4F5')
    .height(90)
    .translate({ y: 40 })
    .onClick(() => {
      if (index !== Constants.TAB_INDEX_TWO) {
        this.currentIndex = index;
        this.controller.changeIndex(index);
        this.iconOffset = Constants.ICON_Offset;
      }
    })
  }
  // [End Builder_tab]

  build() {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        // [Start Rudder_style_tab_tabs]
        Tabs({ barPosition: BarPosition.End, controller: this.controller }) {
          ForEach(this.tabArray, (item: BottomTabModel, index: number) => {
            if (index === Constants.TAB_INDEX_TWO) {
              TabContent()
              .backgroundColor(Color.White)
            } else {
              TabContent() {
                Row() {
                  Text(item.title)
                    .fontSize(30)
                }
                .height(300)
                .width('100%')
                .justifyContent(FlexAlign.Center)
              }
              .backgroundColor(Color.White)
            }
          }, (item: BottomTabModel, index: number) => JSON.stringify(item) + index)
        }
        // [End Rudder_style_tab_tabs]
        .scrollable(false)
        .barHeight(this.initNumber)
        .animationDuration(Constants.ANIMATION_DURATION)
        // [Start Rudder_style_tab_flex]
        Flex() {
          ForEach(this.tabArray, (item: BottomTabModel, index: number) => {
            this.Tab(item.selectImage, item.defaultImage, item.title, item.middleMode, index)
          }, (item: BottomTabModel, index: number) => JSON.stringify(item) + index)
        }
        // [End Rudder_style_tab_flex]
      }
    }
    .height('100%')
  }
}