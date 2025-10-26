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

import NewsWithThreeImages from '../view/NewsWithImages';
import MultiImageViewModel from '../viewmodel/MultiImageViewModelForMediaNews';
import Constants from '../common/Constants';
import { News } from '../viewmodel/ImageAndTextViewModel';
import Header from '../view/Header';

@Component
export struct MediaNews {
  @StorageProp('currentBreakpoint') curBp: string = Constants.BREAKPOINTS[1];
  private multiImageViewModel = new MultiImageViewModel();
  @State newsList: News[] = this.multiImageViewModel.getNewsListByBreakpoint(this.curBp);

  // [Start media_news]
  // src/main/ets/pages/MediaNews.ets
  build() {
    Column() {
      Header()
      GridRow({
        gutter: $r("app.float.grid_gutter_bigger")
      }) {
        ForEach(this.newsList, (news: News) => {
          GridCol({
            span: {
              sm: Constants.GRID_COL_SPAN[5],
              lg: Constants.GRID_COL_SPAN[4]
            }
          }) {
            NewsWithThreeImages({ news })
          }
        }, (news: News) => news.getNewsID())
      }
      .onBreakpointChange((breakPoints: string) => {
        // Return the number of rendered data records based on the breakpoint situation
        this.newsList = this.multiImageViewModel.getNewsListByBreakpoint(breakPoints);
      })
      .width(Constants.CONTENT_WIDTH)
    }
    .width(Constants.FULL_WIDTH)
    .justifyContent(FlexAlign.Center)
  }
  // [End media_news]
}