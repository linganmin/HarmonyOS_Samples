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

interface SwiperType {
  pic: string,
  title: string
}

@Builder
export function HomePageBuilder() {
  HomePage()
}

@Component
struct HomePage {
  @State noMoreData: boolean = false;
  @State isRefreshing: boolean = false; // Is refreshing in progress.
  @State scenicSpotArray: ResourceStr[] = [$r('app.string.scenic_area_1'),$r('app.string.scenic_area_2'),$r('app.string.scenic_area_3'),$r('app.string.scenic_area_4'),$r('app.string.scenic_area_5')];
  private borderRadiusVal = 16;
  private swiperContent: SwiperType[] = [
    { pic: 'app.media.pic1', title: 'picture1' },
    { pic: 'app.media.pic2', title: 'picture2' },
    { pic: 'app.media.pic3', title: 'picture3' },
    { pic: 'app.media.pic4', title: 'picture4' }
  ];
  private scenicSpotTitle: Resource[] =
    [$r('app.string.popular_scenic_spots'), $r('app.string.recommended_scenic_spots'),
      $r('app.string.small_scale_scenic_spots')];
  private gridTitle: Resource[] =
    [$r('app.string.icon_one'), $r('app.string.icon_two'), $r('app.string.icon_three'),
      $r('app.string.icon_four'), $r('app.string.icon_five'), $r('app.string.icon_six'),
      $r('app.string.icon_seven'), $r('app.string.icon_eight'), $r('app.string.icon_nine'),
      $r('app.string.icon_ten')];

  // Scenic spot list title.
  @Builder
  scenicSpotHeader(title: Resource) {
    Column() {
      Text(title)
        .width('100%')
        .height(50)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .backgroundColor(0xF1F3F5)
    }
  }
  // [Start scenic_spot_details]
  // Scenic spot list content details
  @Builder
  scenicSpotDetailBuilder(title: Resource) {
    Column() {
      Image($r('app.media.pic1'))
        // [StartExclude scenic_spot_details]
        .width('100%')
        .height(186)
        .padding({ bottom: 12 })
        .borderRadius(this.borderRadiusVal)
        // [EndExclude scenic_spot_details]
      Column() {
        Text(title)
          // [StartExclude scenic_spot_details]
          .fontWeight(FontWeight.Bold)
          // [EndExclude scenic_spot_details]
        Text() {
          Span($r('app.string.group_discount'))
            // [StartExclude scenic_spot_details]
            .fontSize(14)
            // [EndExclude scenic_spot_details]
          Span('999￥')
            // [StartExclude scenic_spot_details]
            .fontSize(16)
            .fontColor(Color.Red)
            // [EndExclude scenic_spot_details]
        }
        .margin({ top: 4, bottom: 4 })

        Text() {
          Span($r('app.string.group_discount'))
          Span('1999￥')
        }
        // [StartExclude scenic_spot_details]
        .fontSize(14)
        .opacity(0.9)
        .margin({ bottom: 24 })
        // [EndExclude scenic_spot_details]
      }
      // [StartExclude scenic_spot_details]
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
      // [EndExclude scenic_spot_details]
    }
  }
  // [End scenic_spot_details]

  build() {
    NavDestination() {
      Column() {
        // [Start refresh]
        // Top search box.
        // [Start top_search_box]
        Row() {
          // [StartExclude refresh]
          Text($r('app.string.beijing'))
            // [StartExclude top_search_box]
            .fontSize(14)
            // [EndExclude top_search_box]
          TextInput({ placeholder: $r('app.string.want_search')})
            // [StartExclude top_search_box]
            .width('100%')
            .height(40)
            .layoutWeight(1)
            .placeholderFont({ size: 14 })
            .margin({ left: 16, right: 16 })
            // [EndExclude top_search_box]
          Text($r('app.string.more'))
            // [StartExclude top_search_box]
            .fontSize(14)
            // [EndExclude top_search_box]
            // [EndExclude refresh]
        }
        // [StartExclude refresh]
        // [End top_search_box]
        .width('100%')
        .height(60)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        // [EndExclude refresh]

        // Pull down refresh component.
        Refresh({ refreshing: $$this.isRefreshing }) {
          // List as a long list layout.
          // [Start first_list_item]
          // [Start second_list_item]
          // [Start scenic_spot_list]
          List({ space: 12 }) {
            // Swiper
            ListItem() {
              // [StartExclude refresh]
              // [StartExclude scenic_spot_list]
              // [StartExclude second_list_item]
              Swiper() {
                ForEach(this.swiperContent, (item: SwiperType) => {
                  Stack({ alignContent: Alignment.BottomStart }) {
                    Image($r(item.pic))
                  }
                }, (item: SwiperType) => JSON.stringify(item))
              }
              // [StartExclude first_list_item]
              .width('100%')
              .height(184)
              // [EndExclude first_list_item]
              .autoPlay(true) // Set the child component to play automatically
              .duration(1000) // Set the animation duration of the child component switchover
              .curve(Curve.Linear) // Set the animation curve to uniform speed
              .indicator( // Set the navigation point indicator
                new DotIndicator()
                  .selectedColor(Color.White)
              )
              .itemSpace(10) // Set the space between child components
              // [StartExclude first_list_item]
              .borderRadius(this.borderRadiusVal)
              // [EndExclude first_list_item]
              // [EndExclude second_list_item]
              // [EndExclude scenic_spot_list]
              // [EndExclude refresh]
            }
            // [StartExclude first_list_item]
            // Grid
            ListItem() {
              // [StartExclude refresh]
              // [StartExclude scenic_spot_list]
              Grid() {
                ForEach(this.gridTitle, (item: Resource) => {
                  GridItem() {
                    Column() {
                      Image($r('app.media.pic1'))
                        // [StartExclude second_list_item]
                        .width(44)
                        .height(44)
                        .objectFit(ImageFit.Fill)
                        .borderRadius(22)
                        // [EndExclude second_list_item]
                      Text(item)
                        // [StartExclude second_list_item]
                        .fontSize(12)
                        .padding({ top: 4 })
                        // [EndExclude second_list_item]
                    }
                  }
                }, (item: Resource) => JSON.stringify(item))
              }
              .rowsGap(16) // Set the line spacing
              .columnsGap(19) // Set the column spacing
              .columnsTemplate('1fr 1fr 1fr 1fr 1fr') // Set the proportion of each column
              // [StartExclude second_list_item]
              .width('100%')
              .padding(16)
              .borderRadius(this.borderRadiusVal)
              .backgroundColor(Color.White)
              // [EndExclude second_list_item]
              // [EndExclude scenic_spot_list]
              // [EndExclude refresh]
            }
            // [StartExclude second_list_item]
            // Customize display area.
            ListItem() {
              // [StartExclude refresh]
              Row() {
                Image($r('app.media.pic1'))
                  // [StartExclude scenic_spot_list]
                  .width('49%')
                  .height('100%')
                  .borderRadius(this.borderRadiusVal)
                  // [EndExclude scenic_spot_list]
                Image($r('app.media.pic1'))
                  // [StartExclude scenic_spot_list]
                  .width('49%')
                  .height('100%')
                  .borderRadius(this.borderRadiusVal)
                  // [EndExclude scenic_spot_list]
              }
              // [StartExclude scenic_spot_list]
              .width('100%')
              .height(120)
              .justifyContent(FlexAlign.SpaceBetween)
              // [EndExclude scenic_spot_list]
              // [EndExclude refresh]
            }

            // Scenic spot classification list.
            ForEach(this.scenicSpotTitle, (item: Resource) => {
              // [StartExclude refresh]
              ListItemGroup({ header: this.scenicSpotHeader(item) }) {
                ForEach(this.scenicSpotArray, (scenicSpotItem: Resource) => {
                  ListItem() {
                    this.scenicSpotDetailBuilder(scenicSpotItem);
                  }
                }, (scenicSpotItem: Resource) => JSON.stringify(scenicSpotItem))
              }
              .borderRadius(this.borderRadiusVal)
              // [EndExclude refresh]
            }, (item: Resource) => JSON.stringify(item))

            // [StartExclude scenic_spot_list]
            // Customize bottom loading for more.
            ListItem() {
              Row() {
                if (!this.noMoreData) {
                  LoadingProgress()
                    // [StartExclude refresh]
                    .width(24)
                    .height(24)
                    // [EndExclude refresh]
                }
                Text(this.noMoreData ? $r('app.string.no_more_data') : $r('app.string.loading_more'))
              }
              // [StartExclude refresh]
              .justifyContent(FlexAlign.Center)
              // [EndExclude refresh]
            }
            // [StartExclude refresh]
            .width('100%')
            .margin({ bottom: 65 })
            // [EndExclude refresh]
            // [EndExclude first_list_item]
            // [EndExclude second_list_item]
            // [EndExclude scenic_spot_list]
          }
          // [End scenic_spot_list]
          // [End second_list_item]
          // [End first_list_item]
          // [StartExclude refresh]
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
          .sticky(StickyStyle.Header) // Sticky title.
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true }) // Set and enable edge sliding effect.
          .layoutWeight(2) // Set layout weights for components.
          // List component hits bottom to simulate network requests.
          // [EndExclude refresh]
          .onReachEnd(() => { // Callback triggered when the list is added to the end position
            if (this.scenicSpotArray.length >= 20) {
              // When the list data is greater than or equal to 20, noMoreData is set to true
              this.noMoreData = true;
              return;
            }
            setTimeout(() => {
              this.scenicSpotArray.push('scenic area' + (this.scenicSpotArray.length + 1));
            }, 500)
          })
        }
        // Pull down refresh, simulate network request.
        .onRefreshing(() => {
          this.isRefreshing = true; // Enter the refresh state
          setTimeout(() => {
            // Set the landscapeSpotArray to the initial value
            this.scenicSpotArray =
              this.scenicSpotArray = ['scenic area 1', 'scenic area 2', 'scenic area 3', 'scenic area 4', 'scenic area 5'];
            this.noMoreData = false;
            this.isRefreshing = false;
          }, 2000)
        })
        // [End refresh]
      }
      .width('100%')
      .height('100%')
      .padding({ left: 16, right: 16 })
    }
    .hideTitleBar(true)
    .backgroundColor(0xF1F3F5)
    .onWillHide(() => {
      this.scenicSpotArray = ['scenic area 1', 'scenic area 2', 'scenic area 3', 'scenic area 4', 'scenic area 5'];
    })
  }
}