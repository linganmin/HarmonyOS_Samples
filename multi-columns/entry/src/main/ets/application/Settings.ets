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

import { getBottom, getLeft, getRight, getTop } from '../common/Constants';
import { MainItem } from '../common/SettingItem';
import { WlanItem } from '../common/WlanItem';
import { LengthMetrics, window } from '@kit.ArkUI';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let storage = uiContext?.getSharedLocalStorage();

@Entry(storage)
@Component
struct Settings {
  @State localPadding: LocalizedPadding = { top: LengthMetrics.vp(0), start: LengthMetrics.vp(0) };
  @StorageLink('cutout') @Watch('cutoutChange') avoidAreas: window.AvoidAreaOptions | undefined = undefined;
  @StorageLink('windowHeight') windowHeight: number = 0;
  @StorageLink('windowWidth') windowWidth: number = 0;
  @Provide('pathInfo') pathInfo: NavPathStack = new NavPathStack();
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = 'md';

  cutoutChange(): void {
    let topPX = getTop(this.avoidAreas);
    let rightPX = getRight(this.avoidAreas, this.windowWidth);
    let bottomPX = getBottom(this.avoidAreas, this.windowHeight);
    let leftPX = getLeft(this.avoidAreas);
    this.localPadding = {
      top: LengthMetrics.px(topPX),
      end: LengthMetrics.px(rightPX),
      bottom: LengthMetrics.px(bottomPX),
      start: LengthMetrics.px(leftPX)
    }
  }

  @Builder
  myRouter(name: string, param?: number | undefined) {
    if (name === 'wlanItem') {
      WlanItem()
    }
  }

  @Builder
  CustomDivider() {
    Divider()
      .strokeWidth('1px')
      .color($r('sys.color.ohos_id_color_list_separator'))
      .margin({ left: 8, right: 8 })
  }

  aboutToAppear() {
    if (this.currentWidthBreakpoint !== 'sm') {
      this.pathInfo.pushPath({ name: 'wlanItem' });
    }
  }

  build() {
    GridRow() {
      GridCol({ span: { sm: 12, md: 12, lg: 12 } }) {
        Navigation(this.pathInfo) {
          List({ space: 10 }) {
            ListItem() {
              Search({ placeholder: $r('app.string.search') })
                .backgroundColor($r('sys.color.white'))
            }
            .width('100%')
            .padding({ top: 8, bottom: 8 })

            ListItem() {
              MainItem({ isUserItem: true, src: $r('app.media.ic_mine_normal') })
                .backgroundColor($r('sys.color.white'))
                .borderRadius(20)
                .padding({ top: 12, bottom: 12 })
            }

            ListItem() {
              Column() {
                MainItem({
                  itemDesc: $r('app.string.WLAN'),
                  src: $r('app.media.wlan'),
                  itemStatusDesc: $r('app.string.closed')
                })
                  .onClick(() => {
                    this.pathInfo.pushPath({ name: 'wlanItem' });
                  })
                this.CustomDivider()
                MainItem({
                  itemDesc: $r('app.string.bluetooth'),
                  src: $r('app.media.blueTooth'),
                  itemStatusDesc: $r('app.string.closed')
                })
                this.CustomDivider()
                MainItem({ itemDesc: $r('app.string.mobileData'), src: $r('app.media.mobileData') })
                this.CustomDivider()
                MainItem({
                  itemDesc: $r('app.string.moreConnections'),
                  src: $r('app.media.ic_settings_more_connections')
                })
              }
              .width('100%')
              .borderRadius(24)
              .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'))
              .padding({ top: 4, bottom: 4 })
            }

            ListItem() {
              Column() {
                MainItem({ itemDesc: $r('app.string.desktopAndWallpaper'), src: $r('app.media.desk') })
                this.CustomDivider()
                MainItem({ itemDesc: $r('app.string.displayAndBrightness'), src: $r('app.media.displayAndBrightness') })
              }
              .width('100%')
              .borderRadius(24)
              .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'))
              .padding({ top: 4, bottom: 4 })
            }

            ListItem() {
              Column() {
                MainItem({ itemDesc: $r('app.string.soundAndVibration'), src: $r('app.media.volume') })
                this.CustomDivider()
                MainItem({ itemDesc: $r('app.string.notice'), src: $r('app.media.notify') })
                this.CustomDivider()
                MainItem({ itemDesc: $r('app.string.storage'), src: $r('app.media.storage') })
                this.CustomDivider()
                MainItem({ itemDesc: $r('app.string.safe'), src: $r('app.media.security') })
                this.CustomDivider()
                MainItem({ itemDesc: $r('app.string.privacy'), src: $r('app.media.privacy') })
              }
              .width('100%')
              .borderRadius(24)
              .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'))
              .padding({ top: 4, bottom: 4 })
            }

            ListItem() {
              Column() {
                MainItem({ itemDesc: $r('app.string.userAccounts'), src: $r('app.media.userAccounts') })
                this.CustomDivider()
                MainItem({ itemDesc: $r('app.string.system'), src: $r('app.media.system') })
                this.CustomDivider()
                MainItem({ itemDesc: $r('app.string.aboutDevice'), src: $r('app.media.aboutDevice') })
              }
              .width('100%')
              .borderRadius(24)
              .backgroundColor($r('sys.color.ohos_id_color_foreground_contrary'))
              .padding(4)
            }
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
          .padding({ left: 12, right: 12 })
        }
        .width('100%')
        .height('100%')
        .navBarWidth(293)
        .title($r('app.string.settings'))
        .backgroundColor($r('sys.color.background_secondary'))
        .padding({ top: AppStorage.get<number>('statusBarHeight') })
        .navDestination(this.myRouter)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ left: this.getUIContext().px2vp(getLeft(this.avoidAreas)) })
  }
}