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

import { geoLocationManager } from '@kit.LocationKit';
import { map, site, navi } from '@kit.MapKit';
import { BreakpointConstants, BreakpointType, Common, LocationUtil, Logger } from '@ohos/commons/Index';
import { SearchSiteModel } from '@ohos/route/Index';
import { SearchBar } from './SearchBar';
import { HomeConstants } from '../constants/HomeConstants';

@Component
export struct SearchResult {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_MD;
  @StorageLink('searchInput') searchInput: string = '';
  @StorageLink('sites') sites: Array<site.Site> | undefined = [];
  @StorageLink('routes') routes: Array<navi.Route> | undefined = [];
  @StorageLink('isShowRoute') isShowRoute: boolean = false;
  @StorageLink('terminalPoint') terminalPoint: string | undefined = '';
  @Consume('pageInfo') pageInfo: NavPathStack;
  @Link columnHeight: number;
  @Link mapController: map.MapComponentController;
  private searchSiteModel: SearchSiteModel = new SearchSiteModel();

  @Builder
  searchResultList() {
    ForEach(this.sites, (item: site.Site) => {
      Column() {
        Row() {
          Image($r('app.media.attraction1'))
            .width($r('app.float.search_result_image_size'))
            .height($r('app.float.search_result_image_size'))
            .borderRadius($r('app.float.location_image_border'))

          Column() {
            Text(item.name)
              .fontSize($r('app.float.search_result_name_font'))
              .fontColor($r('app.color.black_90'))
              .fontWeight(FontWeight.Medium)
              .maxLines(2)
            Row() {
              if (item.poi) {
                if (item.poi.openingHours && item.poi.openingHours.texts) {
                  Text(item.poi.openingHours.texts[0].split(': ')[1])
                    .fontSize($r('app.float.search_result_text_font'))
                    .fontColor($r('app.color.black_90'))
                }
              }
            }
            .width(Common.FULL_WIDTH)
            .margin({
              top: $r('app.float.search_result_row_side'),
              bottom: $r('app.float.search_result_row_bottom')
            })

            Row() {
              Text(HomeConstants.AWAY_FROM + item.distance + HomeConstants.METRE)
                .fontSize($r('app.float.search_result_text_font'))
                .fontColor($r('app.color.black_90'))
                .margin({ right: $r('app.float.search_result_row_side') })

              Text(item.addressComponent.adminLevel3)
                .fontSize($r('app.float.search_result_text_font'))
                .fontColor($r('app.color.black_90'))
            }
            .width(Common.FULL_WIDTH)
          }
          .margin({ left: $r('app.float.search_result_row_margin_side') })
          .alignItems(HorizontalAlign.Start)
          .width(new BreakpointType($r('app.string.location_name_width'),
            $r('app.float.information_column_width')).getValue(this.currentBreakpoint))
          .height(Common.FULL_HEIGHT)
        }
        .height($r('app.float.search_result_image_size'))
        .margin({
          top: $r('app.float.search_result_row_margin_side'),
          left: $r('app.float.search_result_row_margin_side')
        })

        Row() {
          Column() {
            Image($r('app.media.favor'))
              .height($r('app.float.search_result_favor_image'))
            Text($r('app.string.favor'))
              .fontSize($r('app.float.search_result_favor_font'))
              .margin({ top: $r('app.float.search_result_favor_margin') })
              .fontColor($r('app.color.public_text_color'))
          }
          .margin({ right: $r('app.float.search_result_row_margin_side') })

          Column() {
            Image($r('app.media.share'))
              .height($r('app.float.search_result_favor_image'))
            Text($r('app.string.share'))
              .fontSize($r('app.float.search_result_favor_font'))
              .margin({ top: $r('app.float.search_result_favor_margin') })
              .fontColor($r('app.color.public_text_color'))
          }
          .margin({ right: $r('app.float.text_button_distance') })

          Button($r('app.string.navigate'))
            .width(new BreakpointType($r('app.float.search_result_button_width_sm'),
              $r('app.float.search_result_button_width_lg')).getValue(this.currentBreakpoint))
            .height($r('app.float.search_result_button_height'))
            .fontColor($r('app.color.public_text_color'))
            .backgroundColor($r('app.color.white'))
            .border({
              width: $r('app.float.button_border_width'),
              color: $r('app.color.black')
            })
            .margin({ right: $r('app.float.search_result_row_side') })

          Button($r('app.string.route'))
            .width(new BreakpointType($r('app.float.search_result_button_width_sm'),
              $r('app.float.search_result_button_width_lg')).getValue(this.currentBreakpoint))
            .height($r('app.float.search_result_button_height'))
            .fontColor($r('app.color.start_navigate'))
            .backgroundColor($r('app.color.route_button'))
            .onClick(() => {
              this.terminalPoint = item.name;
              LocationUtil.getLocation(this.mapController).then((location: geoLocationManager.Location|undefined) => {
                if (!location) {
                  return;
                }
                this.searchSiteModel.getDrivingRoutes(location, item)
                  .then((routeResult: navi.RouteResult | undefined) => {
                    if (routeResult) {
                      Logger.info('Route plan success' + JSON.stringify(routeResult));
                      this.routes = routeResult.routes;
                      Logger.info('Routes: ' + JSON.stringify(this.routes));
                      this.isShowRoute = true;
                      this.pageInfo.pushPath({ name: 'RoutePlanView' });
                    }
                  })
              })
            })
        }
        .width(HomeConstants.FUNCTION_ROW_WIDTH)
        .justifyContent(FlexAlign.SpaceEvenly)
        .margin({
          left: $r('app.float.search_result_row_margin_side'),
          right: $r('app.float.search_result_row_margin_side'),
          top: this.columnHeight > Common.HEIGHT_MIDDLE ? 0 : $r('app.float.search_result_row_margin_side'),
          bottom: this.columnHeight > Common.HEIGHT_MIDDLE ? 0 : $r('app.float.search_result_row_margin_side')
        })
        .visibility(this.columnHeight > Common.HEIGHT_MIDDLE ? Visibility.None : Visibility.Visible)
      }
      .margin({
        left: $r('app.float.search_result_row_margin_dominate'),
        right: $r('app.float.search_result_row_margin_dominate'),
        top: this.columnHeight > Common.HEIGHT_MIDDLE ? 0 : $r('app.float.search_result_column_top'),
        bottom: this.columnHeight > Common.HEIGHT_MIDDLE ? 0 : $r('app.float.search_result_column_bottom')
      })
      .height(this.columnHeight > Common.HEIGHT_MIDDLE ?
        $r('app.float.search_result_height_low') : $r('app.float.search_result_height_high'))
      .borderRadius($r('app.float.search_result_column_border'))
      .shadow({
        radius: this.columnHeight > Common.HEIGHT_MIDDLE ? 0 : $r('app.float.shadow_radius'),
        color: $r('app.color.blur')
      })
    })
  }

  build() {
    Column() {
      Column() {
        SearchBar({
          columnHeight: this.columnHeight,
          mapController: this.mapController
        })

        Row() {
          Row() {
            Text($r('app.string.location_distance'))
              .fontSize($r('app.float.tip_font_size'))
              .fontColor($r('app.color.black_90'))

            Image($r('app.media.arrow_down'))
              .width($r('app.float.rank_image_width'))
          }

          Row() {
            Text($r('app.string.rank_recommendation'))
              .fontSize($r('app.float.tip_font_size'))
              .fontColor($r('app.color.black_90'))

            Image($r('app.media.arrow_down'))
              .width($r('app.float.rank_image_width'))
          }
        }
        .height($r('app.float.search_result_rank_height'))
        .width(Common.FULL_WIDTH)
        .justifyContent(FlexAlign.SpaceEvenly)
        .margin({ top: $r('app.float.divider_margin_top') })

        Divider()
          .width(Common.FULL_WIDTH)
          .strokeWidth(HomeConstants.DIVIDER_STROKE_WIDTH)
          .opacity($r('app.float.divider_opacity'))
          .margin({
            top: $r('app.float.divider_margin_top')
          })
      }
      .width(Common.FULL_WIDTH)
      .padding({
        left: $r('app.float.side_space'),
        right: $r('app.float.side_space')
      })

      Swiper() {
        this.searchResultList()
      }
      .height(this.columnHeight - HomeConstants.LIST_DIFFER_HEIGHT)
      .width(Common.FULL_WIDTH)
      .itemSpace(HomeConstants.SWIPER_ITEM_SPACE)
      .margin({
        left: $r('app.float.swiper_margin_left_right'),
        right: $r('app.float.swiper_margin_left_right'),
        bottom: $r('app.float.swiper_margin_bottom')
      })
      .indicator(false)
      .loop(false)
      .displayMode(SwiperDisplayMode.STRETCH)
      .visibility((this.columnHeight <= Common.HEIGHT_MIDDLE && this.columnHeight > Common.HEIGHT_LOW) ?
        Visibility.Visible : Visibility.None)

      List() {
        this.searchResultList()
      }
      .scrollBar(BarState.Off)
      .height(this.columnHeight - HomeConstants.LIST_DIFFER_HEIGHT)
      .visibility(this.columnHeight > Common.HEIGHT_MIDDLE ? Visibility.Visible : Visibility.None)
    }
    .padding({ bottom: $r('app.float.result_column_space') })
  }
}