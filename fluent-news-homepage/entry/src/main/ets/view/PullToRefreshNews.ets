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

import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
// [Start pull_to_refresh]
// PullToRefreshNews.ets
import { PullToRefresh } from '@ohos/pulltorefresh/index';
// [End pull_to_refresh]
import { BreakpointConstants } from '../constants/BreakpointConstants';
import { CommonConstants } from '../constants/CommonConstants';
import { BreakpointType } from '../utils/BreakpointType';
import NewsData from '../viewmodel/NewsData';
import { NewsDataSource } from '../viewmodel/NewsDataSource';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
const NEWS_TITLE_MAX_LINES: number = 1;
const NEWS_TITLE_TEXT_FONT_WEIGHT: number = 500;
const NEWS_CONTENT_MAX_LINES: number = 2;
const NEWS_TIME_MAX_LINES: number = 1;
const NEWS_RESOLVE_SUCCESS: string =
  uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.refresh').id);
const NEWS_MOCK_DATA_COUNT: number = 8;
// [Start mock_data_file_one_dir]
// PullToRefreshNews.ets
const MOCK_DATA_FILE_ONE_DIR: string =
  uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.mock1').id);
const MOCK_DATA_FILE_TWO_DIR: string =
  uiContext!.getHostContext()!.resourceManager.getStringSync($r('app.string.mock2').id);
// [End mock_data_file_one_dir]
const NEWS_REFRESH_TIME: number = 1000;

@Component
export struct PullToRefreshNews {
  // [Start news_data]
  // PullToRefreshNews.ets
  @State newsData: NewsDataSource = new NewsDataSource();
  // [End news_data]
  @State firstIndex: number = 0;
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  private mockFlag: boolean = true;
  private scroller: Scroller = new Scroller();
  readonly ANIMATION_DURATION: number = 500;
  readonly SWITCH_BUTTON: number = 3;

  aboutToAppear() {
    let newsModelMockData: NewsData[] = getNews(MOCK_DATA_FILE_ONE_DIR);
    for (let j = CommonConstants.ZERO; j < NEWS_MOCK_DATA_COUNT; j++) {
      this.newsData.pushData(newsModelMockData[j]);
    }
  }

  build() {
    Column() {
      Column() {
        // [Start pull_to_refresh1]
        // PullToRefreshNews.ets
        PullToRefresh({
          data: $newsData,
          scroller: this.scroller,
          customList: () => {
            this.getListView();
          },
          onRefresh: () => {
            return new Promise<string>((resolve, reject) => {
              // [StartExclude pull_to_refresh1]
              setTimeout(() => {
                this.newsData.clear();
                let newsModelMockData: NewsData[] = [];
                if (this.mockFlag) {
                  newsModelMockData = getNews(MOCK_DATA_FILE_TWO_DIR);
                } else {
                  newsModelMockData = getNews(MOCK_DATA_FILE_ONE_DIR);
                }
                this.mockFlag = !this.mockFlag;
                for (let j = CommonConstants.ZERO; j < NEWS_MOCK_DATA_COUNT; j++) {
                  this.newsData.pushData(newsModelMockData[j]);
                }
                resolve(NEWS_RESOLVE_SUCCESS);
                // [EndExclude pull_to_refresh1]
              }, NEWS_REFRESH_TIME);
            });
          },
          onLoadMore: () => {
            return new Promise<string>((resolve, reject) => {
              // [StartExclude pull_to_refresh1]
              setTimeout(() => {
                let newsModelMockData: NewsData[] = getNews(MOCK_DATA_FILE_ONE_DIR);
                for (let j = CommonConstants.ZERO; j < NEWS_MOCK_DATA_COUNT; j++) {
                  this.newsData.pushData(newsModelMockData[j]);
                }
                resolve(NEWS_RESOLVE_SUCCESS);
              }, NEWS_REFRESH_TIME);
              // [EndExclude pull_to_refresh1]
            });
          },
          customLoad: null,
          customRefresh: null,
        })
        // [End pull_to_refresh1]
      }
      .backgroundColor($r('app.color.listColor'))
    }
    .height($r('app.string.news_page_height'))
  }

  @Builder
  private getListView() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      // [Start news_title]
      // PullToRefreshNews.ets
      List({ space: CommonConstants.LIST_SPACE, scroller: this.scroller }) {
        LazyForEach(this.newsData, (item: NewsData) => {
          ListItem() {
            newsItem({
              // [StartExclude news_title]
              newsTitle: item.newsTitle,
              newsContent: item.newsContent,
              newsTime: item.newsTime,
              newsImage: item.newsImage
              // [EndExclude news_title]
            })
          }
          // [StartExclude news_title]
          .backgroundColor($r('app.color.listViewColor'))
          .margin({
            bottom: $r('app.string.news_list_margin_bottom'),
            left: new BreakpointType($r('app.float.page_col_padding_sm'), $r('app.float.page_col_padding_md'),
              $r('app.float.page_col_padding_lg')).getValue(this.currentBreakpoint),
            right: new BreakpointType($r('app.float.page_col_padding_sm'), $r('app.float.page_col_padding_md'),
              $r('app.float.page_col_padding_lg')).getValue(this.currentBreakpoint),
          })
          .borderRadius($r('app.integer.news_list_border_radius'))

          // [EndExclude news_title]
        }, (item: NewsData, index?: number) => JSON.stringify(item) + index);
      }
      // [End news_title]
      .onScrollIndex((first: number) => {
        this.firstIndex = first;
      })
      .width($r('app.string.news_List_width'))
      .backgroundColor($r('app.color.listColor'))
      .edgeEffect(EdgeEffect.None)

      Row() {
        Image($r('app.media.ic_public_backtotop'))
          .width($r('app.integer.back_top_img_size'))
          .height($r('app.integer.back_top_img_size'))
          .opacity($r('app.float.jump_button_opacity'))
      }
      .onClick(() => {
        if (this.firstIndex >= this.SWITCH_BUTTON) {
          this.scroller.scrollTo({
            xOffset: CommonConstants.ZERO,
            yOffset: CommonConstants.ZERO,
            animation: { duration: this.ANIMATION_DURATION, curve: Curve.LinearOutSlowIn }
          });
        }
      })
      .visibility(this.firstIndex >= this.SWITCH_BUTTON ? Visibility.Visible : Visibility.None)
      .justifyContent(FlexAlign.Center)
      .width($r('app.integer.back_top_img_background_size'))
      .height($r('app.integer.back_top_img_background_size'))
      .backgroundColor($r("app.color.tab_sel_color"))
      .borderRadius($r('app.integer.back_top_bag_radius'))
      .margin({
        right: new BreakpointType($r('app.float.page_col_padding_sm'), $r('app.float.page_col_padding_md'),
          $r('app.float.page_col_padding_lg')).getValue(this.currentBreakpoint),
        bottom: $r('app.integer.back_top_margin')
      })
    }
  }

  aboutToDisappear() {
    this.newsData.clear();
  }
}

// [Start news_item]
// PullToRefreshNews.ets
@Component
struct newsItem {
  // [StartExclude news_item]
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  newsTitle: string | Resource = '';
  newsContent: string | Resource = '';
  newsTime: string | Resource = '';
  newsImage: string | Resource = '';

  build() {
    Row() {
      Column() {
        Row() {
          Image($r('app.media.new'))
            .width($r('app.string.news_title_image_width'))
            .height($r('app.string.news_title_image_height'))
            .objectFit(ImageFit.ScaleDown)
          Text(this.newsTitle)
            .fontSize($r('app.integer.news_title_text_font_size'))
            .fontColor($r('app.color.news_title_fontColor'))
            .layoutWeight(CommonConstants.LAYOUT_WEIGHT)
            .maxLines(NEWS_TITLE_MAX_LINES)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .fontWeight(NEWS_TITLE_TEXT_FONT_WEIGHT)
        }
        .alignItems(VerticalAlign.Center)
        .height($r('app.string.news_title_row_height'))
        .width($r('app.string.news_List_width'))
        .margin({ top: $r('app.string.news_title_row_margin_top') })

        Row() {
          Text(this.newsContent)
            .fontSize($r('app.integer.news_content_font_size'))
            .lineHeight($r('app.integer.news_content_font_line_height'))
            .fontColor($r('app.color.news_content_fontColor'))
            .width($r('app.string.news_List_width'))
            .maxLines(NEWS_CONTENT_MAX_LINES)
            .margin({ top: $r('app.string.news_content_margin') })
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(CommonConstants.LAYOUT_WEIGHT)
        .alignItems(VerticalAlign.Top)

        Text(this.newsTime)
          .fontSize($r('app.integer.news_time_font_size'))
          .fontColor($r('app.color.news_time_fontColor'))
          .height($r('app.string.news_content_height'))
          .textAlign(TextAlign.Start)
          .maxLines(NEWS_TIME_MAX_LINES)
          .margin({
            top: $r('app.string.news_content_margin'),
            bottom: $r('app.string.news_content_margin')
          })
          .textOverflow({ overflow: TextOverflow.None })
      }
      .margin({ right: $r('app.string.news_column_margin') })
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(CommonConstants.LAYOUT_WEIGHT)

      if (this.newsImage !== '') {
        Image($rawfile(`${this.newsImage}`))
          .height($r('app.string.list_image_height'))
          .width($r('app.string.list_image_weight'))
          .borderRadius($r('app.float.image_border_radius'))
          .margin({
            top: $r('app.string.image_margin'),
            bottom: $r('app.string.image_margin')
          })
      }
    }
    .padding({
      left: $r('app.string.news_row_padding'),
      right: $r('app.string.news_row_padding')
    })
    .height($r('app.string.news_item_height'))
  }

  // [EndExclude news_item]
}

// [End news_item]

class JsonNewsList {
  public newsList: NewsData[] = [];
}

class JsonNewsData {
  private jsonFileDir: string = '';

  constructor(jsonFileDir: string) {
    this.jsonFileDir = jsonFileDir;
  }

  getNewsData(): Array<NewsData> {
    let newsModelBuckets: NewsData[] = [];
    try {
      let value = uiContext!.getHostContext()!.resourceManager.getRawFileContentSync(this.jsonFileDir);
      let textDecoder = util.TextDecoder.create('utf-8', {
        ignoreBOM: true
      });
      let textDecoderResult = textDecoder.decodeToString(new Uint8Array(value.buffer));
      let jsonObj: JsonNewsList = JSON.parse(textDecoderResult) as JsonNewsList;
      let newsModelObj = jsonObj.newsList;
      for (let i = CommonConstants.ZERO; i < newsModelObj.length; i++) {
        let contactTemp = new NewsData(newsModelObj[i].newsId, newsModelObj[i].newsTitle,
          newsModelObj[i].newsContent, newsModelObj[i].newsTime, newsModelObj[i].newsImage);
        newsModelBuckets.push(contactTemp);
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'JsonNewsData',
        `getRawFileContentSync failed, error code=${err.code}, message=${err.message}`);
    }
    return newsModelBuckets;
  }
}

function getNews(mockFileDir: string): Array<NewsData> {
  let jsonObj: JsonNewsData = new JsonNewsData(mockFileDir);
  let newsModelMockData: NewsData[] = jsonObj.getNewsData();
  return newsModelMockData;
}
