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

import { LengthMetrics, window } from '@kit.ArkUI';
import { getBottom, getLeft, getRight, getTop } from './Constants';
import { BreakpointType } from './BreakpointSystem';
import { MailContent } from './MailContent';

@Component
export struct MailNavigation {
  @State localPadding: LocalizedPadding = { top: LengthMetrics.vp(0), start: LengthMetrics.vp(0) };
  @StorageLink('cutout') @Watch('cutoutChange') avoidAreas: window.AvoidAreaOptions | undefined = undefined;
  @StorageLink('windowHeight') windowHeight: number = 0;
  @StorageLink('windowWidth') windowWidth: number = 0;
  notesNavMode: NavigationMode | undefined;
  @State pathInfo: NavPathStack = new NavPathStack();
  @State currentIndex: number = 0;
  @State mailList: string[] = ['1', '1', '1', '1', '1', '1', '1', '1'];
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
    };
  }

  @Builder
  myRouter(name: string, param?: number | undefined) {
    if (name === 'mailContent') {
      MailContent()
    }
  }

  @Builder
  NavigationMenus() {
    if (this.currentWidthBreakpoint !== 'md') {
      Row() {
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.plus'))
            .fontColor([$r('sys.color.icon_primary')])
            .fontSize($r('sys.float.Title_M'))
        }
        .height(40)
        .aspectRatio(1)
        .backgroundColor($r('sys.color.comp_background_tertiary'))

        Blank()
          .width(16)
        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.dot_grid_2x2'))
            .fontColor([$r('sys.color.icon_primary')])
            .fontSize($r('sys.float.Title_M'))
        }
        .height(40)
        .aspectRatio(1)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
      }
      .height(56)
      .margin({
        top: 24,
        right: 16
      })
    }
  }

  @Builder
  NavigationTitle() {
    Column() {
      Text($r('app.string.recvBox'))
        .fontColor('#000000')
        .fontSize(30)
        .lineHeight(41)
        .fontWeight(FontWeight.Medium)
      Text('jiaozi@xxx.com')
        .fontColor('#99000000')
        .fontSize(14)
        .lineHeight(20)
        .margin({ top: 2 })
    }
    .width(138)
    .height(162)
    .alignItems(HorizontalAlign.Start)
    .padding({ top: 80, left: 24 })
  }

  // [Start navigation_mode_build]
  build() {
    // [Start navigation_mode]
    Navigation(this.pathInfo) {
      // [StartExclude navigation_mode]
      // [StartExclude navigation_mode_build]
      Stack({ alignContent: Alignment.Start }) {
        Column() {
          Row() {
            Search({ placeholder: $r('app.string.searchMail') })
          }
          .width('100%')
          .height(56)
          .margin({
            left: this.currentWidthBreakpoint === 'sm' ? 12 : 18,
            right: this.currentWidthBreakpoint === 'sm' ? 12 : 18
          })

          List() {
            ForEach(this.mailList, (item: string, index: number | undefined) => {
              ListItem() {
                Column() {
                  Row() {
                    Text($r('app.string.nonSense'))
                      .fontSize(16)
                      .lineHeight(22)
                      .fontColor('#1818a')
                    Blank()
                    Text('4/12')
                      .fontSize(12)
                      .opacity(0.6)
                  }
                  .width('100%')

                  Column() {
                    Text($r('app.string.textPartOne'))
                      .lineHeight(19)
                      .fontSize(14)
                      .fontColor('#1818a')
                    Text($r('app.string.textPartTwo'))
                      .fontSize(14)
                      .fontColor('#1818a')
                      .opacity(0.6)
                      .lineHeight(19)
                  }
                  .width('100%')
                  .alignItems(HorizontalAlign.Start)
                }
                .height(96)
                .justifyContent(FlexAlign.Center)
              }
              .backgroundColor(index === 2 ? '#19254ff7' : '')
              .borderRadius(10)
              .padding({ left: 12, right: 12 })
            })
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
          .layoutWeight(1)
          .divider({ strokeWidth: 1, startMargin: 12, endMargin: 12 })
          .padding({ bottom: this.getUIContext().px2vp(getBottom(this.avoidAreas, this.windowHeight)) })
          .onClick(() => {
            this.pathInfo?.replacePath({ name: 'mailContent' });
          })
        }
        .width('100%')
        .height('100%')
        .padding({ right: 12, left: 12 })
      }
      // [EndExclude navigation_mode_build]
      // [EndExclude navigation_mode]
    }
    .mode(this.currentWidthBreakpoint === 'sm' ? NavigationMode.Stack : this.notesNavMode)
    // [End navigation_mode]
    .navDestination(this.myRouter)
    // [StartExclude navigation_mode_build]
    .navBarWidth(new BreakpointType(321, 321, 390).getValue(this.currentWidthBreakpoint) as number | Length)
    .menus(this.NavigationMenus)
    .width('100%')
    .title({ builder: this.NavigationTitle, height: 162 })
    // [EndExclude navigation_mode_build]
  }
  // [End navigation_mode_build]
}