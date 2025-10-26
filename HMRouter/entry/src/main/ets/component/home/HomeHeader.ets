/*
 *   Copyright (c) 2024 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

import { deviceInfo } from '@kit.BasicServicesKit';
import { BreakpointConstants } from '../common/constants/BreakpointConstants';
import { CommonConstants } from '../common/constants/CommonConstants';
import { ResourceUtil } from '../common/utils/ResourceUtil';
import { BreakpointType } from '../common/utils/BreakpointType';
import { HomeConstants } from '../common/constants/HomeConstants';

@Component
export struct HomeHeader {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink('topRectHeight') topRectHeight: number = 0;

  build() {
    Column() {
      GridRow({
        columns: {
          sm: BreakpointConstants.GRID_ROW_COLUMNS[0],
          md: BreakpointConstants.GRID_ROW_COLUMNS[4],
          lg: BreakpointConstants.GRID_ROW_COLUMNS[2]
        }
      }) {
        GridCol({
          span: {
            sm: BreakpointConstants.GRID_COLUMN_SPANS[2],
            md: BreakpointConstants.GRID_COLUMN_SPANS[6],
            lg: BreakpointConstants.GRID_COLUMN_SPANS[3]
          }
        }) {
          this.topTabBar();
        }
        .padding({
          top: deviceInfo.deviceType === CommonConstants.DEVICE_TYPES[0] ? 0 : this.topRectHeight
        })
        .height(deviceInfo.deviceType === CommonConstants.DEVICE_TYPES[0] ? CommonConstants.TAB_BAR_HEIGHT :
          CommonConstants.TAB_BAR_HEIGHT + this.topRectHeight);

        GridCol({
          span: {
            sm: BreakpointConstants.GRID_COLUMN_SPANS[2],
            md: BreakpointConstants.GRID_COLUMN_SPANS[2],
            lg: BreakpointConstants.GRID_COLUMN_SPANS[2]
          }
        }) {
          this.searchBar();
        }
        .padding({
          top: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM || deviceInfo.deviceType ===
          CommonConstants.DEVICE_TYPES[0] ? 0 : this.topRectHeight
        })
        .height(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM || deviceInfo.deviceType ===
        CommonConstants.DEVICE_TYPES[0] ? CommonConstants.TAB_BAR_HEIGHT : CommonConstants.TAB_BAR_HEIGHT +
        this.topRectHeight);
      };
    };
  }

  @Builder
  topTabBar() {
    List({
      space: new BreakpointType(HomeConstants.HOME_HEADER_LIST_SPACES[0], HomeConstants.HOME_HEADER_LIST_SPACES[1],
        HomeConstants.HOME_HEADER_LIST_SPACES[2]).getValue(this.currentBreakpoint)
    }) {
      ForEach(HomeConstants.TOP_BAR_TEXTS, (item: string, index: number) => {
        ListItem() {
          Text(item)
            .fontSize(index === 0 ? $r('app.float.top_bar_text_selected_font') : $r('app.float.top_bar_text_font'))
            .lineHeight(index === 0 ? $r('app.float.top_bar_text_selected_line') : $r('app.float.top_bar_text_line'))
            .fontWeight(index === 0 ? CommonConstants.FONT_WEIGHT_500 : FontWeight.Normal)
            .fontColor(index === 0 ? $r('app.color.home_header_text_color_selected') : $r('app.color.home_header_text_color'));
        }
        .layoutWeight(1);
      }, (item: string, index: number) => item + index);
    }
    .scrollBar(BarState.Off)
    .alignListItem(ListItemAlign.Center)
    .listDirection(Axis.Horizontal)
    .padding({
      left: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ? $r('app.float.top_text_padding_left_sm') : 0,
      right: new BreakpointType($r('app.float.top_text_padding_right_sm'), $r('app.float.top_text_padding_right_md'),
        $r('app.float.top_text_padding_right_lg')).getValue(this.currentBreakpoint)
    })
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT);
  }

  @Builder
  searchBar() {
    Row() {
      Stack({alignContent: Alignment.Start}) {
        TextInput({placeholder: HomeConstants.SEARCH_PLACEHOLDER})
          .placeholderFont({
            size: $r('app.float.search_input_font'),
            weight: FontWeight.Normal
          })
          .placeholderColor($r('app.color.normal_font_color'))
          .height($r('app.float.search_input_height'))
          .fontSize($r('app.float.search_input_font'))
          .padding({
            left: $r('app.float.search_input_left'),
            right: $r('app.float.search_input_right')
          })
          .width(CommonConstants.FULL_PERCENT)
          .enableKeyboardOnFocus(false);

        // Search image.
        Image($r('app.media.ic_public_search'))
          .width($r('app.float.search_img_size'))
          .height($r('app.float.search_img_size'))
          .margin({left: $r('app.float.search_img_left')});
      }
      .alignSelf(ItemAlign.Center)
      .layoutWeight(1);

      // Scan image.
      Image($r('app.media.ic_public_scan'))
        .width(ResourceUtil.getCommonImgSize()[0])
        .height(ResourceUtil.getCommonImgSize()[0])
        .margin({
          left: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ?
          $r('app.float.search_img_margin_sm') : $r('app.float.search_img_margin')
        });

      // Message image.
      Image($r('app.media.ic_public_comments'))
        .width(ResourceUtil.getCommonImgSize()[0])
        .height(ResourceUtil.getCommonImgSize()[0])
        .margin({
          left: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ?
          $r('app.float.search_img_margin_sm') : $r('app.float.search_img_margin')
        });
    }
    .justifyContent(FlexAlign.Center)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT);
  }
}