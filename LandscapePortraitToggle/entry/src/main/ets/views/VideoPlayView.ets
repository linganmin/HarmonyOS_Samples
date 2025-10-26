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
import { display, window } from '@kit.ArkUI'
import { AVPlayerUtil } from '../utils/AVPlayerUtil'
// [Start set_orientation]
import { BusinessError, settings } from '@kit.BasicServicesKit'
import Logger from '../utils/Logger'
import { common } from '@kit.AbilityKit'

const TAG = 'VideoPlayViewLogTag';

@Component
export struct VideoPlayView {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  // [StartExclude set_orientation]
  @State aspect: number = 9 / 16 // default video height/width ratio value
  // [Start get_default_displaySync]
  @State xComponentWidth: number = this.getUIContext().px2vp(display.getDefaultDisplaySync().width);
  @State xComponentHeight: number = this.getUIContext().px2vp(display.getDefaultDisplaySync().width * this.aspect);
  // [End get_default_displaySync]
  @State isLandscape: boolean = false // Whether it is in full-screen playback state
  @State isVideoLock: boolean = false // Whether the video playback is locked
  @State orientationLockState: string = '1' // control center switch rotation ,value 1:enable 0：disable
  private xComponentController: XComponentController = new XComponentController()
  private player?: AVPlayerUtil
  // [EndExclude set_orientation]
  private windowClass = (this.context as common.UIAbilityContext).windowStage.getMainWindowSync();
  // [StartExclude set_orientation]
  // [Start about_to_appear]
  aboutToAppear(): void {
    try {
      // [StartExclude about_to_appear]
      // Get the rotation lock on state
      this.orientationLockState = settings.getValueSync(this.context, settings.general.ACCELEROMETER_ROTATION_STATUS,
        settings.domainName.DEVICE_SHARED)
      // [EndExclude about_to_appear]
      // [Start window_size_change]
      // [Start window_size_change_two]
      this.windowClass.on('windowSizeChange', (size) => {
        // [StartExclude about_to_appear]
        let viewWidth = this.getUIContext().px2vp(size.width)
        let viewHeight = this.getUIContext().px2vp(size.height)
        // [StartExclude window_size_change_two]
        // [StartExclude window_size_change]
        if (this.isExpandedOrHalfFolded()) {
          this.xComponentWidth = viewWidth
          this.xComponentHeight = viewWidth * this.aspect
        } else {
          // [EndExclude window_size_change]
          // [EndExclude window_size_change_two]
          if (viewWidth > viewHeight) {
            // [StartExclude window_size_change]
            if (display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED ||
              display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_HALF_FOLDED) {
              this.xComponentHeight = viewWidth * this.aspect
              this.xComponentWidth = viewWidth
            } else {
              this.xComponentWidth = viewHeight / this.aspect
              this.xComponentHeight = viewHeight
              this.isLandscape = true
            }
            this.windowClass.setSpecificSystemBarEnabled('navigationIndicator', false).catch((error: BusinessError) => {
              Logger.error(TAG,
                `setSpecificSystemBarEnabled err, error code: ${error.code}, error mesage: ${error.message}`);
            })
            // hide bottom navigation bar
            // [EndExclude window_size_change]
          } else {
            // [StartExclude window_size_change]
            this.xComponentHeight = viewWidth * this.aspect
            this.xComponentWidth = viewWidth
            this.windowClass.setSpecificSystemBarEnabled('navigationIndicator', true).catch((error: BusinessError) => {
              Logger.error(TAG, `setSpecificSystemBarEnabled err, error code: ${error.code}, error mesage: ${error.message}`);
            })
            // show bottom navigation bar
            this.isLandscape = false
            // [EndExclude window_size_change]
          }
          // [StartExclude window_size_change]
          // [StartExclude window_size_change_two]
        }
        // [EndExclude window_size_change_two]
        // [EndExclude window_size_change]
        // [EndExclude about_to_appear]
      })
      // [End window_size_change]
      // [End window_size_change_two]

      // [StartExclude about_to_appear]
      // Listen to get the rotary lock switch chapter table
      // [Start register_key_observer]
      settings.registerKeyObserver(this.context, settings.general.ACCELEROMETER_ROTATION_STATUS,
        settings.domainName.DEVICE_SHARED, () => {
          this.orientationLockState =
            settings.getValueSync(this.context, settings.general.ACCELEROMETER_ROTATION_STATUS,
              settings.domainName.DEVICE_SHARED)
        })
      // [End register_key_observer]
      // [EndExclude about_to_appear]
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `aboutToAppear err, error code: ${error.code}, error mesage: ${error.message}`);
    }
  }

  // [End about_to_appear]

  // [Start is_expanded_or_halfFolded]
  isExpandedOrHalfFolded(): boolean {
    let isExpandedOrHalfFolded: boolean = false;
    try {
      isExpandedOrHalfFolded = display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED ||
        display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_HALF_FOLDED
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `isExpandedOrHalfFolded err, error code: ${error.code}, error mesage: ${error.message}`);
    }
    return isExpandedOrHalfFolded;
  }
  // [End is_expanded_or_halfFolded]

  // [EndExclude set_orientation]
  setOrientation(orientation: number) {
    this.windowClass.setPreferredOrientation(orientation).then(() => {
      Logger.info('setWindowOrientation: ' + orientation + ' Succeeded.')
    }).catch((err: BusinessError) => {
      Logger.info('setWindowOrientation: ' + orientation + ' Failed. Cause: ' + JSON.stringify(err))
    })
  }

  // [End set_orientation]

  // [Start about_to_disappear]
  aboutToDisappear(): void {
    // [StartExclude about_to_disappear]
    settings.unregisterKeyObserver(this.context, settings.general.ACCELEROMETER_ROTATION_STATUS,
      settings.domainName.DEVICE_SHARED)
    // [EndExclude about_to_disappear]
    this.windowClass.off('windowSizeChange')
  }

  // [End about_to_disappear]

  build() {
    Stack() {
      Column() {
        // [Start X_component]
        XComponent({ id: 'video_player_id', type: XComponentType.SURFACE, controller: this.xComponentController })
          .onLoad(() => {
            // [StartExclude X_component]
            try {
              this.player = new AVPlayerUtil(this.getUIContext())
              this.player.setSurfaceId(this.xComponentController.getXComponentSurfaceId())
              this.player.initPlayer('videoTest.mp4', (aspect: number) => {
                this.aspect = aspect
                this.xComponentHeight = this.getUIContext().px2vp(display.getDefaultDisplaySync().width * aspect)
                this.xComponentWidth = this.getUIContext().px2vp(display.getDefaultDisplaySync().width)
              })
            } catch (err) {
              let error = err as BusinessError;
              Logger.error(TAG, `getDefaultDisplaySync err, error code: ${error.code}, error mesage: ${error.message}`);
            }
            // [EndExclude X_component]
          })
          .width(this.xComponentWidth)
          .height(this.xComponentHeight)
        // [End X_component]
      }

      RelativeContainer() {
        if (!this.isVideoLock) {
          // [Start icon_back]
          Image($r('app.media.icon_back'))
            // [StartExclude icon_back]
            .height(24)
            .width(24)
            .margin({
              left: 16,
              top: this.isLandscape ? (AppStorage.get<number>('statusBarHeight') || 0) : 12
            })
              // [EndExclude icon_back]
            .onClick(() => {
              // [StartExclude icon_back]
              if (this.isExpandedOrHalfFolded()) {
                this.isLandscape = false
              } else {
                // [EndExclude icon_back]
                this.setOrientation(window.Orientation.USER_ROTATION_PORTRAIT)
                // [StartExclude icon_back]
              }
              // [EndExclude icon_back]
            })
          // [End icon_back]
        }

        if (this.isLandscape) {
          // [Start is_video_lock_image]
          Image(this.isVideoLock ? $r('app.media.icon_lock') : $r('app.media.icon_lock_open'))
            // [StartExclude is_video_lock_image]
            .height(24)
            .width(24)
            .fillColor(Color.White)
            .alignRules({
              top: { anchor: '__container__', align: VerticalAlign.Center },
              left: { anchor: '__container__', align: HorizontalAlign.Start }
            })
            .margin({ left: (AppStorage.get<number>('statusBarHeight') || 0) })
            .offset({ y: -12 })
              // [EndExclude is_video_lock_image]
            .onClick(() => {
              this.isVideoLock = !this.isVideoLock
              // [StartExclude is_video_lock_image]
              if (this.isExpandedOrHalfFolded() || this.orientationLockState === '0') {
                return
              }
              // [EndExclude is_video_lock_image]
              // [Start is_video_lock]
              if (this.isVideoLock) {
                this.setOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE)
              } else {
                this.setOrientation(window.Orientation.AUTO_ROTATION_UNSPECIFIED)
              }
              // [End is_video_lock]
            })
          // [End is_video_lock_image]
        }

        if (!this.isLandscape) {
          // [Start icon_zoom_in]
          Image($r('app.media.icon_zoom_in'))
            // [StartExclude icon_zoom_in]
            .height(24)
            .width(24)
            .alignRules({
              bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
              right: { anchor: '__container__', align: HorizontalAlign.End }
            })
            .margin({
              right: 16,
              bottom: 8
            })
              // [EndExclude icon_zoom_in]
            .onClick(() => {
              if (this.isExpandedOrHalfFolded()) {
                this.isLandscape = true
              } else {
                this.setOrientation(window.Orientation.USER_ROTATION_LANDSCAPE)
              }
            })
          // [End icon_zoom_in]
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height(this.isLandscape ? '100%' : this.xComponentHeight + (AppStorage.get<number>('statusBarHeight') ?? 0))
    .backgroundColor(Color.Black)
    .padding({ top: this.isLandscape ? 0 : (AppStorage.get<number>('statusBarHeight') || 0) })
  }
}

// [Start freeze_when_inactive]
@Component({ freezeWhenInactive: true })
  // Added custom component freezing function
struct VideoDetailView {
  build() {
    Scroll() {
      // [StartExclude freeze_when_inactive]
      Text('Hello')
        .fontSize(14)
        .fontColor($r('sys.color.mask_secondary'))
      // [EndExclude freeze_when_inactive]
    }
  }
}

// [End freeze_when_inactive]

// [Start Image_item]
@Builder
function ImageItem(imageSrc: ResourceStr) {
  Stack({}) {
    Image(imageSrc)
      .width('100%')
      .height('100%')
      .autoResize(true)// Use auto_resize attributes on images
      .borderRadius(8)
      .objectFit(ImageFit.Fill)
      .backgroundColor('#1AFFFFFF')
  }
}

// [End Image_item]

// [Start Tabs_view]
@Component
struct TabsView {
  @State isLayoutFullScreen: boolean = false

  build() {
    Tabs() {
      // [StartExclude Tabs_view]
      TabContent() {
        Text('Hello')
          .fontWeight(FontWeight.Regular)
          .fontColor(Color.Red)
      }

      // [EndExclude Tabs_view]
    }
    // Hide the height of the Tabs tab bar by whether the user needs to click to enter the full screen and hide it
    .barHeight(this.isLayoutFullScreen ? 0 : 50)
  }
}

// [End Tabs_view]