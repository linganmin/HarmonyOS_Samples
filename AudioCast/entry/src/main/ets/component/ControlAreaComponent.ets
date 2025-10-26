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

import { Prompt } from '@kit.ArkUI';
import { avSession } from '@kit.AVSessionKit';
import { audio } from '@kit.AudioKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BreakpointConstants } from '../common/constants/BreakpointConstants';
import { BreakpointType } from '../common/utils/BreakpointSystem';
import { ResourceConversion } from '../common/utils/ResourceConversion';
import { SongItem, MusicPlayMode, ToneQuality } from '../model/SongData';
import { AVSessionController } from '../controller/AVSessionController';
import { AudioPlayerController } from '../controller/AudioPlayerController';
import { AudioRendererController } from '../controller/AudioRendererController';
import { AudioCastController } from '../controller/AudioCastController';
import { MediaTools } from '../common/utils/MediaTools';
import ToneQualityList from './ToneQualityList';

const PlayModeSwitchList = [MusicPlayMode.ORDER, MusicPlayMode.RANDOM, MusicPlayMode.SINGLE_CYCLE];
const TAG = 'ControlAreaComponent';

@Component
export struct ControlAreaComponent {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_SM;
  @StorageLink('isPlay') isPlay: boolean = false;
  @StorageLink('currentTime') currentTime: number = 0;
  @StorageLink('durationTime') durationTime: number = 0;
  @StorageLink('songList') songList: SongItem[] = [];
  @StorageLink('playMode') playMode: MusicPlayMode = MusicPlayMode.ORDER;
  @StorageLink('selectIndex') selectIndex: number = 0;
  @StorageLink('selectToneQuality') @Watch('switchQuality') selectToneQuality: number = ToneQuality.SQ;
  @StorageLink('avSessionController') avSessionController ?: AVSessionController = undefined;
  @StorageLink('avPlayerController') @Watch('avPlayerStateChange') avPlayerController?: AudioPlayerController =
    undefined;
  @StorageLink('audioRendererController') @Watch('audioRendererStateChange') audioRendererController?: AudioRendererController =
    undefined;
  @StorageLink('audioCastController') @Watch('audioCastControllerStateChange') audioCastController?: AudioCastController =
    undefined;
  @StorageLink('isAvPlayerPlay') isAvPlayerPlay: boolean = true;
  @StorageLink('volumeValue') volumeValue: number = 0;
  @State isShowToneQualityList: boolean = false;
  @State playModeIndex: number = 0;
  @State isCasting: boolean = false;
  @State isPcm: boolean = false;
  @State deviceInfo?: avSession.DeviceInfo = undefined;
  private resourceConversion: ResourceConversion = new ResourceConversion();

  aboutToAppear(): void {
    if (!this.avPlayerController && !this.audioRendererController) {
      this.initAVPlayer();
    }
  }

  async initAVPlayer() {
    try {
      await AudioPlayerController.create(MediaTools.getSrcFromPlayMode(this.songList[this.selectIndex].src));
    } catch (error) {
      hilog.error(0x0000, TAG, `create avPlayer failed, code is ${error.code}, message is ${error.message}.`);
    }
  }

  async initAudioRenderer() {
    this.audioRendererController = AudioRendererController.getInstance();
    await this.audioRendererController.initAudioRenderer();
  }

  async initAVSession() {
    this.avSessionController = AVSessionController.getInstance();
    await this.configSession();
  }

  /**
   * Initializes AV casting device picker and handles device connection changes.
   * Manages remote/local device connections and playback transitions.
   * @param videoSession: The AV session to configure for casting.
   */
  async initAVCastPicker() {
    try {
      // [Start onOutputDeviceChange]
      this.avSessionController?.AVSession?.on('outputDeviceChange', async (connectState: avSession.ConnectionState,
        device: avSession.OutputDeviceInfo) => {
        let currentDevice: avSession.DeviceInfo = device?.devices?.[0];
        this.deviceInfo = currentDevice;
        if (currentDevice.castCategory === avSession.AVCastCategory.CATEGORY_REMOTE &&
          connectState === avSession.ConnectionState.STATE_CONNECTED) {
          // [StartExclude onOutputDeviceChange]
          if (!this.isAvPlayerPlay) {
            if (currentDevice.supportedProtocols === avSession.ProtocolType.TYPE_CAST_PLUS_AUDIO) {
              this.isPcm = true;
            } else {
              Prompt.showToast({
                message: this.resourceConversion.getStringValueFromResource($r('app.string.reason_switch_quality'))
              });
              this.isAvPlayerPlay = true;
              this.selectToneQuality = ToneQuality.SQ;
            }
          }
          // [EndExclude onOutputDeviceChange]
          this.isCasting = true;
          this.startCast(this.currentTime, this.selectIndex);
        }
        // [StartExclude onOutputDeviceChange]
        else if (currentDevice.castCategory === avSession.AVCastCategory.CATEGORY_REMOTE &&
          connectState === avSession.ConnectionState.STATE_DISCONNECTED) {
          this.releaseAvCastController();
        }
        else if (currentDevice.castCategory === avSession.AVCastCategory.CATEGORY_LOCAL) {
          this.playMusic(this.selectIndex, this.currentTime);
          this.releaseAvCastController();
        }
        // [EndExclude onOutputDeviceChange]
      })
      // [End onOutputDeviceChange]
    } catch (error) {
      hilog.error(0x0000, TAG, `avSession on event failed, the error is: ${JSON.stringify(error)}`);
    }
  }

  async avPlayerStateChange() {
    if (this.avPlayerController) {
      this.currentTime =
        this.currentTime > this.avPlayerController.currentTime ? this.currentTime : this.avPlayerController.currentTime;
      this.durationTime = this.avPlayerController.durationTime;
      this.volumeValue = this.avPlayerController.volume;
      this.isPlay = this.avPlayerController.state === 'playing';
      if (this.avPlayerController.state === 'prepared') {
        if (!this.avSessionController) {
          await this.initAVSession();
        } else {
          await this.configSession();
        }
        this.avSessionController?.initAvSessionPlayState(this.avPlayerController);
        this.avPlayerController?.onStateChange(async (newState: string) => {
          this.avSessionController?.setAvSessionState(newState === 'playing');
        });
        this.avPlayerController?.onPositionChange(async (newPosition: number) => {
          this.avSessionController?.setAvSessionPosition(newPosition);
        });
        this.avPlayerController?.seek(this.currentTime);
        this.avPlayerController.setPlaying();
      }
      if (this.avPlayerController.state === 'completed') {
        this.playNextOrPrevious('next');
      }
    }
  }

  async audioRendererStateChange() {
    if (this.audioRendererController) {
      if (!this.avSessionController || !this.audioRendererController) {
        return;
      }
      this.isPlay = this.audioRendererController?.state === audio.AudioState.STATE_RUNNING;
      if (this.audioRendererController?.state === audio.AudioState.STATE_PREPARED) {
        if (!this.avSessionController) {
          await this.initAVSession();
        } else {
          await this.configSession();
        }
        await this.audioRendererController?.setAvSessionCallback();
        this.audioRendererController?.setAudioRendererCallbacks();
        this.audioRendererController.seek(this.currentTime);
        this.audioRendererController.play(this.selectIndex);
      }
    }
  }

  async audioCastControllerStateChange() {
    if (this.audioCastController) {
      this.currentTime = this.audioCastController.elapsedTime;
      this.volumeValue = this.audioCastController.volume;
      this.isPlay = this.audioCastController.state === avSession.PlaybackState.PLAYBACK_STATE_PLAY;
      if (this.audioCastController.state === avSession.PlaybackState.PLAYBACK_STATE_PREPARE) {
        if (this.isAvPlayerPlay) {
          this.avPlayerController?.setPause();
        } else {
          this.audioRendererController?.setPause();
        }
        if (!this.avSessionController) {
          this.avSessionController = AVSessionController.getInstance();
        }
        await this.configSession();
        try {
          this.audioCastController?.avCastController?.on('endOfStream', () => {
            this.playNextOrPrevious('next');
          });
        } catch (error) {
          hilog.error(0x0000, TAG, `avCastController on event failed, the error is: ${JSON.stringify(error)}`);
        }
        this.audioCastController.setPlayModel(this.playMode);
      }
    }
  }

  async startCast(startPosition: number, selectIndex: number) {
    if (!this.audioCastController) {
      try {
        let session = await this.avSessionController?.AVSession?.getAVCastController();
        this.audioCastController = new AudioCastController(session);
        this.selectIndex = selectIndex;
        await this.audioCastController.initAVCast(this.songList, selectIndex, startPosition);
        // [Start AvCastControllerPlayControl]
        this.audioCastController.avCastController?.on('playNext', () => {
          this.playNextOrPrevious('next');
        });
        this.audioCastController.avCastController?.on('playPrevious', () => {
          this.playNextOrPrevious('previous');
        });
        // [End AvCastControllerPlayControl]
      } catch (error) {
        hilog.error(0x0000, TAG, `avCastController on event failed, the error is: ${JSON.stringify(error)}`);
      }
    }
  }

  /**
   * Configures AV session with player controller.
   * Sets up metadata, playback state, and event listeners.
   * Handles playNext/playPrevious commands and state synchronization.
   */
  async configSession() {
    let controller = this.isCasting ? this.audioCastController :
      this.isAvPlayerPlay ? this.avPlayerController : this.audioRendererController;
    if (!this.avSessionController || !controller) {
      return;
    }
    await this.avSessionController.setAVMetadata(this.isAvPlayerPlay);
    this.avSessionController.setAvSessionListener(controller);
    try {
      // [Start AvSessionPlayControl]
      this.avSessionController.AVSession?.on('playNext', () => {
        this.playNextOrPrevious('next');
      });
      this.avSessionController.AVSession?.on('playPrevious', () => {
        this.playNextOrPrevious('previous');
      });
      // [End AvSessionPlayControl]
      this.avSessionController.AVSession?.on('setLoopMode', () => {
        this.switchPlayMode();
      });
    } catch (error) {
      hilog.error(0x0000, TAG, `avSession on event failed, the error is: ${JSON.stringify(error)}`);
    }
    this.initAVCastPicker();
  }

  async playMusic(index: number, currentTime: number) {
    this.currentTime = currentTime;
    this.selectIndex = index;
    AppStorage.setOrCreate('currentTime', currentTime);
    AppStorage.setOrCreate('selectIndex', index);
    if (this.isAvPlayerPlay) {
      await this.releaseAVPlayer();
      await this.initAVPlayer();
    } else {
      await this.releaseAudioRenderer();
      await this.initAudioRenderer();
    }
  }

  playNextOrPrevious(playType: string) {
    let playIndex = MediaTools.getMusicIndexByMusicMode(playType, this.playMode, this.selectIndex);
    if (this.isCasting) {
      this.startCast(0, playIndex);
    } else {
      this.playMusic(playIndex, 0);
    }
  }

  switchPlayMode() {
    this.playModeIndex = this.playModeIndex === PlayModeSwitchList.length - 1 ? 0 : this.playModeIndex + 1;
    this.playMode = PlayModeSwitchList[this.playModeIndex];
    Prompt.showToast({ message: MediaTools.getToastMessageByMusicMode(this.playMode) });
    if (this.isCasting) {
      this.audioCastController?.setPlayModel(this.playMode);
    }
    this.avSessionController?.setLoopModeState(this.playMode);
  }

  async switchQuality() {
    if (this.isCasting) {
      if (this.selectToneQuality === ToneQuality.MASTER) {
        if (this.deviceInfo?.supportedProtocols === avSession.ProtocolType.TYPE_CAST_PLUS_AUDIO) {
          this.isPcm = true;
          this.isAvPlayerPlay = false;
          this.startCast(this.currentTime, this.selectIndex);
        } else {
          this.selectToneQuality = ToneQuality.SQ;
          this.isAvPlayerPlay = true;
          Prompt.showToast({
            message: this.resourceConversion.getStringValueFromResource($r('app.string.reason_switch_quality'))
          });
        }
      }
      return;
    }
    if (this.selectToneQuality === ToneQuality.MASTER) {
      if (this.songList[this.selectIndex].pcmSrc) {
        this.isAvPlayerPlay = false;
        await this.releaseAVPlayer();
        await this.initAudioRenderer();
      }
    } else {
      this.isAvPlayerPlay = true;
      await this.releaseAVPlayer();
      await this.releaseAudioRenderer();
      await this.initAVPlayer();
    }
  }

  switchPlayOrPause() {
    if (this.isCasting) {
      if (this.isPlay) {
        this.audioCastController?.setPause();
      } else {
        this.audioCastController?.setPlaying();
      }
    } else {
      if (this.isAvPlayerPlay) {
        if (this.isPlay) {
          this.avPlayerController?.setPause();
        } else {
          this.avPlayerController?.setPlaying();
          this.avPlayerController?.seek(this.currentTime);
        }
      } else {
        if (this.isPlay) {
          this.audioRendererController?.setPause();
        } else {
          this.audioRendererController?.setPlaying();
          this.audioRendererController?.seek(this.currentTime);
        }
      }
    }
  }

  sliderValueChange(value: number) {
    this.currentTime = value;
    if (this.isCasting) {
      this.audioCastController?.seek(value);
    } else {
      if (this.isAvPlayerPlay) {
        this.avPlayerController?.seek(value);
      } else {
        this.audioRendererController?.seek(value);
      }
    }
  }

  async releaseAVPlayer() {
    if (this.avPlayerController) {
      try {
        await this.avPlayerController.releasePlayer();
      } catch (error) {
        hilog.error(0x0000, TAG, 'releaseAVPlayer failed');
      }
      this.avPlayerController = undefined;
    }
  }

  async releaseAudioRenderer() {
    if (this.audioRendererController) {
      await this.audioRendererController.release();
      this.audioRendererController = undefined;
    }
  }

  async releaseAvCastController() {
    if (this.audioCastController) {
      await this.audioCastController?.releaseAVCast();
      await this.avSessionController!.stopCasting();
      this.audioCastController = undefined;
      this.isCasting = false;
    }
  }

  build() {
    Column() {
      Column() {
        Slider({
          min: 0,
          max: this.durationTime,
          step: 1,
          style: SliderStyle.OutSet,
          value: this.currentTime
        })
          .selectedColor($r('app.color.slider_select'))
          .trackColor($r('app.color.slider_track'))
          .onChange((value: number, mode: SliderChangeMode) => {
            if (this.durationTime < this.currentTime) {
              return;
            }
            if (mode === SliderChangeMode.End || mode === SliderChangeMode.Begin) {
              this.sliderValueChange(value);
            }
          })
          .height($r('app.float.slider_height'))
          .margin({
            left: new BreakpointType({
              sm: $r('app.float.slider_margin_sm'),
              md: $r('app.float.slider_margin_md'),
              lg: $r('app.float.slider_margin_lg')
            }).getValue(this.currentBreakpoint),
            right: new BreakpointType({
              sm: $r('app.float.slider_margin_sm'),
              md: $r('app.float.slider_margin_md'),
              lg: $r('app.float.slider_margin_lg')
            }).getValue(this.currentBreakpoint)
          })
          .hitTestBehavior(HitTestMode.Block)
        Row() {
          Text(MediaTools.msToCountdownTime(this.currentTime))
            .fontColor($r('app.color.play_text_color'))
            .fontSize($r('app.float.singer_title_sm'))
            .fontFamily('HarmonyHeiTi')
            .lineHeight('14vp')
          Text(MediaTools.fetchToneQualityTitle(this.selectToneQuality))
            .fontSize($r('app.float.singer_title_sm'))
            .fontColor('#ffd4c8c8')
            .onClick(() => {
              this.isShowToneQualityList = true;
            })
            .bindSheet($$this.isShowToneQualityList, this.toneQualityListBuilder(), {
              detents: [SheetSize.MEDIUM],
              dragBar: false,
              showClose: false,
              preferType: SheetType.CENTER
            })
          Text(MediaTools.msToCountdownTime(this.durationTime))
            .fontColor($r('app.color.play_text_color'))
            .fontSize($r('app.float.singer_title_sm'))
            .fontFamily('HarmonyHeiTi')
            .lineHeight('14vp')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: $r('app.float.slider_text_margin') })
      }
      .margin({
        top: $r('app.float.slider_margin_top'),
        bottom: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? $r('app.float.slider_margin_bottom_lg') :
        $r('app.float.slider_margin_bottom')
      })

      Row() {
        Image(this.playMode === MusicPlayMode.ORDER ? $r('app.media.order_play') :
          this.playMode === MusicPlayMode.RANDOM ? $r('app.media.shuffle') : $r('app.media.repeat_1'))
          .fillColor(Color.White)
          .controlImageBuilder()
          .width(new BreakpointType({
            sm: $r('app.float.twenty_four'),
            md: $r('app.float.twenty_four'),
            lg: $r('app.float.control_image_lg')
          }).getValue(this.currentBreakpoint))
          .onClick(() => {
            this.switchPlayMode();
          })
        // [Start PlayNextOrPrevious]
        Image($r('app.media.ic_public_previous'))
          // [StartExclude PlayNextOrPrevious]
          .controlImageBuilder()
          .width(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ?
          $r('app.float.control_width_lg') : $r('app.float.control_width'))
          // [EndExclude PlayNextOrPrevious]
          .onClick(() => {
            this.playNextOrPrevious('previous');
          })
        // [StartExclude PlayNextOrPrevious]
        Image(this.isPlay ? $r('app.media.ic_public_play') : $r('app.media.ic_public_pause'))
          .controlImageBuilder()
          .width(new BreakpointType({
            sm: $r('app.float.image_play_width'),
            md: $r('app.float.image_play_width'),
            lg: $r('app.float.image_play_width_lg')
          }).getValue(this.currentBreakpoint))
          .onClick(() => {
            this.switchPlayOrPause();
          })
        // [EndExclude PlayNextOrPrevious]
        Image($r('app.media.ic_public_next'))
          // [StartExclude PlayNextOrPrevious]
          .controlImageBuilder()
          .width(this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? $r('app.float.control_width_lg') :
          $r('app.float.control_width'))
          // [EndExclude PlayNextOrPrevious]
          .onClick(() => {
            this.playNextOrPrevious('next');
          })
        // [End PlayNextOrPrevious]
        Image($r('app.media.ic_music_list'))
          .fillColor(Color.White)
          .controlImageBuilder()
          .width(new BreakpointType({
            sm: $r('app.float.twenty_four'),
            md: $r('app.float.twenty_four'),
            lg: $r('app.float.control_image_lg')
          }).getValue(this.currentBreakpoint))
      }
      .margin({
        bottom: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_LG ? $r('app.float.slider_margin_bottom_lg') :
        $r('app.float.slider_margin_bottom')
      })
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
  }

  @Builder
  toneQualityListBuilder() {
    Column() {
      ToneQualityList({ isShowToneQualityList: this.isShowToneQualityList })
    }
  }
}

@Extend(Image)
function controlImageBuilder() {
  .aspectRatio(1)
  .opacity(0.86)
  .objectFit(ImageFit.Contain)
}