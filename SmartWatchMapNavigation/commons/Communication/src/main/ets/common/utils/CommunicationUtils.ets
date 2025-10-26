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

import { wearEngine } from '@kit.WearEngine';
import { BusinessError, Callback } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CommunicationInformation } from '../model/CommunicationInformation';

const TAG: string = 'CommunicationUtils';

// Peer communication device information
let appInfo: wearEngine.AppInfo = {
  bundleName: 'com.example.smartwatchmapnavigation',
  fingerprint: '6917571151412502832'
};

let appParam: wearEngine.P2pAppParam = {
  remoteApp: appInfo
};

export class CommunicationUtils {
  // Peer communication device entity class object
  device?: wearEngine.Device;
  // Unique ID of the peer communication device.
  deviceRandomId?: string;
  // Used to obtain linked devices
  deviceClient: wearEngine.DeviceClient;
  // Used to p2p
  p2pClient: wearEngine.P2pClient;
  // [Start notifyClient]
  // Used to notify message
  notifyClient: wearEngine.NotifyClient | undefined;
  // [End notifyClient]

  constructor(context: Context) {
    this.deviceClient = wearEngine.getDeviceClient(context);
    this.p2pClient = wearEngine.getP2pClient(context);
  }

  /**
   * Obtains the information about the peer device connected to the peer device
   * and listens on the communication between the peer device and the peer device.
   */
  async getConnectedDevices(): Promise<void> {
    try {
      let devices: wearEngine.Device[] = await this.deviceClient.getConnectedDevices();
      this.device = devices[0];
      this.deviceRandomId = devices[0].randomId;
      await this.registerMessageReceiver();
    } catch (err) {
      hilog.error(0x0000, TAG, 'getConnectedDevices is err' + JSON.stringify(err));
    }
  }

  // [Start onMsgCallback]
  /**
   * Callback Method for Listening to Peer Communication.
   */
  private onMsgCallback: Callback<wearEngine.P2pMessage> = (data: wearEngine.P2pMessage): void => {
    let str: string = '';
    // Decodes the intercepted content into a character string.
    if (canIUse('SystemCapability.Utils.Lang')) {
      let decoder: util.TextDecoder = util.TextDecoder.create();
      str = decoder.decodeToString(data.content);
    }
    // Convert the JSON character string to the CommunicationInformation type.
    let communicationInformation: CommunicationInformation = JSON.parse(str);
    // Determine the information type based on the tag.
    if (communicationInformation.tag === 0) {
      // When tag is set to 0,Indicates that the transferred information is path description information,
      // which is stored in AppStorage to refresh the watch navigation page.
      AppStorage.setOrCreate('route_information', communicationInformation.routeInfomation);
    } else if (communicationInformation.tag === 1) {
      // When tag is set to 1, Indicates that the transferred information is destination location information
      // and is saved to the AppStorage for synchronizing the destination logo of the mobile phone and watch.
      AppStorage.setOrCreate('destination_Position', communicationInformation.location);
    } else if (communicationInformation.tag === 2) {
      // Signal sent from your phone to your watch when navigation starts, indicating that navigation starts.
      AppStorage.setOrCreate('isStartNavigation', true);
    } else {
      // Signal sent from your watch to your phone when navigation ends, indicating that navigation ends.
      AppStorage.setOrCreate('isStartNavigation', false);
    }
  }
  // [End onMsgCallback]


  /**
   * Method of sending messages to the peer end
   * @param message : Character string content sent to the peer end.
   */
  async sendMessage(message: string): Promise<void> {
    try {
      let p2pMessage: wearEngine.P2pMessage = this.getP2pMessage(message);
      let value = await this.p2pClient.sendMessage(this.deviceRandomId, appParam, p2pMessage);
      hilog.info(0x0000, TAG, 'sendMessage value is' + JSON.stringify(value))
    } catch (err) {
      hilog.error(0x0000, TAG, 'sys sendMessage is err ' + JSON.stringify(err));
    }
  }

  /*
   * Listening to the communication between the peer end.
   */
  async registerMessageReceiver(): Promise<void> {
    try {
      await this.p2pClient.registerMessageReceiver(this.deviceRandomId, appParam, this.onMsgCallback);
      hilog.info(0x0000, TAG, 'registerMessageReceiver is ok');
    } catch (err) {
      hilog.error(0x0000, TAG, 'registerMessageReceiver is err ', JSON.stringify(err));
    }
  }

  /*
   * Disabling the Interception of Peer Communication.
   */
  async unregisterMessageReceiver(): Promise<void> {
    try {
      await this.p2pClient.unregisterMessageReceiver(this.deviceRandomId, appParam, this.onMsgCallback);
      hilog.info(0x0000, TAG, 'unregisterMessageReceiver is ok');
    } catch (err) {
      hilog.error(0x0000, TAG, 'unregisterMessageReceiver is err ', JSON.stringify(err));
    }
  }

  /*
   * Disabling the Interception of Peer Communication.
   * @param message : Character string content sent to the peer end.
   */
  private getP2pMessage(message: string): wearEngine.P2pMessage {
    let content: Uint8Array = new Uint8Array();
    if (canIUse('SystemCapability.Utils.Lang')) {
      let encoder: util.TextEncoder = new util.TextEncoder();
      content = encoder.encodeInto(message);
    }
    let p2pMessage: wearEngine.P2pMessage = { content: content };
    return p2pMessage;
  }

  // [Start notifyMessage]
  /*
   * Method of notifying a message to watch.
   */
  notifyMessage() {
    // Configure the notification content.
    // Including the package name of the notification source, notification title, and notification content.
    let type1Notification: wearEngine.Notification = {
      type: wearEngine.NotificationType.NOTIFICATION_WITHOUT_BUTTONS,
      bundleName: 'com.example.smartwatchmapnavigation',
      title: 'smartwatchmapnavigation',
      text: 'walk navigation start',
    }
    let options: wearEngine.NotificationOptions = {
      notification: type1Notification,
      onAction: (feedback: wearEngine.NotificationFeedback) => {
        hilog.info(0x000, TAG,
          `one button notify get feedback is ${feedback.action ? feedback.action : feedback.errorCode}`);
      }
    }

    // Sends a notification to the watch based on notifyClient.
    // This method can be invoked only by apps on mobile phones.
    this.notifyClient!.notify(this.deviceRandomId, options).then(result => {
      hilog.info(0x000, TAG, `Succeeded in sending notification.`);
    }).catch((error: BusinessError) => {
      hilog.error(0x000, TAG, `Failed to send notification. Code is ${error.code}, message is ${error.message}`);
    })
  }
  // [End notifyMessage]
}