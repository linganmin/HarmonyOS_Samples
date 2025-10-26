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

import { common } from '@kit.AbilityKit';
import { media } from '@kit.MediaKit';
import { display } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { HttpProxyCacheServer, HttpProxyCacheServerBuilder } from '@ohos/video-cache';
import { CommonConstants as Const } from '../common/CommonConstants';
import { handleTime } from '../utils/utils';
import GlobalProxyServer from '../model/GlobalProxyServer';
import AvPlayManager from '../model/VideoPlayerManager';

const TAG: string = 'Index';

@Entry
@Component
struct VideoCacheView {
  @StorageLink('playStatus') @Watch('updateImageStatus') playStatus: string = '';
  @StorageLink('currentCachePercent') currentCachePercent: number = 0;
  @State isPlaying: boolean = true;
  @State videoDuration: string = '00:00';
  @State windowWidth: number = Const.WINDOW_SIZE;
  @State windowHeight: number = Const.WINDOW_SIZE;
  @State xComponentWidth: number | null = null;
  @State xComponentHeight: number | null = null;
  @State currentTime: number = 0;
  @State total: number = Const.TOTAL;
  @State rotateAngle: number = 0;
  private surfaceId: string = '';
  private componentController: XComponentController = new XComponentController();
  private screenW: number = this.getUIContext().px2vp(display.getDefaultDisplaySync().width);
  @State curFoldStatus: display.FoldStatus = 0;
  private readonly DEVICESIZE: number = Const.DEVICE_SIZE;
  @State isFullScreen: boolean = false;
  private callBack: Callback<display.FoldStatus> = async (curFoldStatus: display.FoldStatus) => {
    if (this.curFoldStatus === curFoldStatus) {
      return;
    }
    this.curFoldStatus = curFoldStatus;
    this.hideNavBar(this.curFoldStatus);
  }

  aboutToAppear() {
    try {
      setTimeout(() => {
        this.rotateAnimation();
      }, Const.SET_TIMEOUT_TIME);
      this.windowWidth = display.getDefaultDisplaySync().width;
      this.windowHeight = display.getDefaultDisplaySync().height;
      this.xComponentWidth = this.windowWidth * Const.SURFACE_W;
      this.xComponentHeight = this.xComponentWidth / Const.SURFACE_H;
      if (display.isFoldable()) {
        this.regDisplayListener();
      } else {
        if (this.screenW >= this.DEVICESIZE) {
          this.navigationAnimation(true);
        } else {
          this.navigationAnimation(false);
        }
      }
      const server: HttpProxyCacheServer =
        new HttpProxyCacheServerBuilder(this.getUIContext().getHostContext() as common.UIAbilityContext).build();
      GlobalProxyServer?.getInstance()?.setServer(server);
    } catch (error) {
      hilog.error(0x0000, TAG, `aboutToAppear catch error, code: ${error.code}, message: ${error.message}`);
    }
  }

  /**
   * Register listener.
   */
  regDisplayListener(): void {
    try {
      this.hideNavBar(display.getFoldStatus());
      display.on('foldStatusChange', this.callBack);
    } catch (error) {
      hilog.error(0x0000, TAG, `regDisplayListener catch error, code: ${error.code}, message: ${error.message}`);
    }
  }

  hideNavBar(status: number): void {
    if (status === display.FoldStatus.FOLD_STATUS_FOLDED) {
      this.navigationAnimation(false);
    } else {
      this.navigationAnimation(true);
    }
  }

  navigationAnimation(isFullScreen: boolean): void {
    this.getUIContext().animateTo({
      duration: Const.DURATION,
      curve: Curve.EaseInOut,
    }, () => {
      this.isFullScreen = isFullScreen;
    })
  }

  /**
   * Rotate animation.
   */
  rotateAnimation() {
    hilog.info(0x0000, TAG, `AVPlayManager, rotateAnimation start`);
    this.getUIContext().animateTo({
      duration: Const.ANIMATION_DURATION,
      curve: Curve.Ease,
      iterations: -1,
      playMode: PlayMode.Normal,
      onFinish: () => {
        hilog.info(0x0000, TAG, 'play end');
      }
    }, () => {
      this.rotateAngle = Const.ROTATE_ANGLE;
    })
  }

  aboutToDisappear(): void {
    try {
      AvPlayManager.getInstance().videoRelease();
      if (display.isFoldable()) {
        display.off('foldStatusChange', this.callBack);
      }
    } catch (error) {
      hilog.error(0x0000, TAG, `aboutToDisappear catch error, code: ${error.code}, message: ${error.message}`);
    }
  }

  /**
   * Update image status.
   */
  updateImageStatus() {
    if (this.playStatus !== 'completed') {
      return;
    }
    this.isPlaying = false;
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        XComponent({
          id: 'Xcomponent',
          type: XComponentType.SURFACE,
          controller: this.componentController
        })
          .height(`${this.xComponentHeight}px`)
          .width(`${this.xComponentWidth}px`)
          .onLoad(() => {
            this.componentController.setXComponentSurfaceRect({
              surfaceWidth: Const.SURFACE_WIDTH,
              surfaceHeight: Const.SURFACE_HEIGHT
            });
            this.surfaceId = this.componentController.getXComponentSurfaceId();
            AvPlayManager.getInstance()
              .initPlayer(this.getUIContext().getHostContext() as common.UIAbilityContext,
                this.surfaceId, (avPlayer: media.AVPlayer) => {
                  avPlayer.on('timeUpdate', (time: number) => {
                    this.currentTime = time;
                  });
                  this.videoDuration = handleTime(avPlayer.duration);
                  this.total = avPlayer.duration;
                })
          })
        Image($r("app.media.video_cache_loading"))
          .width($r('app.integer.video_cache_loading_image_size'))
          .height($r('app.integer.video_cache_loading_image_size'))
          .rotate({ angle: this.rotateAngle })
          .visibility(this.currentTime === 0 && this.isPlaying ? Visibility.Visible : Visibility.None)
      }

      Row() {
        Image(this.isPlaying ? $r("app.media.video_cache_pause") : $r("app.media.video_cache_play"))
          .width($r('app.integer.video_cache_play_image_size'))
          .id('videoSwitch')
          .onClick(() => {
            this.isPlaying = !this.isPlaying;
            if (this.isPlaying) {
              AvPlayManager.getInstance().videoPlay();
            } else {
              AvPlayManager.getInstance().videoPause();
            }
          })
        Blank()
        Text(handleTime(this.currentTime))
          .fontColor(Color.White)
        Blank()
        Stack({ alignContent: Alignment.Center }) {
          Progress({ value: this.currentCachePercent, total: Const.TOTAL, type: ProgressType.Linear })
            .width($r('app.string.video_cache_progress_width_size'))
            .color($r('app.color.video_cache_progress_color'))
            .backgroundColor(Color.White)

          Progress({
            value: this.currentTime,
            total: this.total,
            type: ProgressType.Linear
          })
            .width($r('app.string.video_cache_progress_width_size'))
        }

        Blank()
        Text(this.videoDuration)
          .fontColor(Color.White)
      }
      .width(`${this.xComponentWidth}px`)
      .margin({ top: $r('app.integer.row_margin') })
    }
    .justifyContent(FlexAlign.Center)
    .layoutWeight(1)
    .backgroundColor(Color.Black)
    .height($r('app.string.video_cache_container_height_size'))
    .width($r('app.string.video_cache_container_width_size'))
    .padding($r('app.integer.padding'))
  }
}