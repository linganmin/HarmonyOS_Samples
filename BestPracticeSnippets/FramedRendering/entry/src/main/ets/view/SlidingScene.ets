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

import { Month, MonthDataSource } from '../model/MonthDataSource'
import { SegmentButton, SegmentButtonItemTuple, SegmentButtonOptions } from '@kit.ArkUI';
import { CommonConstants } from '../common/CommonConstants';
import { DateItemView } from './DateItemView';

@Entry
@Component
struct SlidingScene {
  @State contentData: MonthDataSource = new MonthDataSource();
  @State currentYear: number = new Date().getFullYear();
  @State singleSelectCapsuleOptions: SegmentButtonOptions = SegmentButtonOptions.capsule({
    buttons: [
      { text: $r('app.string.year') }, { text: $r('app.string.month') }, { text: $r('app.string.week') },
      { text: $r('app.string.sunday') }] as SegmentButtonItemTuple,
    multiply: false,
    fontSize: 14,
    fontWeight: 500,
    backgroundBlurStyle: BlurStyle.BACKGROUND_THICK,
    selectedFontColor: Color.Black,
    selectedFontWeight: FontWeight.Bold,
    backgroundColor: '#0000000d',
    selectedBackgroundColor: Color.White
  });
  @State singleSelectCapsuleSelectedIndexes: number[] = [1];
  private readonly LIST_SPACE: number = 24;
  private readonly LIST_CACHE: number = 2;

  aboutToAppear(): void {
    this.contentData.getDateData(this.getUIContext());
  }

  aboutToDisappear(): void {
    this.contentData.clearData();
  }

  build() {
    Column() {
      SegmentButton({
        options: this.singleSelectCapsuleOptions,
        selectedIndexes: $singleSelectCapsuleSelectedIndexes
      })
        .margin({
          left: 16,
          right: 16,
          top: 8
        })
      List({ space: this.LIST_SPACE }) {
        LazyForEach(this.contentData, (monthItem: Month) => {
          ListItem() {
            DateItemView({
              monthItem: monthItem
            })
              .reuseId('reuse_id_' + monthItem.days.length.toString())
          }
        })
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .layoutWeight(1)
      .margin({ top: 24 })
      .cachedCount(this.LIST_CACHE)
      .edgeEffect(EdgeEffect.None)
      .scrollBar(BarState.Off)
      .onScrollIndex((first: number) => {
        if (first < 12) {
          this.currentYear = new Date().getFullYear();
        } else {
          this.currentYear = new Date().getFullYear() + 1;
        }
      })
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .alignItems(HorizontalAlign.Center)
  }
}

@Builder
function slidingSceneBuilder(name: string): void {
  if (name === CommonConstants.NAV_DESTINATION_ITEM_1) {
    NavDestination() {
      SlidingScene();
    }
    .title('2024')
    .backgroundColor('#F1F3F5')
  }
}

export const wrappedBuilderSlidingScene: WrappedBuilder<[string]> =
  wrapBuilder(slidingSceneBuilder);