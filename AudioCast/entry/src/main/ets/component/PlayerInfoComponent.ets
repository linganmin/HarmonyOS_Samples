/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { BusinessError } from '@kit.BasicServicesKit';
import { effectKit } from '@kit.ArkGraphics2D';
import { image } from '@kit.ImageKit';
import { common } from '@kit.AbilityKit';
import { display } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { SongItem } from '../model/SongData';
import { ColorConversion } from '../common/utils/ColorConversion';
import { BreakpointConstants } from '../common/constants/BreakpointConstants';
import { LyricsComponent } from './LyricsComponent';
import { TopAreaComponent } from './TopAreaComponent';
import { MusicInfoComponent } from './MusicInfoComponent';
import { ControlAreaComponent } from './ControlAreaComponent';
import { AVSessionController } from '../controller/AVSessionController';
import { AudioPlayerController } from '../controller/AudioPlayerController';
import { AudioCastController } from '../controller/AudioCastController';
import { AudioRendererController } from '../controller/AudioRendererController';
import { ToneQuality, MusicPlayMode } from '../model/SongData';

const TAG = 'PlayerInfoComponent';

@Component
export struct PlayerInfoComponent {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageProp('selectIndex') @Watch('getImageColor') selectIndex: number = 0;
  @StorageLink('songList') songList: SongItem[] = [];
  @StorageLink('imageColor') imageColor: string = 'rgba(0, 0, 2, 1.00)';
  @StorageLink('topHeight') topHeight: number = 0;
  @StorageLink('bottomHeight') bottomHeight: number = 0;
  @StorageLink('pageShowTime') pageShowTime: number = 0;
  @StorageLink('isFoldFull') isFoldFull: boolean = false;
  @StorageLink('avSessionController') avSessionController ?: AVSessionController = undefined;
  @StorageLink('avPlayerController') avPlayerController?: AudioPlayerController = undefined;
  @StorageLink('audioRendererController') audioRendererController?: AudioRendererController = undefined;
  @StorageLink('audioCastController') audioCastController?: AudioCastController = undefined;
  @State imageLabel: PixelMap | Resource = this.songList[this.selectIndex].label;
  @State isShowControl: boolean = true;
  @State isShowControlLg: boolean = false;
  @State isTablet: boolean = true;
  @State isTabletFalse: boolean = false;
  @State intervalID: number = 0;
  private context: common.UIAbilityContext | undefined = AppStorage.get('context');
  private callback: Callback<display.FoldDisplayMode> = (data: display.FoldDisplayMode) => {
    if (canIUse('SystemCapability.Window.SessionManager')) {
      if (data === display.FoldDisplayMode.FOLD_DISPLAY_MODE_FULL) {
        this.isFoldFull = true;
      } else {
        this.isFoldFull = false;
      }
    }
  };

  aboutToAppear(): void {
    this.getImageColor();
    if (!this.avSessionController) {
      this.avSessionController = AVSessionController.getInstance();
      this.initAVSession();
    }
    try {
      if (canIUse('SystemCapability.Window.SessionManager')) {
        let mode = display.getFoldDisplayMode();
        if (mode === display.FoldDisplayMode.FOLD_DISPLAY_MODE_FULL) {
          this.isFoldFull = true;
        }
        display.on('foldDisplayModeChange', this.callback);
      }
    } catch (exception) {
      hilog.error(0x0000, TAG, 'Failed to register callback. Code: ' + JSON.stringify(exception));
    }
  }

  aboutToDisappear(): void {
    if (canIUse('SystemCapability.Window.SessionManager')) {
      try {
        display.off('foldDisplayModeChange', this.callback);
      } catch (error) {
        hilog.error(0x0000, TAG, 'display off foldDisplayModeChange failed.');
      }
    }
    AppStorage.setOrCreate('currentTime', 0);
    AppStorage.setOrCreate('selectToneQuality', ToneQuality.SQ);
    AppStorage.setOrCreate('isCasting', false);
    AppStorage.setOrCreate('playMode', MusicPlayMode.ORDER);
    if (this.avPlayerController) {
      {
        this.avPlayerController.releasePlayer();
        this.avPlayerController = undefined;
      }
    }
    if (this.audioRendererController) {
      {
        this.audioRendererController.release();
        this.audioRendererController = undefined;
      }
    }
    if (this.audioCastController) {
      this.audioCastController.releaseAVCast();
      this.avSessionController!.stopCasting();
      this.audioCastController = undefined;
    }
    if (this.avSessionController) {
      this.avSessionController.unregisterSessionListener();
      try {
        this.avSessionController.AVSession?.destroy();
      } catch (error) {
        hilog.error(0x0000, TAG, `avSession destroy failed, the error is: ${JSON.stringify(error)}`);
      }
      this.avSessionController = undefined;
    }
  }

  async initAVSession() {
    try {
      await this.avSessionController?.initAVSession();
    } catch (error) {
      hilog.error(0x0000, TAG, 'initAVSession failed');
    }
  }

  getImageColor() {
    if (!this.context) {
      return;
    }
    this.context.resourceManager.getMediaContent(this.songList[this.selectIndex].label.id)
      .then((value: Uint8Array) => {
        let buffer = value.buffer as ArrayBuffer;
        image.createImageSource(buffer).createPixelMap().then((pixelMap) => {
          effectKit.createColorPicker(pixelMap, (error, colorPicker) => {
            if (error) {
              hilog.error(0x0000, 'musicCast', 'Failed to create color picker.');
            } else {
              let color = colorPicker.getLargestProportionColor();
              let colorArr = ColorConversion.dealColor(color.red, color.green, color.blue);
              this.imageColor = `rgba(${colorArr[0]}, ${colorArr[1]}, ${colorArr[2]}, 1)`;
            }
          })
          let headFilter = effectKit.createEffect(pixelMap);
          if (headFilter !== null) {
            headFilter.blur(15);
            headFilter.getEffectPixelMap().then((value) => {
              this.imageLabel = value;
            })
          }
        })
          .catch((error: BusinessError) => {
            hilog.error(0x0000, 'musicCast', `${error.code} + ${error.message}`)
          })
      })
      .catch((error: BusinessError) => {
        hilog.error(0x0000, 'musicCast', `${error.code} + ${error.message}`)
      })
  }

  build() {
    Stack() {
      Image(this.imageLabel)
        .size(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
          {
            width: '120%'
          } :
          {
            height: '120%'
          })
        .aspectRatio(1)
        .objectFit(ImageFit.Cover)
        .opacity(0.5)
      Row() {
        if (this.isFoldFull) {
          Column() {
            TopAreaComponent()
              .margin({
                bottom: $r('app.float.music_info_margin_top'),
                left: $r('app.float.top_margin_left')
              })
            GridRow({
              columns: { md: 8 },
              gutter: 24
            }) {
              GridCol({
                span: { md: 4 }
              }) {
                MusicInfoComponent()
              }
              .margin({
                left: $r('app.float.margin_small'),
                right: $r('app.float.margin_small')
              })

              GridCol({
                span: { md: 4 }
              }) {
                LyricsComponent({ isShowControl: this.isShowControlLg, isTablet: this.isTabletFalse })
              }
              .padding({
                left: $r('app.float.twenty_four')
              })
            }
            .layoutWeight(1)
            .margin({
              bottom: $r('app.float.fold_margin_bottom')
            })
          }
          .layoutWeight(1)
          .padding({
            left: $r('app.float.common_padding'),
            right: $r('app.float.common_padding')
          })
        } else if (this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG) {
          Column() {
            TopAreaComponent()
              .padding({
                left: $r('app.float.common_padding'),
                right: $r('app.float.common_padding')
              })
            GridRow({
              columns: { md: 8, lg: 12 },
              gutter: 24
            }) {
              GridCol({
                span: { md: 4, lg: 4 },
                offset: { lg: 1 }
              }) {
                Column() {
                  Image(this.songList[this.selectIndex].label)
                    .width('100%')
                    .aspectRatio(1)
                    .borderRadius($r('app.float.cover_radius'))
                  ControlAreaComponent()
                }
                .height('100%')
                .justifyContent(FlexAlign.SpaceBetween)
                .margin({
                  bottom: $r('app.float.common_margin')
                })
              }

              GridCol({
                span: { md: 4, lg: 6 },
                offset: { lg: 1 }
              }) {
                LyricsComponent({ isShowControl: this.isShowControlLg, isTablet: this.isTablet })
              }
            }
            .layoutWeight(1)
            .padding({
              left: $r('app.float.common_padding'),
              right: $r('app.float.common_padding'),
              top: $r('app.float.lg_music_top'),
              bottom: $r('app.float.lg_music_margin_bottom')
            })
          }
        } else {
          Stack({ alignContent: Alignment.TopStart }) {
            Swiper() {
              MusicInfoComponent()
                .margin({
                  top: $r('app.float.music_component_top'),
                  bottom: $r('app.float.music_component_bottom')
                })
                .padding({
                  left: $r('app.float.common_padding'),
                  right: $r('app.float.common_padding')
                })
              LyricsComponent({ isShowControl: this.isShowControl, isTablet: this.isTabletFalse })
                .margin({
                  top: $r('app.float.margin_lyric')
                })
                .padding({
                  left: $r('app.float.common_padding'),
                  right: $r('app.float.common_padding')
                })
            }
            .height('100%')
            .indicator(
              new DotIndicator()
                .top($r('app.float.options_padding'))
                .selectedColor($r('app.color.select_swiper'))
                .color($r('app.color.slider_track'))
            )
            .clip(false)
            .loop(false)
            .onChange((index: number) => {
              if (index === 1) {
                this.isShowControl = true;
                this.intervalID = setInterval(() => {
                  this.pageShowTime += 1;
                  if (this.pageShowTime > 5) {
                    this.isShowControl = false;
                    clearInterval(this.intervalID);
                  }
                }, 1000);
              } else {
                this.pageShowTime = 0;
                clearInterval(this.intervalID);
              }
            })

            TopAreaComponent()
              .padding({
                left: $r('app.float.common_padding'),
                right: $r('app.float.common_padding')
              })
          }
          .height('100%')
        }
      }
      .padding({
        bottom: this.bottomHeight,
        top: this.topHeight
      })
    }
    .height('100%')
    .width('100%')
    .backgroundColor(this.imageColor)
  }
}