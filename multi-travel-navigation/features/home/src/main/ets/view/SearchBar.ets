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
import { map, mapCommon, site } from '@kit.MapKit';
import { Common, LocationUtil } from '@ohos/commons/Index';
import { SearchSiteModel } from '@ohos/route/Index';
import { HomeConstants } from '../constants/HomeConstants';

@Component
export struct SearchBar {
  @StorageLink('searchInput') searchInput: string = '';
  @StorageLink('sites') sites: Array<site.Site> | undefined = [];
  @StorageLink('isSearch') isSearch: boolean = false;
  @Link mapController: map.MapComponentController;
  @Link columnHeight: number;
  private searchSiteModel: SearchSiteModel = new SearchSiteModel();

  build() {
    Row() {
      Button({ type: ButtonType.Circle }) {
        Image($r('app.media.back'))
          .height($r('app.float.button_back_icon'))
      }
      .width($r('app.float.button_back'))
      .height($r('app.float.button_back'))
      .backgroundColor($r('app.color.back_button'))
      .visibility((this.isSearch && this.columnHeight > Common.HEIGHT_MIDDLE) ? Visibility.Visible : Visibility.None)
      .margin({
        right: $r('app.float.back_icon_margin')
      })
      .onClick(() => {
        this.searchInput = '';
        this.isSearch = false;
      })

      Stack({ alignContent: Alignment.End }) {
        Stack({ alignContent: Alignment.Start }) {
          TextInput({ placeholder: $r('app.string.textInput_holder'), text: this.searchInput })
            .width(Common.FULL_WIDTH)
            .height(Common.FULL_HEIGHT)
            .enableKeyboardOnFocus(false)
            .padding({
              left: $r('app.float.text_input_padding'),
              right: $r('app.float.side_distance')
            })
            .onChange((value: string) => {
              this.searchInput = value;
            })
            .onSubmit(() => {
              LocationUtil.getLocation(this.mapController).then((location: geoLocationManager.Location | undefined) => {
                if (!location) {
                  return;
                }
                let position: mapCommon.LatLng = {
                  longitude: location.longitude,
                  latitude: location.latitude
                };
                this.searchSiteModel.getNearByLocation(position, this.searchInput)
                  .then((nearByResult: site.NearbySearchResult | undefined) => {
                    if (nearByResult) {
                      this.sites = nearByResult.sites;
                      this.isSearch = true;
                    }
                  })
              })
            })

          Image($r('app.media.ic_public_input_search'))
            .width($r('app.float.search_image_size'))
            .height($r('app.float.search_image_size'))
            .margin({ left: $r('app.float.side_distance') })
        }

        if (this.isSearch) {
          Image($r('app.media.cancel'))
            .width($r('app.float.search_image_size'))
            .height($r('app.float.search_image_size'))
            .margin({ right: $r('app.float.side_distance') })
            .onClick(() => {
              this.searchInput = '';
              this.isSearch = false;
            })
        } else {
          Image($r('app.media.voice'))
            .width($r('app.float.search_image_size'))
            .height($r('app.float.search_image_size'))
            .margin({ right: $r('app.float.side_distance') })
        }
      }
      .layoutWeight(1)
      .width((this.isSearch && this.columnHeight > Common.HEIGHT_MIDDLE) ?
        HomeConstants.SEARCHBAR_WIDTH : Common.FULL_WIDTH)
      .height(Common.FULL_HEIGHT)
    }
    .height($r('app.float.search_height'))
  }
}