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
// [Start import_connection]
import { connection } from '@kit.NetworkKit';
// [End import_connection]
// [Start scene_change_step]
import { netQuality } from '@kit.NetworkBoostKit';
// [End scene_change_step]
import { PromptAction } from '@kit.ArkUI';
import { Logger } from '../common/Logger';
import { formatVideoTime } from '../common/TimeUtil';
import { showToast } from '../common/ToastUtil';
import { NetworkUtil } from '../common/NetworkUtil';

const TAG = 'NetworkMonitorTag';

@Component
export struct NetworkMonitor {
  private videoUrl: string =
    'https://consumer.huawei.com/content/dam/huawei-cbg-site/cn/mkt/pdp/phones/pura-x/video/kv-popup.mp4';
  private uiContext: UIContext = this.getUIContext();
  private promptAction: PromptAction = this.uiContext.getPromptAction();
  private videoRatio: number = 16 / 9; // default video width/height ratio value
  private netCon: connection.NetConnection | null = null;
  private controller: VideoController = new VideoController();
  private lastTime: number = 0;
  @State currentTime: number = 0;
  @State durationTime: number = 0
  @State isPlaying: boolean = false;
  @State isCellular: boolean = false;
  @State networkType: number = connection.NetBearType.BEARER_WIFI;
  @State isNetAvailable: boolean = false;
  @State isShowController: boolean = false;
  @State isPlayError: boolean = false;
  @State isShowGoOn: boolean = false;

  aboutToAppear(): void {
    this.onNetworkChange();
    this.onNetSceneChange();
  }

  // [Start scene_change_step]
  onNetSceneChange() {
    // Subscribe to network scene information
    try {
      netQuality.on('netSceneChange', (list: netQuality.NetworkScene[]) => {
        Logger.info(TAG, `on netSceneChange, Succeeded receive netSceneChange info: ${list.length}`);
        if (list.length > 0) {
          list.forEach((networkScene) => {
            if (networkScene.scene === 'weakSignal' || networkScene.scene === 'congestion') {
              this.promptAction.showToast({ message: $r('app.string.network_bad_tips') });
            }
          });
        }
      });
    } catch (err) {
      Logger.error(TAG, `on netSceneChange err: ${JSON.stringify(err)}`);
    }
  }
  // [End scene_change_step]

  onNetworkChange() {
    // [Start network_available_step]
    // Create a NetConnection object
    this.netCon = connection.createNetConnection();
    // Subscribe to a network available event that triggers when the network is available
    this.netCon.on('netAvailable', (data: connection.NetHandle) => {
      Logger.info(TAG, `on netAvailable, Succeeded to get netAvailable: ${JSON.stringify(data)}`);
      this.isNetAvailable = NetworkUtil.isNetworkAvailable();
      this.isCellular = NetworkUtil.isCellular();
      if (this.isNetAvailable && this.isPlayError && !this.isCellular) {
        this.controller.reset();
      }
    });
    // [End network_available_step]

    // [Start network_unavailable_step]
    // Subscribe to a network unavailability event that triggers when the network is unavailable
    this.netCon.on('netUnavailable', () => {
      Logger.info(TAG, 'on netUnavailable, Succeeded to get unavailable net event');
      this.isNetAvailable = false;
      showToast(this.uiContext, $r('app.string.result_network_unavailable'));
    });
    // [End network_unavailable_step]

    // [Start network_abilities_change_step]
    // Subscribe to network capability change events that trigger when network capability changes,
    // such as from no network to network with network, or when switching from WIFI to cellular
    this.netCon.on('netCapabilitiesChange', (data: connection.NetCapabilityInfo) => {
      Logger.info(TAG, `on netCapabilitiesChange, Succeeded to get netCapabilitiesChange: ${JSON.stringify(data)}`);
      if (data.netCap.bearerTypes.includes(connection.NetBearType.BEARER_CELLULAR)) {
        // For cellular networks, pause playback
        this.isCellular = true;
        this.isShowController = false;
        this.controller.pause();
        showToast(this.getUIContext(), $r('app.string.current_cellular_tips'))
        this.isShowGoOn = true;
      } else {
        this.isCellular = false;
        this.isShowController = true;
        this.controller.start();
        this.isShowGoOn = false;
      }
    });
    // [End network_abilities_change_step]

    // [Start network_lost_step]
    // Subscribe to a network loss event, triggered when the network is severely interrupted or normally disconnected,
    // and the network interruption pauses playback
    this.netCon.on('netLost', (data: connection.NetHandle) => {
      Logger.info(TAG, `on netLost, Succeeded to get netLost: ${JSON.stringify(data)}`);
      this.isNetAvailable = false;
      this.isCellular = false;
      showToast(this.uiContext, $r('app.string.network_disconnect_tips'));
    });
    // [End network_lost_step]

    // [Start register_network_change_step]
    this.netCon.register((error: BusinessError) => {
      if (error) {
        Logger.error(TAG, `networkListen fail: ${JSON.stringify(error)}`);
      }
    });
    // [End register_network_change_step]
  }

  // [Start unsubscribe_step]

  aboutToDisappear(): void {
    // Unsubscribe from network status changes
    this.netCon?.unregister((err: BusinessError) => {
      if (err) {
        Logger.error(TAG, `unregister failed, err: ${JSON.stringify(err)}`);
      }
    });
    // Unsubscribe from network scenario information
    try {
      netQuality.off('netSceneChange');
    } catch (err) {
      Logger.error(TAG, `off netSceneChange err: ${JSON.stringify(err)}`);
    }
  }
  // [End unsubscribe_step]

  build() {
    NavDestination() {
      Stack() {
        // [Start play_error]
        Video({ src: this.videoUrl, controller: this.controller })
        // [StartExclude play_error]
          .width('100%')
          .aspectRatio(this.videoRatio)
          .objectFit(ImageFit.Contain)
          .loop(true)
          .controls(false)
          .onUpdate((info) => {
            this.currentTime = info.time;
          })
          .onPause(() => {
            this.isPlaying = false;
          })
          .onStart(() => {
            this.isPlaying = true;
          })
          .onPrepared((event) => {
            Logger.info(TAG, 'Video onPrepared');
            this.durationTime = event.duration;
            if (this.isPlayError) {
              this.controller.setCurrentTime(this.lastTime, SeekMode.Accurate);
              this.isPlayError = false;
              return;
            }
            if (!this.isCellular) {
              this.controller.start();
            }
          })
          // [EndExclude play_error]
          .onError(() => {
            Logger.error(TAG, 'Video onError');
            this.lastTime = this.currentTime;
            this.isShowController = false;
            this.isPlayError = true;
            this.isPlaying = false;
            this.isNetAvailable = NetworkUtil.isNetworkAvailable();
          })
        // [End play_error]

        if (this.isShowController) {
          Row() {
            SymbolGlyph(this.isPlaying ? $r('sys.symbol.pause_fill') : $r('sys.symbol.play_fill'))
              .fontSize(24)
              .fontColor([$r('sys.color.font_on_primary')])
              .margin({ right: 4 })
              .onClick(() => {
                if (this.isPlaying) {
                  this.controller.pause();
                } else {
                  this.controller.start();
                }
              })
            Text(formatVideoTime(this.currentTime))
              .fontSize(12)
              .fontColor($r('sys.color.font_on_primary'))
            Slider({
              value: this.currentTime,
              step: 1,
              min: 0,
              max: this.durationTime
            })
              .layoutWeight(1)
              .margin({
                left: 12,
                right: 12
              })
              .onChange((value: number, mode: SliderChangeMode) => {
                // Set the video playback progress to jump to the value
                this.currentTime = value;
                if (mode === SliderChangeMode.End) {
                  this.controller.setCurrentTime(value);
                  this.controller.start();
                }
              })
            Text(formatVideoTime(this.durationTime))
              .fontSize(12)
              .fontColor($r('sys.color.font_on_primary'))
          }
          .position({ bottom: 0 })
          .padding({
            left: 16,
            right: 16
          })
        }

        // Displays alerts when the cellular network is on
        if (this.isCellular && this.isNetAvailable && this.isShowGoOn) {
          Column({ space: 10 }) {
            Text($r('app.string.current_cellular_tips'))
              .fontColor($r('sys.color.font_on_primary'))
              .fontSize(12)

            Button($r('app.string.go_on_play'))
              .fontSize(12)
              .height(30)
              .onClick(() => {
                this.isShowController = true;
                this.controller.start();
              })
          }
        } else if (this.isPlayError || (!this.isPlaying && !this.isNetAvailable)) {
          // Alerts when the network is unavailable
          Text($r('app.string.no_network_tips'))
            .fontColor($r('sys.color.font_on_primary'))
            .fontSize(12)
        }
      }
      .alignContent(Alignment.Center)
    }
    .title($r('app.string.title_network_aware'))
  }
}