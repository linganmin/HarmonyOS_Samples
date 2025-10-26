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
import { buffer } from "@kit.ArkTS";
import { hilog } from "@kit.PerformanceAnalysisKit";

interface City {
  code: string,
  city: string
}

interface CityData {
  current: string[],
  hot: string[],
  cityList: Map<string, City[]>
}

@Builder
export function CityListBuilder() {
  CityList()
}

@Component
struct CityList {
  @State selectNavIndex: number = -1;
  @State isClickScroll: boolean = false;
  @State currentCity: string = '';
  @State hotCities: string[] = [];
  @State groupCities: Map<string, City[]> = new Map();
  private cityScroller: ListScroller = new ListScroller();
  private navListScroller: ListScroller = new ListScroller();
  private groupWorldList: string[] =
    ['A', 'B', 'C', 'D', 'F', 'J', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'W', 'X', 'Y', 'Z'];
  @StorageLink('languageVal') @Watch('aboutToAppear') languageVal: string = '';

  aboutToAppear() {
    let storageVal: string | undefined = AppStorage.get('languageVal');
    if (storageVal) {
      try {
        let cityData: Uint8Array = this.getUIContext().getHostContext()!.resourceManager.getRawFileContentSync(storageVal === 'zh' ? 'cityListCN.json' : 'cityListEN.json');
        let cityStr = buffer.from(cityData.buffer).toString();
        let data: CityData = JSON.parse(cityStr);
        this.currentCity = data.current[0];
        this.hotCities = data.hot;
        this.groupCities = data.cityList;
      } catch (error) {
        hilog.error(0x0000, 'testTag',`getRawFileContentSync failed, Code:${error.code}, message:${error.message}`);
      }
    }
  }

  // Group List Header.
  @Builder
  itemHead(text: ResourceStr) {
    Text(text)
      .width('100%')
      .height(45)
      .fontSize(16)
      .padding({ left: 16 })
      .backgroundColor(0xF1F3F5)
  }

  // [Start list_data_content]
  // List data content.
  @Builder
  textContent(content: string) {
    Text(content)
      // [StartExclude list_data_content]
      .width('100%')
      .height(45)
      .fontSize(16)
      .padding({ left: 16, top: 12, bottom: 12 })
      .textAlign(TextAlign.Start)
      .backgroundColor(Color.White)
      // [EndExclude list_data_content]
  }
  // [End list_data_content]

  // Retrieve city data corresponding to letters.
  getCitiesWithGroupName(name: string): City[] {
    return this.groupCities[name];
  }

  build() {
    NavDestination() {
      // [Start city_list_sticky]
      // [Start city_list_stack]
      Stack({ alignContent: Alignment.End }) {
        // City List Data.
        // [Start city_list_data]
        List({ scroller: this.cityScroller }) {
          // [StartExclude city_list_sticky]
          // [StartExclude city_list_stack]
          // Current city.
          ListItemGroup({ header: this.itemHead($r('app.string.current_city')) }) {
            ListItem() {
              Text(this.currentCity)
                .width('100%')
                .height(45)
                .fontSize(16)
                .padding({ left: 16, top: 12, bottom: 12 })
                .textAlign(TextAlign.Start)
                .backgroundColor(Color.White)
            }
          }

          // Popular cities.
          ListItemGroup({ header: this.itemHead($r('app.string.popular_cities')) }) {
            ForEach(this.hotCities, (item: string) => {
              ListItem() {
                this.textContent(item);
              }
            }, (item: string) => item)
          }
          .divider({
            strokeWidth: 1,
            color: '#EDEDED',
            startMargin: 10,
            endMargin: 45
          })

          // City data.
          ForEach(this.groupWorldList, (item: string) => {
            // Traverse the first letter of the city and use it as the header of the city grouping data.
            ListItemGroup({ header: this.itemHead(item) }) {
              // Retrieve and display corresponding city data based on letters.
              ForEach(this.getCitiesWithGroupName(item), (cityItem: City) => {
                ListItem() {
                  this.textContent(cityItem.city);
                }
              }, (cityItem: City) => cityItem.city)
            }
          })
          // [EndExclude city_list_stack]
          // [EndExclude city_list_sticky]
        }
        // [StartExclude city_list_sticky]
        // [StartExclude city_list_stack]
        // [End city_list_data]
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .sticky(StickyStyle.Header) // Set the header of ListItemGroup to be the top, and the foot not to be the bottom.
        .onTouch(() => {
          // Touch scrolling of city list, isClickScroll is false to prevent conflicts with navigation list scrolling during the scrolling process.
          this.isClickScroll = false;
        })
        // [EndExclude city_list_sticky]
        .onScrollIndex((index: number) => {
          // By linking the selectNavIndex state variable with index, control the selection status of the navigation list.
          this.selectNavIndex = index - 2;
        })
        // [EndExclude city_list_stack]

        // [Start side_letter_navigation]
        // Side letter navigation data.
        Column() {
          List({ scroller: this.navListScroller }) {
            // [StartExclude city_list_stack]
            ForEach(this.groupWorldList, (item: string, index: number) => {
              ListItem() {
                Text(item)
                  // [StartExclude city_list_sticky]
                  // [StartExclude side_letter_navigation]
                  .width(30)
                  .height(30)
                  .fontSize(16)
                  .padding({ left: 10 })
                  .textAlign(TextAlign.Start)
                  .borderRadius(index === this.selectNavIndex ? '50%' :
                    0)// Set the background color when selecting the side navigation.
                  .fontColor(index === this.selectNavIndex ? '#FFFFFF' : Color.Black)
                  .backgroundColor(index === this.selectNavIndex ? '#bEDAF2' : Color.Transparent)
                  // [EndExclude city_list_sticky]
                  .onClick(() => {
                    this.selectNavIndex = index;
                    // Select the navigation list and set isClickScroll to true to prevent changes in the navigation list status during the scrolling process with the city list.
                    this.isClickScroll = true;
                    // By using the scrollIndex method of cityScanner, control the sliding city list to specify the Index,
                    // as there are "current city" and "popular city" in the city list, so the index needs to be incremented by 2.
                    this.cityScroller.scrollToIndex(index + 2, false, ScrollAlign.START);
                  })
                  // [EndExclude side_letter_navigation]
              }
            }, (item: string) => item)
            // [EndExclude city_list_stack]
          }
        }
        // [StartExclude city_list_sticky]
        // [StartExclude city_list_stack]
        // [End side_letter_navigation]
        .width('10%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        // [EndExclude city_list_stack]
        // [EndExclude city_list_sticky]
      }
      // [End city_list_stack]
      // [End city_list_sticky]
    }
    .hideTitleBar(true)
    .backgroundColor(0xF1F3F5)
  }
}