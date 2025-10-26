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

import { wearEngine } from '@kit.WearEngine';
import { BusinessError, Callback } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { promptAction } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'ConnectUtil';

// Peer communication device information
let appInfo: wearEngine.AppInfo = {
  bundleName: 'com.example.phone_connect',
  fingerprint: '6917560890589341513'
};

let appParam: wearEngine.P2pAppParam = {
  remoteApp: appInfo
};

// [Start deviceClient_init]
// [Start p2pClient_init]
export class ConnectUtil {
  // [StartExclude p2pClient_init]
  // Peer communication device entity class object
  device?: wearEngine.Device;
  // Unique ID of the peer communication device.
  deviceRandomId?: string;
  // Used to obtain linked devices
  deviceClient?: wearEngine.DeviceClient;
  // [StartExclude deviceClient_init]
  // [EndExclude p2pClient_init]
  // Used to p2p
  p2pClient?: wearEngine.P2pClient;
  // [StartExclude p2pClient_init]
  notifyClient?: wearEngine.NotifyClient;

  // [EndExclude p2pClient_init]
  // [EndExclude deviceClient_init]

  constructor(context: Context) {
    if (canIUse('SystemCapability.Health.WearEngine')) {
      // [StartExclude p2pClient_init]
      this.deviceClient = wearEngine.getDeviceClient(context);
      // [EndExclude p2pClient_init]
      // [StartExclude deviceClient_init]
      this.p2pClient = wearEngine.getP2pClient(context);
      // [EndExclude deviceClient_init]
    }
  }
  // [StartExclude p2pClient_init]
  // [StartExclude deviceClient_init]

  // [Start getConnectedDevices]
  // Obtains the information about the peer device connected to the peer device
  // and listens on the communication between the peer device and the peer device.
  async getConnectedDevices(): Promise<void> {
    try {
      if (canIUse('SystemCapability.Health.WearEngine')) {
        let devices: wearEngine.Device[] = await this.deviceClient?.getConnectedDevices() as wearEngine.Device[];
        this.device = devices[0];
        this.deviceRandomId = devices[0].randomId;
      }
      await this.registerMessageReceiver();
    } catch (err) {
      hilog.error(0x0000, TAG, 'getConnectedDevices is err' + JSON.stringify(err));
    }
  }

  // [End getConnectedDevices]

  // [Start sendMessage]
  // Method of sending messages to the peer end
  async sendMessage(message: string): Promise<void> {
    try {
      let p2pMessage: wearEngine.P2pMessage = this.getP2pMessage(message);
      if (canIUse('SystemCapability.Health.WearEngine')) {
        let value = await this.p2pClient?.sendMessage(this.deviceRandomId, appParam, p2pMessage);
        hilog.info(0x0000, TAG, 'sendMessage value is' + JSON.stringify(value))
      }
    } catch (err) {
      hilog.error(0x0000, TAG, 'sys sendMessage is err ' + JSON.stringify(err));
    }
  }

  // [End sendMessage]

  // [Start registerMessageReceiver]
  // Callback Method for Listening to Peer Communication.
  private onMsgCallback: Callback<wearEngine.P2pMessage> = (data: wearEngine.P2pMessage): void => {
    // Decodes the intercepted content into a character string.
    let decoder: util.TextDecoder = util.TextDecoder.create();
    if (canIUse('SystemCapability.Health.WearEngine')) {
      let str: string = decoder.decodeToString(data.content);
      promptAction.openToast({
        message: 'message: ' + str,
        duration: 2000
      });
    }
  }

  // Listening to the communication between the peer end.
  async registerMessageReceiver(): Promise<void> {
    try {
      if (canIUse('SystemCapability.Health.WearEngine')) {
        await this.p2pClient?.registerMessageReceiver(this.deviceRandomId, appParam, this.onMsgCallback);
        hilog.info(0x0000, TAG, 'registerMessageReceiver is ok');
      }
    } catch (err) {
      hilog.error(0x0000, TAG, 'registerMessageReceiver is err ', JSON.stringify(err));
    }
  }

  // Disabling the Interception of Peer Communication。
  async unregisterMessageReceiver(): Promise<void> {
    try {
      if (canIUse('SystemCapability.Health.WearEngine')) {
        await this.p2pClient?.unregisterMessageReceiver(this.deviceRandomId, appParam, this.onMsgCallback);
        hilog.info(0x0000, TAG, 'unregisterMessageReceiver is ok');
      }
    } catch (err) {
      hilog.error(0x0000, TAG, 'unregisterMessageReceiver is err ', JSON.stringify(err));
    }
  }

  // [End registerMessageReceiver]

  // Method of transcoding a string.
  private getP2pMessage(message: string): wearEngine.P2pMessage {
    let encoder: util.TextEncoder = new util.TextEncoder();
    let content: Uint8Array = encoder.encodeInto(message);
    let p2pMessage: wearEngine.P2pMessage = { content: content };
    return p2pMessage;
  }

  // Method of notifying a message to watch.
  notifyMessage() {
    if (canIUse('SystemCapability.Health.WearEngine')) {
      let type1Notification: wearEngine.Notification = {
        type: wearEngine.NotificationType.NOTIFICATION_WITHOUT_BUTTONS,
        bundleName: 'com.example.phone_connect',
        title: 'phone connect',
        text: 'phone notify'
      };
      let options: wearEngine.NotificationOptions = {
        notification: type1Notification,
        onAction: (feedback: wearEngine.NotificationFeedback) => {
          hilog.info(0x000, TAG,
            `one button notify get feedback is ${feedback.action ? feedback.action : feedback.errorCode}`);
        }
      };

      this.notifyClient?.notify(this.deviceRandomId, options).then(result => {
        hilog.info(0x000, TAG, `Succeeded in sending notification.`);
      }).catch((error: BusinessError) => {
        hilog.error(0x000, TAG, `Failed to send notification. Code is ${error.code}, message is ${error.message}`);
      })
    }
  }
  // [EndExclude p2pClient_init]
  // [EndExclude deviceClient_init]
}
// [End p2pClient_init]
// [End deviceClient_init]