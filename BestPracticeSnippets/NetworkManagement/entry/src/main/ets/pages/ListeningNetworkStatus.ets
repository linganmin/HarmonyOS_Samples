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

import { connection } from '@kit.NetworkKit';
import { promptAction } from '@kit.ArkUI';
// [Start import_netQuality]
import { BusinessError } from '@kit.BasicServicesKit';
import { netHandover, netQuality } from '@kit.NetworkBoostKit';
// [End import_netQuality]
// [Start import_wifi_manager]
import { wifiManager } from '@kit.ConnectivityKit';
// [End import_wifi_manager]
import { hilog } from '@kit.PerformanceAnalysisKit';

@Builder
export function ListeningNetworkStatusBuilder() {
  ListeningNetworkStatus()
}

@Component
export struct ListeningNetworkStatus {
  controller: VideoController = new VideoController();
  @State videoSrc: Resource = $rawfile('video.mp4'); // Replace it with the actual video loading URL.
  private netCon: connection.NetConnection | null = null;
  private networkPause: boolean = false; // Listen to the loading status
  private isLowQuality: boolean = false;

  aboutToAppear(): void {
    this.networkListen();
    this.netQualityListen();
    this.wifiChangeListen();
    this.sceneChangeListen();
    this.handoverChangeListen();
  }

  // [Start net_con_unregister]
  aboutToDisappear(): void {
    this.netCon?.unregister((error: BusinessError) => {
      if (error) {
        hilog.error(0x0000, 'Sample', 'unregister failed, callback: err->: %{public}s', JSON.stringify(error));
      }
    });
  }
  // [End net_con_unregister]

  // [Start function_network_listen]
  networkListen() {
    this.netCon = connection.createNetConnection();
    this.netCon.register((error: BusinessError) => {
      if (error) {
        hilog.error(0x0000, 'Sample', 'networkListen fail: %{public}s', JSON.stringify(error));
        return;
      }
    });

    this.netCon.on('netAvailable', (data: connection.NetHandle) => {
      hilog.info(0x0000, 'Sample', 'Succeeded to get netAvailable: %{public}s', JSON.stringify(data));
      if (connection.hasDefaultNetSync()) {
        if (this.networkPause) {
          // [Start video_start]
          this.controller?.start();
          // [End video_start]
          this.networkPause = false;
        }
      }
    });

    // Subscribe to network loss events
    this.netCon.on('netLost', (data: connection.NetHandle) => {
      if (connection.getAllNetsSync().length == 0) {
        // [Start video_pause]
        this.controller?.pause();
        // [End video_pause]
        this.networkPause = true;
      }
      hilog.info(0x0000, 'Sample', 'Succeeded to get netLost: %{public}s', JSON.stringify(data));
    });

    this.netCon.on('netCapabilitiesChange', (data: connection.NetCapabilityInfo) => {
      hilog.info(0x0000, 'Sample', 'Succeeded to get netCapabilitiesChange: %{public}s', JSON.stringify(data));
    });

    this.netCon.on('netUnavailable', () => {
      hilog.info(0x0000, 'Sample', 'Succeeded to get unavailable net event');
    });
  }
  // [End function_network_listen]

  judgeHasNet(): boolean {
    try {
      let netHandle = connection.getDefaultNetSync();
      if (!netHandle || netHandle.netId === 0) {
        return false;
      }
      let netCapability = connection.getNetCapabilitiesSync(netHandle);
      let cap = netCapability.networkCap || [];
      if (cap.includes(connection.NetCap.NET_CAPABILITY_VALIDATED)) {
        // connection.NetCap.NET_CAPABILITY_VALIDATED，The value indicates that the network is normal and HTTP and HTTPS requests can be initiated.
        // The network information changes and the network is available.
        return true;
      } else {
        // The network information changes and the network is unavailable.
        return false;
      }
    } catch (e) {
      let err = e as BusinessError;
      hilog.error(0x0000, 'Sample', 'errCode: %{public}s, errMessage: %{public}s', (err as BusinessError).code,
        (err as BusinessError).message);
    }
    return false;
  }

  // [Start toggle_low_definition]
  toggleLowDefinition() {
    this.videoSrc = $rawfile('lowQuality.mp4');
  }
  // [End toggle_low_definition]

  // [Start net_quality_listen]
  netQualityListen() {
    try {
      netQuality.on('netQosChange', (list: Array<netQuality.NetworkQos>) => {
        if (list.length > 0) {
          list.forEach((qos) => {
            // Callback information processing
            hilog.info(0x0000, 'Sample', 'Succeeded receive netQosChange info: %{public}s', JSON.stringify(qos));
            let lowNetQuality: boolean = false;
            // Determine the current network quality based on the network quality information. The logic needs to be customized. If the quality is low, set lowNetQuality to true.
            // If the network quality is low, switch the video definition.
            if (lowNetQuality) {
              this.toggleLowDefinition();
            }
          });
        }
      });
    } catch (err) {
      hilog.error(0x0000, 'Sample', 'errCode: %{public}s, errMessage: %{public}s', (err as BusinessError).code,
        (err as BusinessError).message);
    }
  }
  // [End net_quality_listen]

  // [Start wifi_change_listen]
  wifiChangeListen() {
    this.netCon = connection.createNetConnection({
      netCapabilities: {
        bearerTypes: [connection.NetBearType.BEARER_WIFI]
      }
    });
    // Use the register interface to register a subscription event.
    this.netCon.register((error: BusinessError) => {
      if (error) {
        hilog.error(0x0000, 'Sample', 'networkListen fail: %{public}s', JSON.stringify(error));
        return;
      }
    });

    // Subscribe to network availability events. This event notification can be received only after register is called.
    this.netCon.on('netAvailable', (data: connection.NetHandle) => {
      hilog.info(0x0000, 'Sample', 'WifiChangeListen-- Succeeded to get data: %{public}s', JSON.stringify(data));
    });

    // Subscribe to network loss events. This event notification can be received only after register is called.
    this.netCon.on('netLost', (data: connection.NetHandle) => {
      hilog.info(0x0000, 'Sample', 'WifiChangeListen-- Succeeded to get data: %{public}s', JSON.stringify(data));
    });

    let recvPowerNotifyFunc = (result: number) => {
      hilog.info(0x0000, 'Sample', 'WifiChangeListen-- Receive power state change event: %{public}d', result);
    }
    let recvWifiConnectionChangeFunc = (result: number) => {
      hilog.info(0x0000, 'Sample', 'WifiChangeListen-- Receive wifi connection change event: %{public}d', result);
    }

    // Registering Events
    wifiManager.on('wifiStateChange', recvPowerNotifyFunc);
    wifiManager.on('wifiConnectionChange', recvWifiConnectionChangeFunc);
  }
  // [End wifi_change_listen]

  // [Start scene_change_listen]
  sceneChangeListen() {
    try {
      netQuality.on('netSceneChange', (list: Array<netQuality.NetworkScene>) => {
        if (list.length > 0) {
          list.forEach((networkScene) => {
            // Callback information processing
            hilog.info(0x0000, 'Sample', 'Succeeded receive netSceneChange info');
            // [Start weak_signal_congestion]
            if (networkScene.scene === 'weakSignal' || networkScene.scene === 'congestion') {
              // Indicates the weak network scenario.
              hilog.info(0x0000, 'Sample', 'The current network is weak');
              this.networkWeak();
            }
            // [End weak_signal_congestion]
            // [Start weak_signal_prediction]
            if (networkScene.weakSignalPrediction) {
              // Weak signal prediction processing
            }
            // [End weak_signal_prediction]
          });
        }
      });
    } catch (err) {
      hilog.error(0x0000, 'Sample', 'errCode: %{public}s, errMessage: %{public}s', (err as BusinessError).code,
        (err as BusinessError).message);
    }
  }
  // [End scene_change_listen]

  // [Start network_weak]
  networkWeak() {
    this.getUIContext().getPromptAction().showToast({
      message: $r('app.string.weak_network_environment_message'),
      duration: 2000
    });
  }
  // [End network_weak]

  // [Start handover_change_listen]
  handoverChangeListen() {
    try {
      netHandover.on('handoverChange', (info: netHandover.HandoverInfo) => {
        if (info.handoverStart) {
          // Connection migration start callback. The application adjusts the data transmission policy based on the suggestions of HandoverStart.
          hilog.info(0x0000, 'Sample', 'handover start');
        } else if (info.handoverComplete) {
          // Callback after the connection migration is complete. The application performs rate adjustment and reestablishment according to the suggestions in HandoverComplete.
          hilog.info(0x0000, 'Sample', 'handover complete');
        }
      });
    } catch (err) {
      hilog.error(0x0000, 'Sample', 'errCode: %{public}s, errMessage: %{public}s', (err as BusinessError).code,
        (err as BusinessError).message);
    }
  }
  // [End handover_change_listen]

  @Builder
  NavDestinationTitle() {
    Column() {
      Text($r('app.string.network_status_listening'))
        .fontSize(20)
        .lineHeight(40)
        .fontWeight(700)
        .width('100%')
        .padding({ left: 12 })
    }
    .width('100%')
  }
  build() {
    NavDestination() {
      Video({
        src: this.videoSrc,
        controller: this.controller
      })
        .objectFit(ImageFit.Cover)
        .onStart(() => {
          let judgeHasNet = this.judgeHasNet();
          if (!judgeHasNet) {
            this.controller?.reset();
            this.getUIContext().getPromptAction().showToast({
              message: $r('app.string.network_unavailable_message'),
              duration: 2000
            });
          }
        })
        .height('50%')

      Column() {
        Button($r('app.string.simulate_network_unavailable')).onClick(() => {
          this.controller.pause();
          this.getUIContext().getPromptAction().showToast({
            message: $r('app.string.network_unavailable_message'),
            duration: 2000
          });
        })
          .margin({ bottom: 12 })
          .width('100%')
          .backgroundColor('#0A59F7')
        Button($r('app.string.simulate_network_lost')).onClick(() => {
          this.controller.pause();
          this.getUIContext().getPromptAction().showToast({
            message: $r('app.string.simulate_network_disconnected_message'),
            duration: 2000
          });
        })
          .margin({ bottom: 12 })
          .width('100%')
          .backgroundColor('#0A59F7')
        Button($r('app.string.simulate_weak_network_environment')).onClick(() => {
          this.controller.pause();
          this.getUIContext().getPromptAction().showToast({
            message: $r('app.string.weak_network_toggle_video'),
            duration: 2000
          });
        })
          .margin({ bottom: 12 })
          .width('100%')
          .backgroundColor('#0A59F7')
        Button($r('app.string.Simulate_low_quality_network_environment')).onClick(() => {
          this.controller.pause();
          this.getUIContext().getPromptAction().showToast({
            message: $r('app.string.low_quality_network_environment_message'),
            duration: 2000
          });
        })
          .margin({ bottom: 12 })
          .width('100%')
          .backgroundColor('#0A59F7')
        Button($r('app.string.toggle_video_to_low_definition')).onClick(() => {
          if (!this.isLowQuality) {
            this.toggleLowDefinition();
            this.isLowQuality = true;
            this.getUIContext().getPromptAction().showToast({
              message: $r('app.string.toggle_low_definition_message'),
              duration: 2000
            });
            this.controller?.reset();
          } else {
            this.getUIContext().getPromptAction().showToast({
              message: $r('app.string.toggle_definition_message_fail'),
              duration: 2000
            });
          }
        })
          .width('100%')
          .margin({ bottom: 12 })
          .backgroundColor('#0A59F7')
        Button($r('app.string.toggle_video_to_high_definition')).onClick(() => {
          this.videoSrc = $rawfile('video.mp4');
          this.isLowQuality = false;
          this.controller?.reset();
          this.getUIContext().getPromptAction().showToast({
            message: $r('app.string.toggle_high_definition_message'),
            duration: 2000
          });
        })
          .width('100%')
          .backgroundColor('#0A59F7')
      }
      .justifyContent(FlexAlign.End)
      .height(346)
      .padding({ left: 16, right: 16, bottom: 24 })
      .margin({ bottom: 16 })
    }
    .title(this.NavDestinationTitle())
  }
}
// [Start video_player]
@Component
export struct VideoPlayer{
  private controller:VideoController | undefined;
  @State videoSrc: string= 'https://www.example.com/example.mp4' //Please replace it with the actual video loading URL when using it.
  build(){
    Column() {
      Video({
        src: this.videoSrc,
        controller: this.controller
      })
    }
  }
}
// [End video_player]