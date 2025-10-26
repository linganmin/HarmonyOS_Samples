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

import { LengthMetrics, window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Logger } from '../utils/Logger';
import tetrahedron_napi from 'libtetrahedron_napi.so';
import { RotationType } from '../utils/Constants';

interface Areas {
  top: number,
  right: number,
  bottom: number,
  left: number,
  heightBreakpoint: number,
  widthBreakpoint: number
}

// [Start get_safeAreaPixel]
function getTop(avoidArea: window.AvoidAreaOptions | undefined): number {
  let result: number = 0;
  if (avoidArea !== undefined) {
    if (avoidArea.area.topRect.height) {
      result = avoidArea.area.topRect.top + avoidArea.area.topRect.height;
    }
  } else {
    hilog.error(0x0000, '3D', 'Can not get TopSafeAreaPixel, avoidArea visible false');
  }
  return result;
}

function getBottom(avoidArea: window.AvoidAreaOptions | undefined, windowHeight: number): number {
  let result: number = 0;
  if (avoidArea !== undefined) {
    if (avoidArea.area.bottomRect.height) {
      result = windowHeight - avoidArea.area.bottomRect.top;
    }
  } else {
    hilog.error(0x0000, '3D', 'Can not get BottomSafeAreaPixel, avoidArea visible false');
  }
  return result;
}

function getLeft(avoidArea: window.AvoidAreaOptions | undefined): number {
  let result: number = 0;
  if (avoidArea !== undefined) {
    if (avoidArea.area.leftRect.width) {
      result = avoidArea.area.leftRect.left + avoidArea.area.leftRect.width;
    }
  } else {
    hilog.error(0x0000, '3D', 'Can not get LeftSafeAreaPixel, avoidArea visible false');
  }
  return result;
}

function getRight(avoidArea: window.AvoidAreaOptions | undefined, windowWidth: number): number {
  let result: number = 0;
  if (avoidArea !== undefined) {
    if (avoidArea.area.rightRect.width) {
      result = windowWidth - avoidArea.area.rightRect.left;
    }
  } else {
    hilog.error(0x0000, '3D', 'Can not get RightSafeAreaPixel, avoidArea visible false');
  }
  return result;
}
// [End get_safeAreaPixel]

// [Start breakPoint2Native]
@Entry
@Component
struct Index {
  // [StartExclude breakPoint2Native]
  @State angleArray: Array<number> = new Array<number>();
  @State enableRotate: boolean = false;
  // [EndExclude breakPoint2Native]
  // Define the variables passed into the Native side.
  @State cutoutAreas: Areas = {
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    heightBreakpoint: 0,
    widthBreakpoint: 0
  };
  // [StartExclude breakPoint2Native]
  // [Start padding]
  @State localPadding: LocalizedPadding = { top: LengthMetrics.vp(0), start: LengthMetrics.vp(0) };
  // [StartExclude padding]
  // [EndExclude breakPoint2Native]
  // Watching the changes in horizontal and vertical breakpoint values.
  @StorageLink('currentHeightBreakpoint') @Watch('breakPointChange') heightBreakpoint: HeightBreakpoint =
    HeightBreakpoint.HEIGHT_SM;
  @StorageLink('currentWidthBreakpoint') @Watch('breakPointChange') widthBreakpoint: WidthBreakpoint =
    WidthBreakpoint.WIDTH_XS;
  // [StartExclude breakPoint2Native]
  // [EndExclude padding]
  // [Start get_avoidAreas]
  @StorageLink('cutout') @Watch('cutoutChange') avoidAreas: window.AvoidAreaOptions | undefined = undefined;
  // [StartExclude padding]
  @StorageLink('windowHeight') windowHeight: number = 0;
  @StorageLink('windowWidth') windowWidth: number = 0;
  // [StartExclude get_avoidAreas]
  private xComponentId = 'tetrahedron';
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.All });
  // [EndExclude breakPoint2Native]

  // Breakpoint change, triggering value transfer.
  breakPointChange() {
    this.cutoutAreas.heightBreakpoint = this.heightBreakpoint;
    this.cutoutAreas.widthBreakpoint = this.widthBreakpoint;
    // Encapsulate the Native method and pass in a breakpoint.
    tetrahedron_napi.objectPassing(this.cutoutAreas);
  }
  // [EndExclude padding]
  // [EndExclude get_avoidAreas]
  // [StartExclude breakPoint2Native]
  cutoutChange() {
    let topPX = getTop(this.avoidAreas);
    let rightPX = getRight(this.avoidAreas, this.windowWidth);
    let bottomPX = getBottom(this.avoidAreas, this.windowHeight);
    let leftPX = getLeft(this.avoidAreas);

    // [StartExclude padding]
    // [StartExclude get_avoidAreas]
    this.cutoutAreas = {
      top: topPX,
      right: rightPX,
      bottom: bottomPX,
      left: leftPX,
      heightBreakpoint: this.heightBreakpoint,
      widthBreakpoint: this.widthBreakpoint
    };
    // [EndExclude padding]

    this.localPadding = {
      top: LengthMetrics.px(topPX),
      end: LengthMetrics.px(rightPX),
      bottom: LengthMetrics.px(bottomPX),
      start: LengthMetrics.px(leftPX)
    }
    // ArkTS2Native
    tetrahedron_napi.objectPassing(this.cutoutAreas);
    // [EndExclude get_avoidAreas]
  }
  // [End get_avoidAreas]

  // [StartExclude padding]
  async aboutToAppear() {
    Logger.info('aboutToAppear');
    this.angleArray[0] = 30;
    this.angleArray[1] = 45;

    let topPX = getTop(this.avoidAreas);
    let rightPX = getRight(this.avoidAreas, this.windowWidth);
    let bottomPX = getBottom(this.avoidAreas, this.windowHeight);
    let leftPX = getLeft(this.avoidAreas);

    this.cutoutAreas = {
      top: topPX,
      right: rightPX,
      bottom: bottomPX,
      left: leftPX,
      heightBreakpoint: this.heightBreakpoint,
      widthBreakpoint: this.widthBreakpoint
    };

    this.localPadding = {
      top: LengthMetrics.px(topPX),
      end: LengthMetrics.px(rightPX),
      bottom: LengthMetrics.px(bottomPX),
      start: LengthMetrics.px(leftPX)
    }

    tetrahedron_napi.objectPassing(this.cutoutAreas);
  }
  // [EndExclude padding]

  build() {
    // [StartExclude padding]
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        Column() {
          XComponent({
            id: this.xComponentId,
            type: XComponentType.SURFACE,
            libraryname: 'tetrahedron_napi'
          })
            .onLoad(() => {
              Logger.info('onLoad');
            })
            .id('tetrahedron')
            .onDestroy(() => {
              Logger.info('onDestroy');
            })
            .id('xComponent')
            .backgroundColor(Color.White)
        }
        .justifyContent(FlexAlign.SpaceAround)
        .alignItems(HorizontalAlign.Center)
        .height('100%')
        .width('100%')
        .backgroundColor(Color.White)
        .borderRadius(24)
      }
      .gesture(
        PanGesture(this.panOption)
          .onActionStart(() => {
            Logger.info('Gesture onActionStart');
          })
          .onActionUpdate((event: GestureEvent) => {
            tetrahedron_napi.setRotate(RotationType.STOP);
            this.enableRotate = false;
            this.angleArray = tetrahedron_napi.updateAngle(event.offsetX, event.offsetY);
            Logger.info('Gesture onActionUpdate : offSet ' + event.offsetX + ',' + event.offsetY);
          })
          .onActionEnd(() => {
            Logger.info('Gesture onActionEnd');
          })
      )
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Row({ space: 12 }) {
        Button(this.enableRotate ? $r('app.string.btn_stop_rotation') : $r('app.string.btn_auto_rotation'),
          { type: ButtonType.Capsule, stateEffect: true })
          .fontSize(16)
          .onClick(() => {
            if (this.enableRotate) {
              tetrahedron_napi.setRotate(RotationType.STOP);
              this.enableRotate = false;
            } else {
              tetrahedron_napi.setRotate(RotationType.AUTO);
              this.enableRotate = true;
            }
          })
          .layoutWeight(1)

        Button($r('app.string.btn_damping_rotation'), { type: ButtonType.Capsule, stateEffect: true })
          .fontSize(16)
          .onClick(() => {
            this.enableRotate = false;
            tetrahedron_napi.setRotate(RotationType.DAMPING);
          })
          .layoutWeight(1)
      }
      .hitTestBehavior(HitTestMode.Transparent)
      .padding({
        left: this.widthBreakpoint === WidthBreakpoint.WIDTH_SM ? 12 : 24,
        right: this.widthBreakpoint === WidthBreakpoint.WIDTH_SM ? 12 : 24,
        bottom: 50
      })
    }
    // [EndExclude padding]
    .padding(this.localPadding)
  }
  // [End padding]
  // [EndExclude breakPoint2Native]
}
// [End breakPoint2Native]
