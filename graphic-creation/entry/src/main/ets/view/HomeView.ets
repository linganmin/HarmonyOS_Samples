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
import { CommonConstants } from '../common/CommonConstants';
import { WaterFlowData, WaterFlowDataSource } from '../model/WaterFlowDataSource';
import { BreakpointType } from '../utils/BreakpointSystem';
import { DataUtils } from '../utils/DataUtils';
import { FlowItemView } from './FlowItemView';
import { SearchTitleView } from './SearchTitleView';

@Component
export struct HomeView {
  @Link dataSource: WaterFlowDataSource;
  @StorageLink(CommonConstants.BREAKPOINT_NAME) currentBreakpoint: string = CommonConstants.BREAKPOINT_SM;
  @State maxHeight: number = DataUtils.fromResToNumber($r('app.float.flow_item_height_max'));
  @State minHeight: number = DataUtils.fromResToNumber($r('app.float.flow_item_height_min'));

  aboutToAppear(): void {
  }

  build() {
    Flex({
      direction: FlexDirection.Column,
      wrap: FlexWrap.NoWrap,
      justifyContent: FlexAlign.Start,
      alignItems: ItemAlign.Center,
      alignContent: FlexAlign.Center
    }) {
      this.setTitle();
      this.tabWaterFlow();
    }
    .width($r('app.string.full_screen'))
    .height($r('app.string.full_screen'))
    .margin({ top: $r('app.float.window_status_bar_height') })
    .padding({
      left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
      right: $r('sys.float.ohos_id_elements_margin_horizontal_l')
    })
  }

  @Builder
  setTitle() {
    Row() {
      Row() {
        Row({ space: DataUtils.fromResToNumber($r('app.float.space_16')) }) {
          Text($r('app.string.home_follow'))
            .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
            .fontSize($r('sys.float.ohos_id_text_size_headline9'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .fontWeight(FontWeight.Medium)

          Text($r('app.string.home_recommends'))
            .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
            .fontSize($r('sys.float.ohos_id_text_size_headline7'))
            .fontColor($r('sys.color.ohos_id_color_emphasize'))
            .fontWeight(FontWeight.Medium)

          Text($r('app.string.home_same_city'))
            .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
            .fontSize($r('sys.float.ohos_id_text_size_headline9'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .fontWeight(FontWeight.Medium)
        }
        .alignItems(VerticalAlign.Bottom);
      }
      .height($r('app.string.full_screen'))

      SearchTitleView();
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .width($r('app.string.full_screen'))
    .height($r('app.float.navigation_height_sm'))
  }

  @Builder
  tabWaterFlow() {
    Column() {
      Column({ space: DataUtils.fromResToNumber($r('app.float.space_8')) }) {
        // eslint-disable-next-line @performance/waterflow-data-preload-check
        WaterFlow() {
          LazyForEach(this.dataSource, (item: WaterFlowData, index: number) => {
            FlowItem() {
              FlowItemView({ data: item })
            }
            .width($r('app.string.full_screen'))
            .backgroundColor(Color.White)
            .clip(true)
            .borderRadius($r('app.float.rounded_size_16'))
            .onAppear(() => {
              if (index === this.dataSource.totalCount() - 5) {
                this.dataSource.addPageData();
              }
            })
          })
        }
        .cachedCount(20)
        .columnsTemplate(new BreakpointType({
          sm: CommonConstants.GRID_NUM_TWO,
          md: CommonConstants.GRID_NUM_FOUR,
          lg: CommonConstants.GRID_NUM_FOUR
        }).getValue(this.currentBreakpoint))
        .columnsGap($r('sys.float.ohos_id_elements_margin_vertical_m'))
        .rowsGap($r('sys.float.ohos_id_elements_margin_horizontal_m'))
        .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
        .layoutDirection(FlexDirection.Column)
        .itemConstraintSize({
          minWidth: 0,
          maxWidth: $r('app.string.full_screen'),
          minHeight: 0,
        })
      }
      .width($r('app.string.full_screen'))
      .height($r('app.string.full_screen'))
    }
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .width($r('app.string.full_screen'))
    .height($r('app.string.full_screen'))
    .margin({ top: $r('app.float.margin_8') })
  }
}