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
import { MailNavigation } from '../common/MailNavigation';
import { MailSideBar } from '../common/MailSideBar';
import { LengthMetrics, window } from '@kit.ArkUI';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let storage = uiContext?.getSharedLocalStorage();

@Entry(storage)
@Component
struct MailBox {
  @State localPadding: LocalizedPadding = { top: LengthMetrics.vp(0), start: LengthMetrics.vp(0) };
  @StorageLink('cutout') @Watch('cutoutChange') avoidAreas: window.AvoidAreaOptions | undefined = undefined;
  @StorageLink('windowHeight') windowHeight: number = 0;
  @StorageLink('windowWidth') windowWidth: number = 0;
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = 'sm';
  @State isFold: boolean = false;
  @State sideBarWidth: number = 304;

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

  // [Start set_show_side_bar_build]
  build() {
    GridRow() {
      GridCol({ span: { sm: 12, md: 12, lg: 12 } }) {
        // [Start set_show_side_bar]
        SideBarContainer(SideBarContainerType.AUTO) {
          // Area A
          Column() {
            MailSideBar()
          }
          .width('100%')
          .height('100%')
          .backgroundColor($r('sys.color.gray_01'))

          // Area B+C
          Column() {
            Stack() {
              MailNavigation()
                .margin({ top: 18 })
                .padding({ left: this.getUIContext().px2vp(getLeft(this.avoidAreas)) })
              // [StartExclude set_show_side_bar]
              if (this.isFold && this.currentWidthBreakpoint !== 'lg') {
                Column()
                  .width('100%')
                  .height('100%')
                  .backgroundColor('#33000000')
              }
              // [EndExclude set_show_side_bar]
            }
          }
          .width('100%')
          .height('100%')
        }
        .showSideBar(this.currentWidthBreakpoint === 'lg')
        // [End set_show_side_bar]
        // [StartExclude set_show_side_bar_build]
        .sideBarWidth(this.sideBarWidth)
        .minSideBarWidth(240)
        .minContentWidth(this.currentWidthBreakpoint === 'sm' ? 360 : 600)
        .controlButton({
          left: 24,
          top: AppStorage.get<number>('statusBarHeight') as number + 18,
          width: 24,
          height: 24
        })
        .onChange((value: boolean) => {
          this.isFold = value;
        })
        // [EndExclude set_show_side_bar_build]
      }
    }
    .width('100%')
    .height('100%')
  }
  // [End set_show_side_bar_build]
}