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
import Constants, { getBottom, getLeft, getRight, getTop, Route } from '../common/Constants';

@Entry
@Component
struct Index {
  @State localPadding: LocalizedPadding = { top: LengthMetrics.vp(0), start: LengthMetrics.vp(0) };
  @StorageLink('cutout') @Watch('cutoutChange') avoidAreas: window.AvoidAreaOptions | undefined = undefined;
  @StorageLink('windowHeight') windowHeight: number = 0;
  @StorageLink('windowWidth') windowWidth: number = 0;
  @StorageLink('currentWidthBreakpoint') currentWidthBreakpoint: string = '';
  private routes: Route[] = Constants.ROUTES;

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

  build() {
    Column() {
      Navigation() {
        Column() {
          List({ space: 12 }) {
            ForEach(this.routes, (item: Route) => {
              ListItem() {
                Column() {
                  Button(item.text)
                    .onClick(() => {
                      this.getUIContext().getRouter().pushUrl({ url: item.to })
                    })
                    .width(this.currentWidthBreakpoint === 'sm' ? '100%' : 448)
                }
                .padding({
                  right: this.currentWidthBreakpoint === 'sm' ? 16 : 0,
                  left: this.currentWidthBreakpoint === 'sm' ? 16 : 0
                })
              }
              .width('100%')
            }, (item: Route) => JSON.stringify(item))
          }
        }
        .height('100%')
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.End)
      }
      .width('100%')
      .height('100%')
      .mode(NavigationMode.Stack)
      .title($r('app.string.title'))
      .backgroundColor($r('sys.color.background_secondary'))
      .padding({
        top: AppStorage.get<number>('statusBarHeight'),
        bottom: getBottom(this.avoidAreas, this.windowHeight) === 0 ? AppStorage.get<number>('naviIndicatorHeight') :
          this.getUIContext().px2vp(getBottom(this.avoidAreas, this.windowHeight)) +
            AppStorage.get<number>('naviIndicatorHeight')! as number,
        left: this.getUIContext().px2vp(getLeft(this.avoidAreas))
      })
    }
    .backgroundColor($r('sys.color.background_secondary'))
  }
}
