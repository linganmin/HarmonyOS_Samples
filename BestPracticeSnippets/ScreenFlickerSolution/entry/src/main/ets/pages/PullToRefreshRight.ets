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

import util from '@ohos.util';
import { PullToRefresh, PullToRefreshConfigurator } from '@ohos/pulltorefresh/index';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct PullToRefreshError {
  // Create data objects for lazy loading
  @State newsData: Array<NewsData> = [];
  private mockFlag: boolean = true;
  // You need to bind a list or cell component
  private scroller: Scroller = new Scroller();
  // Simulation news data list list page
  @State newsDataListIndex: number = 1;
  private refreshConfigurator: PullToRefreshConfigurator = new PullToRefreshConfigurator();
  @State isPullUp: boolean = true;
  @State isLoading: boolean = false;
  @State private angle1?: number | string = 0;
  @State private angle2?: number | string = 0;
  @State loadText: ResourceStr = '';
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear(): void {
    const arrayModelMockData: Array<NewsData> = getNews('mockDataOne.json', this.context);
    this.newsData = arrayModelMockData;
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.arrow_left'))
          .padding(12)
          .width(40)
          .height(40)
          .borderRadius('50%')
          .backgroundColor('rgba(0,0,0,0.05)')
        Text($r('app.string.message'))
          .fontSize(20)
          .lineHeight(26)
          .fontWeight(700)
          .padding({ left: 8 })
      }
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Start)
      .height(56)
      .width('100%')

      Column() {
        PullToRefresh({
          // When you use the PullToRefresh component, you need to bind the data and body layout first. If you use the LazyForEach component to render the list, you need to decorate the LazyForEach component with the @For decorator.
          data: this.newsData,
          // A required pass that binds to a list or cell component in the passed body layout
          scroller: this.scroller,
          // Required items, custom body layout, internal list or grid components
          customList: () => {
            // A UI method decorated with @Builder
            this.getListView();
          },
          // Component property configuration, with default values
          refreshConfigurator: this.refreshConfigurator,
          // Set the onRefresh drop-down refresh callback method, which must return a Promise type.
          onRefresh: () => {
            return new Promise<string>((resolve) => {
              // Simulate network request operation, get data after 1.5 seconds request network, notify components, change list data
              setTimeout(() => {
                this.newsData = [];
                let newsModelMockData: Array<NewsData> = [];
                // Switch the obtained data file according to mockFlag
                if (this.mockFlag) {
                  newsModelMockData = getNews('mockDataTwo.json', this.context);
                } else {
                  newsModelMockData = getNews('mockDataOne.json', this.context);
                }
                this.mockFlag = !this.mockFlag;
                const array: NewsData[] = this.newsData.slice();
                array.push(...newsModelMockData);
                this.newsData = array;
                // Page number to zero
                this.newsDataListIndex = 1;
                resolve('Refresh successfully');
              }, 1000);
            });
          },
          // Set onLoadMore to slide up the more data callback method, which must return a Promise type.
          onLoadMore: () => {
            return new Promise<string>((resolve) => {
              // The simulation data list page reached the bottom after more than 4 pages and could not be loaded
              if (this.newsDataListIndex < 4) {
                // Simulate network request operation, get data after 1.5 seconds of network request, notify the component to change the list data
                setTimeout(() => {
                  let newsModelMockData: Array<NewsData> = getNews('mockDataOne.json', this.context);
                  const array = this.newsData;
                  array.push(...newsModelMockData);
                  this.newsData = array;
                  this.newsDataListIndex++;
                  resolve('');
                }, 1000);
              } else {
                // If 4 pages are full, change the drop-down message to indicate that all data has been loaded
                setTimeout(() => {
                  resolve('');
                }, 1000);
              }
            });
          },
          customLoad: () => this.customLoad(),
          customRefresh: null,
          onAnimPullUp: (value, width, height) => {
            if (value !== undefined && width !== undefined && height !== undefined) {
              if (value) {
                this.isLoading = false;
                this.isPullUp = true;
                // Determine whether the height exceeds the stage threshold during pull-up and dragging
                if (value < 0.75) {
                  // Zero Angle, keep the arrow facing up
                  this.angle1 = 0;
                  // Change the prompt text to pull-up 1 phase
                  this.loadText = $r('app.string.pulling_up_to_refresh');
                } else {
                  // Flip the Angle, keeping the arrow facing down
                  this.angle1 = 180;
                  // Change the prompt text to pull up 2 stages
                  this.loadText = $r('app.string.release_to_refresh');
                }
              }
            }
          },
          onAnimLoading: (value, width, height) => {
            if (value == undefined && width != undefined && height != undefined) {
              if (value) {
                this.isPullUp = false;
                this.isLoading = true;
                // Change the Angle to keep the loaded image rotated
                this.angle2 = value * 360;
                // Read if the page number is the last page
                if (this.newsDataListIndex !== 4) {
                  this.loadText = $r('app.string.loading_at_risk');
                } else {
                  this.loadText = $r('app.string.have_come_to_the_end');
                }
              }
            }
          }
        })
      }
    }
    .height('100%')
    .backgroundColor('#F1F3F5')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  private customLoad() {
    Row() {
      Stack() {

        // Pull up the 1 stage arrow picture
        Image($r('app.media.pull_icon_up'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Contain)
          .visibility(this.isPullUp ? Visibility.Visible : Visibility.Hidden)
          .rotate({
            z: 1,
            angle: this.angle1 != undefined ? this.angle1 : 0
          })

        // Load-time picture
        Image($r('app.media.pull_icon_load'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Contain)
          .visibility(this.isLoading ? Visibility.Visible : Visibility.Hidden)
          .rotate({
            z: 1,
            angle: this.angle2 != undefined ? this.angle2 : 0
          })
      }
      // Hide the loaded image when the last page loads
      .width(this.newsDataListIndex === 4 && this.isLoading ? 0 : this.refreshConfigurator.getLoadImgHeight())
      .height(this.newsDataListIndex === 4 && this.isLoading ? 0 : this.refreshConfigurator.getLoadImgHeight())

      // Pull-up process with prompt text when loading
      Text(this.loadText)
        .height('100%')
        .textAlign(TextAlign.Center)
        .margin({ left: this.newsDataListIndex === 4 && this.isLoading ? 0 : 8 })
        .fontColor(this.refreshConfigurator != undefined ? this.refreshConfigurator.getLoadTextColor() : 0)
        .fontSize(this.refreshConfigurator != undefined ? this.refreshConfigurator.getLoadTextSize() : 0)
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }

  // [Start get_list_view_right]
  @Builder
  private getListView() {
    List({
      space: 12,
      scroller: this.scroller
    }) {
      // Render data using lazy loading components
      ForEach(this.newsData, (item: NewsData) => {
        ListItem() {
          newsItem({
            newsTitle: item.newsTitle,
            newsContent: item.newsContent,
            newsTime: item.newsTime,
            img: item.img
          })
        }
        .backgroundColor(Color.White)
        .borderRadius(16)
      }, (item: NewsData) => item.newsId);
    }
    .width('100%')
    .height('100%')
    .padding({
      left: 16,
      right: 16
    })
    .backgroundColor('#F1F3F5')
    // You must set the list to slide to edge to have no effect, otherwise the pullToRefresh component's slide up and drop down method cannot be triggered.
    .edgeEffect(EdgeEffect.None)
  }
  // [End get_list_view_right]

  aboutToDisappear() {
    this.newsData = [];
  }
}


// Single list style component
@Component
struct newsItem {
  private newsTitle: ResourceStr = '';
  private newsContent: ResourceStr = '';
  private newsTime: ResourceStr = '';
  private img: string = '';

  build() {
    Row() {
      Column() {
        Text(this.newsTitle)
          .fontSize(16)
          .lineHeight(23)
          .fontColor('rgba(0, 0, 0, 0.9)')
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontWeight(500)

        Text(this.newsContent)
          .fontSize(14)
          .lineHeight(20)
          .fontColor('rgba(0, 0, 0, 0.6)')
          .width('100%')
          .margin({
            top: 4,
            bottom: 4
          })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.newsTime)
          .fontSize(12)
          .lineHeight(16)
          .fontColor('rgba(0, 0, 0, 0.4)')
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.None })
      }
      .width('65%')
      .padding({ right: 8 })

      Image($r(`app.media.${this.img}`))
        .width('35%')
        .aspectRatio(1.24)
        .borderRadius(8)
    }
    .width('100%')
    .padding({
      top: 12,
      left: 16,
      right: 16,
      bottom: 12
    })
  }
}

// News data object
class NewsData {
  newsId: string;
  img: string;
  newsTitle: ResourceStr;
  newsContent: ResourceStr;
  newsTime: ResourceStr;

  toString(): string {
    return `${this.newsId} ${this.newsTitle} ${this.newsContent} ${this.newsTime} ${this.img}`;
  }

  constructor(id: string, title: ResourceStr, content: ResourceStr, time: ResourceStr,
    img: string) {
    this.newsId = id;
    this.newsTitle = title;
    this.newsContent = content;
    this.newsTime = time;
    this.img = img;
  }
}

class JsonObjType {
  newsList: Array<NewsData> = [];
}

class JsonObject {
  private jsonFileDir: string = '';

  constructor(jsonFileDir: string) {
    this.jsonFileDir = jsonFileDir;
  }

  // Get data
  getNewsData(context: common.UIAbilityContext): Array<NewsData> {
    // Get data from a local file
    let value: Uint8Array | null = null;
    try {
      value = context?.resourceManager.getRawFileContentSync(this.jsonFileDir);
    } catch (error) {
      let err = error as BusinessError;
      hilog.warn(0x000, 'testTag', `setColorMode failed, code=${err.code}, message=${err.message}`);
    }
    // Decode to utf-8 format
    const textDecoder: util.TextDecoder = util.TextDecoder.create('utf-8', {
      ignoreBOM: true
    });
    const textDecoderResult: string = textDecoder.decodeToString(new Uint8Array(value!.buffer));
    const jsonObj: JsonObjType = JSON.parse(textDecoderResult) as JsonObjType;
    const newsModelBuckets: Array<NewsData> = [];
    // Map json data to NewsModel objects
    const newsModelObj: NewsData[] = jsonObj.newsList;
    for (let i = 0; i < newsModelObj.length; i++) {
      const contactTemp: NewsData = new NewsData(newsModelObj[i].newsId, newsModelObj[i].newsTitle,
        newsModelObj[i].newsContent, newsModelObj[i].newsTime, newsModelObj[i].img);
      newsModelBuckets.push(contactTemp);
    }
    return newsModelBuckets;
  }
}

function getNews(mockFileDir: string, context: common.UIAbilityContext): Array<NewsData> {
  const jsonObj: JsonObject = new JsonObject(mockFileDir);
  const newsModelMockData: Array<NewsData> = jsonObj.getNewsData(context);
  return newsModelMockData;
}
