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

import HotList from '../view/HotList';
import LeftTextRightImageBgWhite from '../view/LeftTextRightImageBgWhite';
import LeftTextRightImageBgGray from '../view/LeftTextRightImageBgGray';
import NewsWithThreeImage from '../view/NewsWithImages';
import TopImageBottomText from '../view/TopImageBottomText';
import TopTextBottomVideo from '../view/TopTextBottomVideo';
import VideoCard from '../view/VideoCard';
import Header from '../view/Header';
import MultiImageViewModel from '../viewmodel/MultiImageViewModel';
import ImageAndTextViewModel, { News } from '../viewmodel/ImageAndTextViewModel';
import VideoListViewModel from '../viewmodel/VideoListViewModel';
import HotListViewModel from '../viewmodel/HotListViewModel';
import TopImageBottomTextViewModel from '../viewmodel/TopImageBottomTextViewModel';
import Constants from '../common/Constants';

@Component
export struct NewsListPage {
  @StorageProp('currentBreakpoint') curBp: string = Constants.BREAKPOINTS[1];
  private scroller: Scroller = new Scroller();
  private imageAndTextViewModel = new ImageAndTextViewModel();
  private multiImageList: News[] = new MultiImageViewModel().getMultiImageList();
  private newsList: News[] = this.imageAndTextViewModel.getNewsList();
  private videoList: News[] = new VideoListViewModel().getVideoList();
  private hotList: Resource[] = new HotListViewModel().getHotList();
  private topImageBottomTextList: News[] = new TopImageBottomTextViewModel().getNewsList();

  build() {
    Scroll(this.scroller) {
      Column() {
        Header()
        Column() {
          // [Start news_list_page]
          Column() {
            if (this.curBp === 'sm') {
              List({
                space: Constants.LIST_GUTTER
              }) {
                // [StartExclude news_list_page]
                ListItem() {
                  HotList({ hotList: this.hotList })
                }

                ListItem() {
                  NewsWithThreeImage({ news: this.multiImageList[2] })
                }

                ForEach(this.imageAndTextViewModel.getNewsListGroup(0), (news: News) => {
                  ListItem() {
                    LeftTextRightImageBgWhite({ news })
                  }

                }, (news: News) => news.getNewsID())

                ListItem() {
                  TopTextBottomVideo({ news: this.videoList[0] })
                }

                ListItem() {
                  NewsWithThreeImage({ news: this.multiImageList[3] })
                }

                ListItem() {
                  NewsWithThreeImage({ news: this.multiImageList[4] })
                }

                ForEach(this.imageAndTextViewModel.getNewsListGroup(1), (news: News) => {
                  ListItem() {
                    LeftTextRightImageBgWhite({ news })
                  }
                }, (news: News) => news.getNewsID())

                ListItem() {
                  TopTextBottomVideo({ news: this.videoList[1] })
                }
                // [EndExclude news_list_page]
              }
              .width(Constants.CONTENT_WIDTH)
            } else {
              GridRow({
                columns: {
                  md: Constants.GRID_ROW_COLUMNS[1],
                  lg: Constants.GRID_ROW_COLUMNS[2]
                },
                gutter: $r("app.float.news_list_common_space")
              }) {
                // [StartExclude news_list_page]
                GridCol() {
                  HotList({ hotList: this.hotList })
                }

                GridCol() {
                  TopImageBottomText({ news: this.topImageBottomTextList[0] })
                }

                GridCol() {
                  Column() {
                    LeftTextRightImageBgGray({ news: this.newsList[0] })
                    LeftTextRightImageBgGray({ news: this.newsList[1] })
                  }
                  .height($r("app.float.cards_height"))
                  .justifyContent(FlexAlign.SpaceBetween)
                }

                GridCol() {
                  Column() {
                    LeftTextRightImageBgGray({ news: this.newsList[2] })
                    LeftTextRightImageBgGray({ news: this.newsList[3] })
                  }
                  .height($r("app.float.cards_height"))
                  .justifyContent(FlexAlign.SpaceBetween)
                }
                // [EndExclude news_list_page]
              }
              // [StartExclude news_list_page]
              GridRow({
                columns: Constants.GRID_ALL_COLUMNS,
                gutter: $r("app.float.grid_gutter")
              }) {
                GridCol({
                  span: {
                    md: Constants.GRID_COLUMN_SPAN[2],
                    lg: Constants.GRID_COLUMN_SPAN[1]
                  }
                }) {
                  VideoCard({ news: this.videoList[0] })
                }

                GridCol({
                  span: {
                    md: Constants.GRID_COLUMN_SPAN[1],
                    lg: Constants.GRID_COLUMN_SPAN[0]
                  }
                }) {
                  TopImageBottomText({ news: this.topImageBottomTextList[1] })
                }

                GridCol({
                  span: {
                    md: Constants.GRID_COLUMN_SPAN[1],
                    lg: Constants.GRID_COLUMN_SPAN[0]
                  }
                }) {
                  TopImageBottomText({ news: this.topImageBottomTextList[2] })
                }
              }
              .margin({ top: $r("app.float.grid_gutter") })

              GridRow({
                columns: Constants.GRID_ALL_COLUMNS,
                gutter: $r("app.float.grid_gutter")
              }) {
                GridCol({
                  span: {
                    md: Constants.GRID_COLUMN_SPAN[1],
                    lg: Constants.GRID_COLUMN_SPAN[0]
                  }
                }) {
                  Column() {
                    LeftTextRightImageBgGray({ news: this.newsList[4] })
                    LeftTextRightImageBgGray({ news: this.newsList[5] })
                  }
                  .height($r("app.float.cards_height"))
                  .justifyContent(FlexAlign.SpaceBetween)
                }

                GridCol({
                  span: {
                    md: Constants.GRID_COLUMN_SPAN[1],
                    lg: Constants.GRID_COLUMN_SPAN[0]
                  }
                }) {
                  Column() {
                    LeftTextRightImageBgGray({ news: this.newsList[6] })
                    LeftTextRightImageBgGray({ news: this.newsList[7] })
                  }
                  .height($r("app.float.cards_height"))
                  .justifyContent(FlexAlign.SpaceBetween)

                }

                GridCol({
                  span: {
                    md: Constants.GRID_COLUMN_SPAN[2],
                    lg: Constants.GRID_COLUMN_SPAN[1]
                  }
                }) {
                  VideoCard({ news: this.videoList[1] })
                }
              }
              .margin({ top: $r("app.float.grid_gutter") })
              // [EndExclude news_list_page]
            }
          }
          // [End news_list_page]
        }
        .padding($r("app.float.container_padding"))
        .width(Constants.FULL_WIDTH)
        .backgroundColor(Color.White)
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Center)
      }
      .backgroundColor(Color.White)

    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.On)
    .scrollBarColor(Color.Gray)
    .edgeEffect(EdgeEffect.Spring)
  }
}