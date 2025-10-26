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

import { MapComponent, mapCommon, map, site } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { geoLocationManager } from '@kit.LocationKit';
import { Logger, Common, BreakpointConstants, LocationUtil, DeviceScreen, BreakpointType } from '@ohos/commons/Index';
import { SearchResult } from '@ohos/home/Index';
import { RoutePlanView } from '@ohos/route/Index';
import { TabView } from './TabView';
import { MapConstants } from '../constants/MapConstants';

@Component
export struct MapView {
  @StorageLink('currentBreakpoint') @Watch('getHeight') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_MD;
  @StorageLink('searchInput') searchInput: string = '';
  @StorageLink('myLocation') myLocation: geoLocationManager.Location | undefined = undefined;
  @StorageLink('isSearch') isSearch: boolean = false;
  @StorageLink('sites') sites: Array<site.Site> | undefined = [];
  @StorageLink('isShowBack') isShowBack: boolean = false;
  @StorageLink('isOnShowRoute') isOnShowRoute: boolean = false;
  @Provide('pageInfo') pageInfo: NavPathStack = new NavPathStack();
  @State mapController?: map.MapComponentController | undefined = undefined;
  @State isShow: boolean = true;
  @State columnMaxHeight: number = 0;
  @State columnHeight: number = 269;
  @State tempColumnHeight: number = 269;
  @State isChangeHeight: boolean = false;
  @State isLeft: boolean = true;
  @State left: number = 24;
  @State tempLeft: number = 24;
  private mapOption?: mapCommon.MapOptions;
  private callback?: AsyncCallback<map.MapComponentController>;
  private panOptionHeight: PanGestureOptions = new PanGestureOptions({
    direction: PanDirection.Up | PanDirection.Down
  });
  private panOptionPosition: PanGestureOptions = new PanGestureOptions({
    direction: PanDirection.Left | PanDirection.Right,
    distance: 10
  });
  private smMaxHeight: number = DeviceScreen.getDeviceHeight() - 8 - (this.getUIContext().px2vp(AppStorage.get('topRectHeight') as number));
  private style: mapCommon.MyLocationStyle = {
    anchorU: 0.5,
    anchorV: 0.5,
    radiusFillColor: 0xff00FFFFFF,
    displayType: mapCommon.MyLocationDisplayType.FOLLOW
  };

  getHeight() {
    this.columnMaxHeight = new BreakpointType(this.smMaxHeight, Common.HEIGHT_MD).getValue(this.currentBreakpoint);
    AppStorage.setOrCreate('columnMaxHeight', this.columnMaxHeight);
    if (this.tempColumnHeight === this.smMaxHeight && this.currentBreakpoint === BreakpointConstants.BREAKPOINT_MD) {
      this.tempColumnHeight = Common.HEIGHT_MD;
    }
    if (this.tempColumnHeight === Common.HEIGHT_MD && this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM) {
      this.tempColumnHeight = this.smMaxHeight;
    }
  }

  async aboutToAppear() {
    this.getHeight();

    this.mapOption = {
      position: {
        target: {
          latitude: MapConstants.LATITUDE,
          longitude: MapConstants.LONGITUDE
        },
        zoom: MapConstants.ZOOM
      }
    };

    this.callback = async (err, mapController) => {
      if (!err) {
        this.mapController = mapController;
        this.mapController.on('mapLoad', () => {
          Logger.info('mapLoad success');
        });
        this.abilityEnabled();
        mapController.setMyLocationStyle(this.style);
        LocationUtil.getLocation(this.mapController).then((location: geoLocationManager.Location|undefined) => {
          if (!location) {
            return;
          }
          Logger.info('my location' + JSON.stringify(location));
          this.myLocation = location;
        });
        this.mapController.on('mapClick', () => {
          this.isShow = !this.isShow;
        })
      }
    };
    this.pageInfo.disableAnimation(true);
  }

  async abilityEnabled(): Promise<void> {
    this.mapController?.setMyLocationEnabled(true);
    this.mapController?.setMyLocationControlsEnabled(true);
    this.mapController?.setTrafficEnabled(true);
    this.mapController?.setBuildingEnabled(true);
    if (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM) {
      this.mapController?.setZoomControlsEnabled(false);
    }
    this.mapController?.moveCamera(map.zoomTo(MapConstants.ZOOM));
  }

  @Builder
  PageMap(name: string) {
    if (name === 'RoutePlanView') {
      RoutePlanView({
        mapController: this.mapController,
        columnHeight: this.columnHeight
      })
    }
  }
  // [Start map_view_build]
  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      MapComponent({ mapOptions: this.mapOption, mapCallback: this.callback })

      Column() {
        Row() {
          // [StartExclude map_view_build]
          Divider()
            .strokeWidth(4)
            .color('#33000000')
            .width('48vp')
            .lineCap(LineCapStyle.Round)
            .padding({ bottom: '16vp' })
          // [EndExclude map_view_build]
        }
        .height('26vp')
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .gesture(
          PanGesture(this.panOptionHeight)
            .onActionUpdate((event?: GestureEvent) => {
              if (event) {
                let height = this.columnHeight - event.offsetY;
                this.tempColumnHeight = height;
                if (this.tempColumnHeight < 150) {
                  this.tempColumnHeight = 150;
                }
                if (this.tempColumnHeight > this.columnMaxHeight) {
                  this.tempColumnHeight = this.columnMaxHeight;
                }
              }
            })
            .onActionEnd(() => {
              if (this.tempColumnHeight > (this.columnMaxHeight - 269) / 2 + 269) {
                this.columnHeight = this.columnMaxHeight;
                this.isShowBack = false;
              } else if (this.tempColumnHeight < (269 - 150) / 2 + 150) {
                this.columnHeight = 150;
                this.isShowBack = true;
              } else {
                this.columnHeight = 269;
                this.isShowBack = true;
              }
              this.tempColumnHeight = this.columnHeight;
            })
        )

        // [StartExclude map_view_build]
        if (!this.isSearch) {
          TabView({ mapController: this.mapController, columnHeight: this.columnHeight })
        } else {
          Navigation(this.pageInfo) {
            SearchResult({ mapController: this.mapController, columnHeight: this.tempColumnHeight })
              .margin({ bottom: $r('app.float.tab_margin_bottom') })
          }
          .expandSafeArea([])
          .hideToolBar(true)
          .hideTitleBar(true)
          .hideBackButton(true)
          .navDestination(this.PageMap)
          .width(Common.FULL_WIDTH)
        }
        // [EndExclude map_view_build]
      }
      // [StartExclude map_view_build]
      .expandSafeArea((this.tempColumnHeight === this.columnMaxHeight ? [SafeAreaType.KEYBOARD] : []),
        (this.tempColumnHeight === this.columnMaxHeight ? [SafeAreaEdge.BOTTOM] : []))
      .backgroundColor(Color.White)
      .visibility(this.isShow ? Visibility.Visible : Visibility.None)
      .borderRadius({
        topLeft: $r('app.float.border_radius'),
        topRight: $r('app.float.border_radius'),
        bottomLeft: new BreakpointType($r('app.float.border_zero'),
          $r('app.float.border_radius')).getValue(this.currentBreakpoint),
        bottomRight: new BreakpointType($r('app.float.border_zero'),
          $r('app.float.border_radius')).getValue(this.currentBreakpoint)
      })
      .width(new BreakpointType($r('app.string.full_percent'), $r('app.float.width_md')).getValue(this.currentBreakpoint))
      .height(this.tempColumnHeight)
      .padding({
        top: $r('app.float.column_padding_top'),
        bottom: new BreakpointType($r('app.float.column_padding_bottom_wide'),
          $r('app.float.column_padding_bottom_narrow')).getValue(this.currentBreakpoint)
      })
      .margin({
        bottom: new BreakpointType($r('app.float.null_margin'), $r('app.float.column_margin_bottom'))
          .getValue(this.currentBreakpoint),
        left: new BreakpointType(0, this.tempLeft).getValue(this.currentBreakpoint)
      })
      // [EndExclude map_view_build]
      .gesture(
        PanGesture(this.panOptionPosition)
          .onActionUpdate((event?: GestureEvent) => {
            if (event) {
              let position = this.left + event.offsetX;
              this.tempLeft = position;
              if (this.tempLeft < 24) {
                this.tempLeft = 24;
              }
              if (this.tempLeft > 350) {
                this.tempLeft = 350;
              }
            }
          })
          .onActionEnd(() => {
            if (this.tempLeft < 200) {
              this.left = 24;
            } else {
              this.left = 350;
            }
            this.tempLeft = this.left;
          })
      )
      // [StartExclude map_view_build]
      Button({ type: ButtonType.Circle }) {
        Image($r('app.media.back'))
          .width($r('app.float.button_back_icon'))
      }
      .width($r('app.float.button_back'))
      .height($r('app.float.button_back'))
      .backgroundColor($r('app.color.back_button'))
      .visibility((this.isShowBack && this.isOnShowRoute) ? Visibility.Visible : Visibility.None)
      .margin({
        bottom: DeviceScreen.getDeviceHeight() - MapConstants.BUTTON_BOTTOM,
        left: new BreakpointType($r('app.float.back_button_left_sm'), $r('app.float.back_button_left_md'))
          .getValue(this.currentBreakpoint)
      })
      .onClick(() => {
        this.isShowBack = false;
        this.isOnShowRoute = false;
        this.pageInfo.pop();
        this.mapController?.clear();
      })
      // [EndExclude map_view_build]
    }
    .height('100%')
    .width('100%')
  }
  // [End map_view_build]
}