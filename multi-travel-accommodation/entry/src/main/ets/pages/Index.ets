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

import { display } from '@kit.ArkUI';
import { CommonConstants } from '../commons/constants/CommonConstants';
import Logger from '../commons/utils/Logger';
import { LowPriceView } from '../view/LowPriceView';
import { HotelDetailsPage } from './HotelDetailsPage';
import { SearchTicketPage } from './SearchTicketPage';

class DirectoryItem {
  title: Resource | undefined = undefined;
  uri: string = '';
}

@Entry
@Component
struct Index {
  @StorageLink('breakPoint') breakPoint: string = CommonConstants.BREAK_POINT_SM;
  @StorageLink('isShowingCalendar') isShowingCalendar: boolean = false;
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  scroller: Scroller = new Scroller();
  isInitialization: boolean = false;
  private title: string | Resource = $r('app.string.EntryAbility_label');
  private directory: DirectoryItem[] = [
    {
      title: $r('app.string.HotelDetailPage'),
      uri: CommonConstants.HOTEL_DETAIL_PAGE_URL,
    },
    {
      title: $r('app.string.SearchTicketsPage'),
      uri: CommonConstants.SEARCH_TICKET_PAGE_URL,
    },
  ];

  @Builder
  PageMap(name: string) {
    if (name === CommonConstants.HOTEL_DETAIL_PAGE_URL) {
      HotelDetailsPage()
    } else if (name === CommonConstants.SEARCH_TICKET_PAGE_URL) {
      SearchTicketPage()
    } else {
      LowPriceView()
    }
  }

  build() {
    GridRow({
      breakpoints: {
        value: CommonConstants.BREAK_POINTS_VALUE,
        reference: BreakpointsReference.WindowSize
      },
      columns: {
        sm: CommonConstants.COLUMN_SM,
        md: CommonConstants.COLUMN_MD,
        lg: CommonConstants.COLUMN_LG
      },
      direction: GridRowDirection.Row
    }) {
      GridCol({
        span: {
          sm: CommonConstants.COLUMN_SM,
          md: CommonConstants.COLUMN_MD,
          lg: CommonConstants.COLUMN_LG
        }
      }) {
        Column() {
          Navigation(this.pageInfos) {
            Column() {
              ForEach(this.directory, (item: DirectoryItem, index) => {
                Button(item.title)
                  .width(CommonConstants.NINETY_PERCENT)
                  .margin({ top: $r('app.float.index_page_button_margin') })
                  .onClick(() => {
                    this.pageInfos.pushPath(new NavPathInfo(item.uri, []));
                    if (index === 0) {
                      let callback: Callback<display.FoldStatus> = (data: display.FoldStatus) => {
                        Logger.info('Listening enabled. Data: ' + JSON.stringify(data));
                        if (data === CommonConstants.NUMBER_ONE) {
                          this.pageInfos.replacePath(new NavPathInfo(CommonConstants.HOTEL_DETAIL_PAGE_URL, []));
                          return;
                        }
                        if (data === CommonConstants.NUMBER_TWO) {
                          this.isShowingCalendar = false;
                          this.pageInfos.replacePath(new NavPathInfo(CommonConstants.HOTEL_DETAIL_PAGE_URL, []));
                          return;
                        }
                      };
                      try {
                        display.on('foldStatusChange', callback);
                      } catch (exception) {
                        Logger.error('Failed to register callback. Code: ' + JSON.stringify(exception));
                      }
                    } else {
                      try {
                        display.off('foldStatusChange');
                      } catch (exception) {
                        console.error('Failed to unregister callback. Code: ' + JSON.stringify(exception));
                      }
                    }
                  })
              }, (item: DirectoryItem) => JSON.stringify(item))
            }
            .width(CommonConstants.FULL_WIDTH_PERCENT)
            .height(CommonConstants.FULL_WIDTH_PERCENT)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }
          .navDestination(this.PageMap)
          .mode(NavigationMode.Stack)
          .hideBackButton(true)
          .titleMode(NavigationTitleMode.Mini)
          .title(this.title)
        }
        .width(CommonConstants.FULL_WIDTH_PERCENT)
        .height(CommonConstants.FULL_WIDTH_PERCENT)
      }
    }
  }
}