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

import { mediaquery } from '@kit.ArkUI';
// [Start Home]
import HomeContent from './HomeContent';
import IndexTitleBar from './IndexTitleBar';
import SideContent from './SideContent';
import { CityListData, Style, getBg, getCityListWeatherData, Logger } from 'common';
// [StartExclude Home]
const TAG: string = 'Home';
// [EndExclude Home]

@Entry
@Component
struct Home {
  // [StartExclude Home]
  @StorageLink('isRefresh') @Watch('refreshChange') isRefresh: boolean = false;
  @StorageLink('swiperIndex') swiperIndex: number = 0;
  // [EndExclude Home]
  @State curBp: string = 'md';
  @State cityListWeatherData: CityListData[] = getCityListWeatherData();
  @State showSideBar: boolean = false;
  // [StartExclude Home]
  @State popupState: boolean = false;
  smListener: mediaquery.MediaQueryListener =
    this.getUIContext().getMediaQuery().matchMediaSync('(320vp<width<=600vp)');
  mdListener: mediaquery.MediaQueryListener =
    this.getUIContext().getMediaQuery().matchMediaSync('(600vp<width<=840vp)');
  lgListener: mediaquery.MediaQueryListener =
    this.getUIContext().getMediaQuery().matchMediaSync('(840vp<width)');
  // [EndExclude Home]

  build() {
    SideBarContainer(SideBarContainerType.Embed) {
      // Left sidebar.
      SideContent({ showSideBar: $showSideBar })
        .height('100%')
      // Right content area.
      Column() {
        // Title bar.
        IndexTitleBar({ showSideBar: $showSideBar })
          .height(56)
        // Weather details.
        Swiper() {
          ForEach(this.cityListWeatherData, (item: CityListData, index: number) => {
            HomeContent({ showSideBar: this.showSideBar, cityListData: item, index: index })
          }, (item: CityListData, index: number) => JSON.stringify(item) + index)
        }
        .id('swiper')
        .padding({ left: Style.NORMAL_PADDING, right: Style.NORMAL_PADDING })
        .onChange(index => {
          this.swiperIndex = index;
          AppStorage.setOrCreate('swiperIndex', this.swiperIndex);
        })
        // Disable navigation dots on lg width breakpoint.
        .indicator(this.curBp !== 'lg' ? new DotIndicator()
          .selectedColor(Color.White) : false
        )
        .index(this.swiperIndex)
        .loop(false)
        .width('100%')
        .layoutWeight(1)
      }
      .height('100%')
    }
    .height('100%')
    .sideBarWidth('33.3%')
    .minSideBarWidth('33.3%')
    .maxSideBarWidth('33.3%')
    .showControlButton(false)
    .showSideBar(this.showSideBar)
    .backgroundImageSize(ImageSize.Cover)
    .backgroundImage(getBg(this.cityListWeatherData[this.swiperIndex].header.weatherType))
  }
  // [StartExclude Home]

  aboutToAppear() {
    this.smListener.on('change', this.isBreakpointSM);
    this.mdListener.on('change', this.isBreakpointMD);
    this.lgListener.on('change', this.isBreakpointLG);
  }

  aboutToDisappear() {
    this.smListener.off('change', this.isBreakpointSM);
    this.mdListener.off('change', this.isBreakpointMD);
    this.lgListener.off('change', this.isBreakpointLG);
  }

  isBreakpointSM = (mediaQueryResult: mediaquery.MediaQueryResult) => {
    if (mediaQueryResult.matches) {
      this.curBp = 'sm';
      this.showSideBar = false;
      AppStorage.setOrCreate('curBp', this.curBp);
    }
    Logger.info(TAG, `this.curBp = ${this.curBp}`);
  }
  isBreakpointMD = (mediaQueryResult: mediaquery.MediaQueryResult) => {
    if (mediaQueryResult.matches) {
      this.curBp = 'md';
      this.showSideBar = false;
      AppStorage.setOrCreate('curBp', this.curBp);
    }
    Logger.info(TAG, `this.curBp = ${this.curBp}`);
  }
  isBreakpointLG = (mediaQueryResult: mediaquery.MediaQueryResult) => {
    if (mediaQueryResult.matches) {
      if (this.curBp !== 'lg') {
        this.showSideBar = true;
      }
      this.curBp = 'lg';
      AppStorage.setOrCreate('curBp', this.curBp);
    }
    Logger.info(TAG, `this.curBp = ${this.curBp}`);
  }

  refreshChange() {
    Logger.info(TAG, `refreshChange}`);
    if (this.isRefresh) {
      this.cityListWeatherData = getCityListWeatherData();
      AppStorage.setOrCreate('isRefresh', false);
    }
    Logger.info(TAG, `refreshChange, this.cityListWeatherData.length = ${this.cityListWeatherData.length}`);
  }
  // [EndExclude Home]
}
// [End Home]