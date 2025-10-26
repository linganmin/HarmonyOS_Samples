/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
import { display } from '@kit.ArkUI';
import { Constants } from '../common/Constants';
import { BasicDataSource } from '../viewmodel/BasicDataSource';

@Component
export struct UpDownFlipPage {
  @StorageLink('windowWidth') @Watch('updateScreenW') windowWidth: number = 0;
  @Link isMenuViewVisible: boolean;
  // [Start up_down_1]
  // entry/src/main/ets/view/UpDownFlipPage.ets
  @Link currentPageNum: number;
  private data: BasicDataSource = new BasicDataSource([]);
  // [StartExclude up_down_1]
  @State screenW: number = 0;
  private scroller: Scroller = new Scroller();

  // [EndExclude up_down_1]
  aboutToAppear(): void {
    for (let i = Constants.PAGE_FLIP_PAGE_START; i <= Constants.PAGE_FLIP_PAGE_END; i++) {
      this.data.pushItem(Constants.PAGE_FLIP_RESOURCE + i.toString());
    }
    // [StartExclude up_down_1]
    if (this.screenW > Constants.WINDOW_WIDTH) {
      this.screenW = this.screenW / 2;
    }
    this.updateScreenW();
    // [EndExclude up_down_1]
  }
  // [End up_down_1]

  updateScreenW(){
    this.screenW = this.getUIContext().px2vp(this.windowWidth);
  }

  build() {
    Column() {
      // [Start up_down_2]
      // entry/src/main/ets/view/UpDownFlipPage.ets
      List({ initialIndex: this.currentPageNum - 1, scroller: this.scroller }) {
        LazyForEach(this.data, (item: string) => {
          ListItem() {
            Text($r(item))
            // [StartExclude up_down_2]
              .fontSize($r('app.integer.flip_page_text_font_size'))
              .width($r('app.string.page_flip_full_size'))
              .lineHeight($r('app.integer.flip_page_text_line_height'))
              .padding({
                left: 26,
                right: 20
              })
              .fontColor($r('app.color.text_font_color'))
              .fontWeight(FontWeight.Normal)
              .letterSpacing(1)
            // [EndExclude up_down_2]
          }
        }, (item: string, index: number) => index + JSON.stringify(item))
      }
      // [StartExclude up_down_2]
      .height($r('app.string.page_flip_full_size'))
      .scrollBar(BarState.Off)
      .cachedCount(Constants.PAGE_FLIP_CACHE_COUNT)
      // [EndExclude up_down_2]
      .onScrollIndex((firstIndex: number) => {
        this.currentPageNum = firstIndex + 1;
      })
      // [End up_down_2]
    }
    .width($r('app.string.page_flip_full_size'))
    .backgroundColor($r('app.color.page_flip_background_color'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onClick((event?: ClickEvent) => {
      // Menu visibility control.
      if (event && event.x < (this.screenW / Constants.PAGE_FLIP_THREE * Constants.PAGE_FLIP_TWO) &&
        event.x > (this.screenW / Constants.PAGE_FLIP_THREE)) {
        if (this.isMenuViewVisible) {
          this.isMenuViewVisible = false;
        } else {
          this.isMenuViewVisible = true;
        }
      }
    })
  }
}