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

import { TabContentView } from '../view/TabContentView';
import { TitleDataSource } from '../model/TitleDataSource';
import { TabTitleView } from '../view/TabTitleView';
import { TAB_TITLES } from '../common/MockData';

@Component
export struct DiffListReusePage {
  arrayStr: string[] = TAB_TITLES;
  @State array: TitleDataSource = new TitleDataSource();
  swiperController: SwiperController = new SwiperController();
  @State selectedIndex: number = 0;

  aboutToAppear(): void {
    for (let i = 0; i < this.arrayStr.length; i++) {
      this.array.addItem(this.arrayStr[i]);
    }
  }

  build() {
    NavDestination() {
      TabTitleView({
        selectedIndex: this.selectedIndex,
        titles: this.arrayStr,
        selectListener: (index: number) => {
          if (this.selectedIndex === index) {
            return;
          }
          this.swiperController.changeIndex(index, true);
          this.selectedIndex = index;
        }
      })

      Swiper(this.swiperController) {
        LazyForEach(this.array, (index: number) => {
          TabContentView({ index: index })
        }, (title: string) => title)
      }
      .onAnimationStart(() => {
      })
      .loop(false)
      .onChange((index: number) => {
        if (this.selectedIndex !== index) {
          this.selectedIndex = index;
        }
      })
      .indicator(false)
      // set cachedCount 0 to mock reuse when swipe next page
      .cachedCount(0)
      .id('id_custom_reusable_pool_main_swiper')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .backgroundColor(0xF1F3F5)
    .title($r('app.string.index_diff_list'))
  }
}