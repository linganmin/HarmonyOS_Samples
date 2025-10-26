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

import { abilityAccessCtrl, common } from '@kit.AbilityKit';
import { geoLocationManager } from '@kit.LocationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { i18n } from '@kit.LocalizationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CommonConstants } from '../constants/CommonConstants';
import { BreakpointConstants } from '../constants/BreakpointConstants';
import LocationUtil from '../utils/LocationUtil';
import { BreakpointType } from '../utils/BreakpointSystem';

const DOMAIN = 0x0000;
const TAG = 'BottomToolbar';
const FORMAT = '%{public}s';

@Component
export struct BottomToolbar {
  @State currentLocalInfo: ResourceStr[] | geoLocationManager.GeoAddress[] = CommonConstants.CURRENT_LOCAL_INFO;
  @State currentLocation: string = '';
  @State isDefaultLocation: boolean = true;
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('bottomHeight') bottomHeight: number = 0;
  @Watch('systemLanguage') @StorageLink('language') systemLanguages: string = '';
  @Link isAddLocalInfo: boolean;
  @Link selectLocalInfo: string | Resource;
  @Link isShowLocalInfo: boolean;
  @Link isKeyboard: boolean;
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private latitude: number = 0;
  private longitude: number = 0;
  private locale: string = i18n.System.getAppPreferredLanguage();

  private location(location: geoLocationManager.Location) {
    try {
      this.latitude = location.latitude;
      this.longitude = location.longitude;
      let reverseGeocodeRequest: geoLocationManager.ReverseGeoCodeRequest = {
        'locale': this.locale.toString().includes('zh') ? 'zh' : 'en',
        'latitude': this.latitude,
        'longitude': this.longitude
      };
      geoLocationManager.getAddressesFromLocation(reverseGeocodeRequest).then(data => {
        hilog.info(DOMAIN, TAG, FORMAT, 'GetAddressesFromLocation data :', JSON.stringify(data));
        if (data.length !== 0) {
          this.currentLocalInfo = [];
          data.forEach((item) => {
            this.currentLocalInfo.push(item.placeName!);
            this.currentLocalInfo.push(item.administrativeArea!);
            this.currentLocalInfo.push(item.subAdministrativeArea!);
            this.currentLocalInfo.push(item.subLocality!);
          })
        }
        if (data[0].placeName) {
          this.currentLocation = data[0].placeName;
        }
        this.isDefaultLocation = false;
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, TAG, FORMAT, 'GetAddressesFromLocation err:' + JSON.stringify(err));
      });
    } catch {
      hilog.error(DOMAIN, TAG, FORMAT, 'GetAddressesFromLocation err:');
    }
  };

  private getGeolocationOn: (location: geoLocationManager.Location) => void =
    (location: geoLocationManager.Location) => {
      this.location(location);
    };
  private getGeolocation: (err: BusinessError, location: geoLocationManager.Location) => void =
    (err: BusinessError, location: geoLocationManager.Location) => {
      if (err) {
        return;
      }
      this.location(location);
    };
  changeFocus: (isAllClose: boolean) => void = () => {
  };

  systemLanguage(): void {
    if (this.latitude !== undefined && this.longitude !== undefined) {
      this.locale = i18n.System.getAppPreferredLanguage();
      LocationUtil.getCurrentLocation(this.getGeolocation);
    }
  };

  addAppStorage(): void {
    AppStorage.set('isShowLocalInfo', this.isShowLocalInfo);
    AppStorage.set('isAddLocalInfo', this.isAddLocalInfo);
    AppStorage.set('selectLocalInfo', this.selectLocalInfo);
  }

  aboutToAppear(): void {
    this.requestPermissions();
  }

  aboutToDisappear(): void {
    LocationUtil.geolocationOff();
  }

  requestPermissions(): void {
    let atManager = abilityAccessCtrl.createAtManager();
    try {
      atManager.requestPermissionsFromUser(this.context, CommonConstants.REQUEST_PERMISSIONS).then(() => {
        LocationUtil.geolocationOn(this.getGeolocationOn);
      }).catch((err: BusinessError) => {
        hilog.info(DOMAIN, TAG, FORMAT,
          `RequestPermissionsFromUser failed. Cause code: ${err.code}, message: ${err.message}`);
      });
    } catch (err) {
      hilog.error(DOMAIN, TAG, FORMAT, 'requestPermissionsFromUser err' + JSON.stringify(err));
    }
  }

  characterElision(): string {
    let str = this.selectLocalInfo as string;
    let length = str.length;
    if (length > CommonConstants.END_SM_LOCAL_INFO && this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM) {
      return str.substring(CommonConstants.START_MD_LOCAL_INFO, CommonConstants.END_SM_LOCAL_INFO) +
      CommonConstants.OMITTED_CHARACTER;
    } else if (length > CommonConstants.END_MD_LOCAL_INFO &&
      this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD) {
      return str.substring(CommonConstants.START_MD_LOCAL_INFO, CommonConstants.END_MD_LOCAL_INFO) +
      CommonConstants.OMITTED_CHARACTER;
    } else {
      return str;
    }
  }

  getResourceString(resource: Resource): string {
    let resourceString: string = '';
    try {
      resourceString = this.getUIContext().getHostContext()!.resourceManager.getStringSync(resource.id);
    } catch (error) {
      hilog.error(DOMAIN, TAG, FORMAT, 'getResourceString err:' + JSON.stringify(error));
    }
    return resourceString;
  }

  build() {
    this.bottomToolbar();
  }

  /*
   * Bottom Toolbar
   */
  @Builder
  bottomToolbar() {
    Column() {
      // Bottom toolbar addition position.
      Column() {
        Row() {
          Image(this.isAddLocalInfo ? $r('app.media.ic_location_blue') : $r('app.media.ic_location'))
            .height($r('app.integer.location_icon_size'))
            .margin({
              left: $r('app.integer.location_icon_left'),
              right: $r('app.integer.location_icon_right')
            })
          Text() {
            Span(this.isAddLocalInfo ?
              (this.isDefaultLocation ? this.selectLocalInfo : this.characterElision()) : $r('app.string.add_local'))
              .fontSize($r('app.integer.text_size_body3'))
              .fontColor($r('sys.color.font_secondary'))
              .onClick(() => {
                this.changeFocus(true);
                this.isShowLocalInfo = !this.isShowLocalInfo;
                this.addAppStorage();
              })
            ImageSpan($r('app.media.ic_public_cancel'))
              .width($r('app.integer.cancel_icon_size_mini'))
              .height($r('app.integer.cancel_icon_size_mini'))
              .margin({
                bottom: $r('app.integer.cancel_icon_bottom'),
                left: $r('app.integer.cancel_icon_left')
              })
              .visibility(this.isAddLocalInfo ? Visibility.Visible : Visibility.None)
              .onClick(() => {
                this.isAddLocalInfo = false;
                this.addAppStorage();
              })
          }
          .align(Alignment.Top)
          .margin({ right: $r('app.integer.location_row_right') })
        }
        .backgroundColor($r('sys.color.background_secondary'))
        .height($r('app.integer.location_info_row_height'))
        .borderRadius($r('app.integer.border_radius5'))
      }
      .padding({
        left: new BreakpointType($r('sys.float.padding_level8'), $r('sys.float.padding_level8'),
          $r('sys.float.padding_level12'), $r('sys.float.padding_level16')).GetValue(this.currentBreakpoint),
        right: new BreakpointType($r('sys.float.padding_level8'), $r('sys.float.padding_level8'),
          $r('sys.float.padding_level12'), $r('sys.float.padding_level16')).GetValue(this.currentBreakpoint)
      })
      .backgroundColor($r('sys.color.background_primary'))
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .height($r('app.integer.location_row_height'))
      .width(CommonConstants.FULL_PERCENT)

      // The location information list is added to the toolbar at the bottom.
      Flex({ alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
        List({ space: CommonConstants.LIST_COMM_SPACE }) {
          ForEach(this.currentLocalInfo, (item: Resource, index: number) => {
            ListItem() {
              Text(item)
                .backgroundColor($r('sys.color.background_secondary'))
                .fontColor($r('sys.color.font_secondary'))
                .fontSize($r('app.integer.text_size_body3'))
                .borderRadius($r('app.integer.border_radius28'))
                .height($r('app.integer.text_publish_height'))
                .padding({
                  right: $r('app.integer.comm_padding_margin_mini'),
                  left: $r('app.integer.comm_padding_margin_mini')
                })
            }
            .onClick(() => {
              hilog.info(DOMAIN, TAG, FORMAT, `Number of the current picture: ${index}`);
              this.isAddLocalInfo = true;
              this.selectLocalInfo = item;
              this.addAppStorage();
            })
          }, (item: string, index: number) => JSON.stringify(item + index))
        }
        .alignListItem(ListItemAlign.Center)
        .width(CommonConstants.LOCAL_INFO_LIST_WIDTH)
        .listDirection(Axis.Horizontal)
        .scrollBar(BarState.Off)
        .backgroundColor($r('sys.color.background_secondary'))

        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize($r('app.integer.cancel_icon_size_mini1'))
          .fontColor([$r('sys.color.font_primary')])
          .onClick(() => {
            this.isShowLocalInfo = !this.isShowLocalInfo;
            this.addAppStorage();
          })
      }
      .visibility(this.isShowLocalInfo ? Visibility.Visible : Visibility.None)
      .borderWidth({
        top: $r('app.integer.default_border_width'),
        bottom: $r('app.integer.default_border_width')
      })
      .borderColor($r('app.color.bottom_border_color'))
      .padding({
        left: new BreakpointType($r('sys.float.padding_level8'), $r('sys.float.padding_level8'),
          $r('sys.float.padding_level12'), $r('sys.float.padding_level16')).GetValue(this.currentBreakpoint),
        right: new BreakpointType($r('sys.float.padding_level8'), $r('sys.float.padding_level8'),
          $r('sys.float.padding_level12'), $r('sys.float.padding_level16')).GetValue(this.currentBreakpoint)
      })
      .height($r('app.integer.location_info_height'))
      .width(CommonConstants.FULL_PERCENT)
      .backgroundColor($r('sys.color.background_secondary'))

      // Bottom toolbar picture.
      Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
        SymbolGlyph($r('sys.symbol.face_smiling'))
          .fontSize($r('app.integer.bottom_icon_size'))
          .fontColor([$r('sys.color.font_primary')])
          .margin({ right: $r('app.integer.comm_padding_margin') })
          .onClick(() => {
            try {
              this.getUIContext().getPromptAction().showToast({ message: $r('app.string.trigger_event') });
            } catch (err) {
              hilog.error(DOMAIN, TAG, FORMAT, `ShowToast failed. Cause code: ${err.code}, message: ${err.message}`);
            }
          })
        SymbolGlyph(this.isKeyboard ? $r('sys.symbol.list_bullet') : $r('sys.symbol.keyboard'))
          .fontSize($r('app.integer.bottom_icon_size'))
          .fontColor([$r('sys.color.font_primary')])
          .focusable(true)
          .margin({ right: $r('app.integer.comm_padding_margin') })
          .onClick(() => {
            this.isShowLocalInfo = false;
            this.isKeyboard = !this.isKeyboard;
            this.changeFocus(false);
          })
        SymbolGlyph($r('sys.symbol.arrowshape_turn_up_right'))
          .fontSize($r('app.integer.bottom_icon_size'))
          .fontColor([$r('sys.color.font_primary')])
          .margin({ right: $r('app.integer.comm_padding_margin') })
          .onClick(() => {
            try {
              this.getUIContext().getPromptAction().showToast({ message: $r('app.string.trigger_event') });
            } catch (err) {
              hilog.error(DOMAIN, TAG, FORMAT, `ShowToast failed. Cause code: ${err.code}, message: ${err.message}`);
            }
          })
        SymbolGlyph($r('sys.symbol.topic'))
          .fontSize($r('app.integer.bottom_icon_size'))
          .fontColor([$r('sys.color.font_primary')])
          .margin({ right: $r('app.integer.comm_padding_margin') })
          .onClick(() => {
            try {
              this.getUIContext().getPromptAction().showToast({ message: $r('app.string.trigger_event') });
            } catch (err) {
              hilog.error(DOMAIN, TAG, FORMAT, `ShowToast failed. Cause code: ${err.code}, message: ${err.message}`);
            }
          })
      }
      .backgroundColor($r('sys.color.background_secondary'))
      .width(CommonConstants.FULL_PERCENT)
      .height($r('app.integer.bottom_icon_region_height'))
      .padding({
        left: new BreakpointType($r('sys.float.padding_level8'), $r('sys.float.padding_level8'),
          $r('sys.float.padding_level12'), $r('sys.float.padding_level16')).GetValue(this.currentBreakpoint),
        right: new BreakpointType($r('sys.float.padding_level8'), $r('sys.float.padding_level8'),
          $r('sys.float.padding_level12'), $r('sys.float.padding_level16')).GetValue(this.currentBreakpoint)
      })
    }
    .padding({ bottom: this.isKeyboard ? 0 : this.bottomHeight })
    .backgroundColor($r('sys.color.background_secondary'))
    .justifyContent(FlexAlign.Center)
  }
}