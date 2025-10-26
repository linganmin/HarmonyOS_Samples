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

import ImageAndTextViewModel from '../viewmodel/ImageAndTextViewModelForNewsChannel';
import LeftTextRightImageBgWhite from '../view/LeftTextRightImageBgWhite';
import Constants from '../common/Constants';
import { News } from '../viewmodel/ImageAndTextViewModel';
import Header from '../view/Header';

@Component
export struct NewsChannel {
  @StorageProp('currentBreakpoint') curBp: string = Constants.BREAKPOINTS[1];
  private imageAndTextViewModel = new ImageAndTextViewModel();
  @State newsList: News[] = this.imageAndTextViewModel.getNewsListByBreakpoint(this.curBp);

  // [Start news_channel]
  build() {
    Column() {
      Header()
      GridRow({
        columns: 12,
        gutter: {
          x: { md: Constants.GRID_HORIZONTAL_GUTTER[0], lg: Constants.GRID_HORIZONTAL_GUTTER[1] },
          y: { sm: Constants.GRID_VERTICAL_GUTTER[0], md: Constants.GRID_VERTICAL_GUTTER[1] }
        }
      }) {
        ForEach(this.newsList, (news: News) => {
          GridCol({
            span: {
              sm: Constants.GRID_COL_SPAN[5],
              md: Constants.GRID_COL_SPAN[4]
            }
          }) {
            LeftTextRightImageBgWhite({ news })
          }
        }, (news: News) => news.getNewsID())
      }
      .onBreakpointChange((breakPoints: string) => {
        this.newsList = this.imageAndTextViewModel.getNewsListByBreakpoint(breakPoints);
      })
      .width(Constants.CONTENT_WIDTH)
    }
    .width(Constants.FULL_WIDTH)
    .justifyContent(FlexAlign.Center)
  }
  // [End news_channel]
}