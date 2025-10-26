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

import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ALL_CITY2, CITY_DATA } from '../viewmodel/CityDetailData';
import { SearchView } from '../view/SearchView';
import { CityView } from '../view/CityView';
import { CommonConstants } from '../constants/CommonConstants';

@Entry
@Component
struct CitySearch {
  @State changeValue: string = '';
  @State placeholder: string =
    this.getUIContext().getHostContext()!.resourceManager.getStringSync($r('app.string.placeholder').id);
  @State isSearchState: boolean = false;
  @State searchList: string[] = [];
  controller: SearchController = new SearchController();

  getString(id: number): string {
    try {
      return this.getUIContext().getHostContext()!.resourceManager.getStringSync(id);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'HomeHeader', `getStringSync failed, error code=${err.code}, message=${err.message}`);
      return '';
    }
  }

  build() {
    Column() {
      // Search box.
      Search({ value: this.changeValue, placeholder: this.placeholder, controller: this.controller })
        .searchButton(this.getString($r('app.string.search_text').id))
        .width(CommonConstants.FULL_PERCENT)
        .height($r('app.integer.search_height'))
        .margin({ top: $r('app.integer.search_margin_top') })
        .backgroundColor($r('app.color.search_bgc'))
        .placeholderColor(Color.Grey)
        .placeholderFont({
          size: $r('app.integer.placeholderFont_size'),
          weight: CommonConstants.FONT_WEIGHT_400
        })
        .textFont({
          size: $r('app.integer.placeholderFont_size'),
          weight: CommonConstants.FONT_WEIGHT_400
        })
        .onSubmit((value: string) => {
          if (value.length === 0) {
            value = this.placeholder;
          }
          this.changeValue = value;
          this.isSearchState = true;
          this.searchCityList(value);
        })
        .onChange((value: string) => {
          this.changeValue = value;
          this.searchCityList(value);
          if (value.length === 0) {
            this.isSearchState = false;
            this.searchList.splice(0, this.searchList.length);
          }
        })

      // City list component.
      CityView({ isSearchState: $isSearchState })
        .margin({ top: $r('app.integer.list_margin_top') })

      // Search component, passing data to the search list.
      SearchView({
        searchList: $searchList,
        isSearchState: $isSearchState
      })
        .width(CommonConstants.FULL_PERCENT)
        .layoutWeight(CommonConstants.LAYOUT_WEIGHT)
    }
    .width(CommonConstants.FULL_PERCENT)
    .padding({ left: $r('app.integer.padding_left') })
    .backgroundColor($r('app.color.bgc'))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Start)
    .height(CommonConstants.FULL_PERCENT)
  }

  // Display logic for searching for a city.
  searchCityList(value: string): void {
    let cityNames: string[] = [];
    ALL_CITY2.forEach(item => {
      if (item.name === value) {
        item.city.forEach(city => {
          cityNames.push(city);
        })
      }
      this.searchList = cityNames;
      return;
    })
    CITY_DATA.forEach(item => {
      item.city.forEach(city => {
        if (city.includes(value)) {
          cityNames.push(city);
        }
      })
    })
    this.searchList = cityNames;
  }
}

// Create the WrappedBuilder object and construct the page during dynamic route jumping.
@Builder
export function getCitySearch(): void {
  CitySearch();
}
