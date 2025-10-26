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

import { Constants } from '../common/Constants';

@Entry
@Component
struct DrawerTab {
  @State navList: Array<number> = [0, 1, 2, 3, 4, 5];
  @State active: number = 0;
  @State show: boolean = false;

  build() {
    // [Start Drawer_tab_side_bar_container]
    SideBarContainer(SideBarContainerType.Overlay) {
      // [Start Drawer_tab_side_bar_container_other]
      Column() {
        // [StartExclude Drawer_tab_side_bar_container]
        ForEach(this.navList, (item: number, index: number) => {
          Column() {
            Row() {
              Image(this.active === item ? $r('app.media.activeList') : $r('app.media.list'))
                .width(24)
                .height(24)
              Text($r('app.string.list_name'))
                .fontSize(16)
                .fontColor(Color.Black)
                .fontWeight(FontWeight.Medium)
                .margin({ left: 17 })
            }
            .height(48)
            .width('100%')

            if (this.navList.length - 1 !== index) {
              Row()
                .height(0.5)
                .backgroundColor('#0D000000')
                .width('90%')
            }
          }
          .onClick(() => {
            this.active = item;
          })
          .margin({
            top: 4,
            left: 4,
            right: 4,
            bottom: 4
          })
          .justifyContent(FlexAlign.Center)
          .width(264)
          .height(48)
          .padding({ left: 13 })
          .borderRadius(16)
          .backgroundColor(this.active === item ? '#1A0A59F7' : '')
        }, (item: number, index: number) => JSON.stringify(item) + index)

        Row() {
          Image($r('app.media.add'))
            .width(40)
            .height(40)
          Text($r('app.string.add_list')).margin({ left: 8 })
        }
        .width('100%')
        .margin({ top: 284 })
        // [EndExclude Drawer_tab_side_bar_container]
      }
      .height('100%')
      .padding({ top: 104 })
      .backgroundColor('#E9EAEC')
      .width(272)
      .height(344)
      .backgroundColor(Color.White)
      .borderRadius(20)
      // [End Drawer_tab_side_bar_container_other]
      Column() {
        // [StartExclude Drawer_tab_side_bar_container]
        Text($r('app.string.content'))
          .width('100%')
          .height('100%')
          .fontSize(30)
          .textAlign(TextAlign.Center)
          .fontColor(Color.Black)
        // [EndExclude Drawer_tab_side_bar_container]
      }
      .onClick(() => {
        this.getUIContext().animateTo({
          duration: Constants.ANIMATION_DURATION,
          curve: Curve.EaseOut,
          playMode: PlayMode.Normal,
        }, () => {
          this.show = false;
        })
      })
      .width('100%')
      .height('110%')
      .backgroundColor(this.show ? '#c1c2c4' : '')
    }
    .showSideBar(this.show)
    .controlButton({
      left: 16,
      top: 48,
      height: 40,
      width: 40,
      icons: {
        shown: $r('app.media.changeBack'),
        hidden: $r('app.media.change'),
        switching: $r('app.media.change')
      }
    })
    .onChange((value: boolean) => {
      this.show = value;
    })
    // [End Drawer_tab_side_bar_container]
    .sideBarWidth('85%')
    .minSideBarWidth('85%')
    .width('100%')
    .height('110%')
    .translate({ y: -40 })
  }
}