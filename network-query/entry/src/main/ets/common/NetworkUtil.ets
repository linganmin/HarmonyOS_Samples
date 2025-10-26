/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use Logger file except in compliance with the License.
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

import { BusinessError, request } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { connection } from '@kit.NetworkKit';
import { fileUri } from '@kit.CoreFileKit';
import { radio } from '@kit.TelephonyKit';
import { wifiManager } from '@kit.ConnectivityKit';
import { Logger } from './Logger';

const TAG = 'NetworkUtilTag';

export class NetworkUtil {
  private static downloadTask: request.agent.Task | undefined;

  /**
   * Get wifi signal strength
   * @returns {number} Signal strength value
   */
  public static getWifiSignalRssi(): number {
    try {
      let linkInfo = wifiManager.getLinkedInfoSync();
      let rssi = linkInfo.rssi;
      return rssi;
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `getWifiRssi err, code: ${error.code}, message: ${error.message}`);
      return 0;
    }
  }

  // [Start is_network_available]
  public static isNetworkAvailable(): boolean {
    try {
      let netHandle = connection.getDefaultNetSync();
      if (netHandle.netId === 0) {
        // If there is no network connected, the netid of the obtained netHandler is 0
        return false;
      }
      let netCapability = connection.getNetCapabilitiesSync(netHandle);
      let networkCaps: connection.NetCap[] = netCapability.networkCap || [];
      return networkCaps.includes(connection.NetCap.NET_CAPABILITY_VALIDATED);
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `getNetworkType err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
    return false;
  }
  // [End is_network_available]

  public static isCellular(): boolean {
    try {
      let netHandle = connection.getDefaultNetSync();
      if (netHandle.netId === 0) {
        // If there is no network connected, the netid of the obtained netHandler is 0
        return false;
      }
      let netCapability = connection.getNetCapabilitiesSync(netHandle);
      let bearTypes: connection.NetBearType[] = netCapability.bearerTypes;
      return bearTypes.includes(connection.NetBearType.BEARER_CELLULAR);
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `isCellular err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
    return true;
  }

  /**
   * Get cellular network signal strength
   * @returns {Promise<number>} Cellular network signal strength value
   */
  public static async getCellularSignalRssi(): Promise<number> {
    try {
      let primarySlotId = await radio.getPrimarySlotId();
      let signalInfos: radio.SignalInformation[] = radio.getSignalInformationSync(primarySlotId);
      if (signalInfos.length > 0) {
        let signalInfo = signalInfos[0];
        return signalInfo.dBm;
      }
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `getCellularSignalRssi err, errCode: ${error.code}, error mesage: ${error.message}`);
    }
    return 0;
  }

  public static getCellularTypeStr(signalType: number): string {
    let cellularType = '';
    switch (signalType) {
      case radio.NetworkType.NETWORK_TYPE_UNKNOWN:
        cellularType = 'unknown';
        break;
      case radio.NetworkType.NETWORK_TYPE_GSM:
        cellularType = 'GSM';
        break;
      case radio.NetworkType.NETWORK_TYPE_CDMA:
        cellularType = 'CDMA';
        break;
      case radio.NetworkType.NETWORK_TYPE_WCDMA:
        cellularType = 'WCDMA';
        break;
      case radio.NetworkType.NETWORK_TYPE_TDSCDMA:
        cellularType = 'TDSCDMA';
        break;
      case radio.NetworkType.NETWORK_TYPE_LTE:
        cellularType = 'LTE';
        break;
      case radio.NetworkType.NETWORK_TYPE_NR:
        cellularType = 'NR';
        break;
      default:
        break;
    }
    return cellularType;
  }

  public static getNetworkTypeStr(type: connection.NetBearType): string {
    let networkTypeStr = '';
    switch (type) {
      case connection.NetBearType.BEARER_CELLULAR:
        networkTypeStr = 'cellular';
        break;
      case connection.NetBearType.BEARER_WIFI:
        networkTypeStr = 'wifi';
        break;
      case connection.NetBearType.BEARER_BLUETOOTH:
        networkTypeStr = 'bluetooth';
        break;
      case connection.NetBearType.BEARER_ETHERNET:
        networkTypeStr = 'ethernet';
        break;
      case connection.NetBearType.BEARER_VPN:
        networkTypeStr = 'vpn';
        break;
      default:
        break;
    }
    return networkTypeStr;
  }

  public static async downloadFile(context: common.UIAbilityContext, resUrl: string, cachePath: string) {
    try {
      let uri: string = fileUri.getUriFromPath(cachePath);
      if (uri === '') {
        return;
      }
      let config: request.agent.Config = {
        action: request.agent.Action.DOWNLOAD,
        url: resUrl,
        saveas: uri,
        gauge: true,
        // Starting from API version 20, the download to user file scenario must be
        overwrite: true,
        // Starting from API version 20, the download to the user file scenario must be request.agent.Mode.FOREGROUND
        mode: request.agent.Mode.FOREGROUND,
      };
      request.agent.create(context, config).then((task: request.agent.Task) => {
        NetworkUtil.downloadTask = task;
        task.start((err: BusinessError) => {
          if (err) {
            Logger.error(TAG, `Failed to start the download task, Code: ${err.code}  message: ${err.message}`);
            return;
          }
        });

        task.on('remove', async (progress) => {
          Logger.info(TAG, 'Request download remove, ' + progress.processed);
          Logger.info(TAG, 'avg download speed: ' + progress.processed / 1024 / 1024 / 10);
        })

        task.on('failed', async (progress) => {
          Logger.error(TAG, 'Request download failed, ' + JSON.stringify(progress));
          request.agent.remove(task.tid);
        })

        task.on('progress', async (progress) => {
          // Download progress in B
          Logger.info(TAG, `Request download status ${progress.state}, downloaded ${progress.processed}`);
        })
        task.on('completed', async (progress) => {
          Logger.info(TAG, 'Request download completed, ' + JSON.stringify(progress));
          request.agent.remove(task.tid);
        })
      })
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(TAG, `downloadFile err, code: ${error.code}, message: ${error.message}`);
    }
  }

  public static removeTask() {
    if (NetworkUtil.downloadTask) {
      request.agent.remove(NetworkUtil.downloadTask.tid).then(() => {
        Logger.info(TAG, `Succeeded in removing a download task. `);
      }).catch((err: BusinessError) => {
        Logger.error(TAG, `Failed to remove a download task, Code: ${err.code}, message: ${err.message}`);
      });
    }
  }
}