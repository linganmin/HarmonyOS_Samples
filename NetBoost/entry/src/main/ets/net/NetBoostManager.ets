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

import { netBoost, netHandover, netQuality } from '@kit.NetworkBoostKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { connection, socket } from '@kit.NetworkKit';
import { getAllNetHandles } from './NetConnectionManager';
import { CommonConst } from '../common/CommonConst';

const DOMAIN = 0x0000;
const TAG = 'NetBoostUtils';

/**
 * Report qoe to system.
 * @param appQoe net quality, default is good.
 * */
export function reportQoe(appQoe?: netQuality.QoeType) {
  try {
    let type = appQoe ? appQoe : 'good';
    netQuality.reportQoe({
      serviceType: 'upload',
      qoeType: type
    });
  } catch (err) {
    const error: BusinessError = err as BusinessError;
    hilog.error(DOMAIN, TAG, `[reportQoe] Error:${error.code},${error.name}`);
  }
}

// [Start set_upload_scene]
/**
 * Enter or exit 'upload' scene.
 * @param enter true enter,false exit.
 * */
export function setUploadSceneDesc(enter: boolean): boolean {
  try {
    let sceneDesc: netBoost.SceneDesc = {
      scene: 'upload',
      sceneEvent: enter ? netBoost.SceneEvent.SCENE_EVENT_ENTER : netBoost.SceneEvent.SCENE_EVENT_LEAVE
    };
    netBoost.setSceneDesc(sceneDesc);
    return true;
  } catch (err) {
    const error: BusinessError = err as BusinessError;
    hilog.error(DOMAIN, TAG, `[setUploadSceneDesc] Error:${error.code},${error.name}`);
    return false;
  }
}
// [End set_upload_scene]

// [Start request_multi_path]
/**
 * Request a multi-network path.
 * @returns Returns true on success, otherwise false.
 * */
export function requestMultiPath(): Promise<boolean> {
  return new Promise((resolve) => {
    try {
      netHandover.requestMultiPath((data: netHandover.MultiPathRequestResult) => {
        if (data && data.result === netHandover.MultiPathErrorResult.MULTIPATH_ERROR_NONE) {
          resolve(true);
        } else {
          resolve(false);
        }
      });
    } catch (err) {
      resolve(false);
      const error: BusinessError = err as BusinessError;
      hilog.error(DOMAIN, TAG, `[requestMultiPath] Error:${error.code},${error.name}`);
    }
  })
}
// [End request_multi_path]

// [Start release_multi_path]
/**
 * Stop multi net path.
 * */
export function releaseMultiPath() {
  try {
    netHandover.releaseMultiPath();
  } catch (err) {
    const error: BusinessError = err as BusinessError;
    hilog.error(DOMAIN, TAG, `[releaseMultiPath] Error:${error.code},${error.name}`);
  }
}

// [StartExclude release_multi_path]
/**
 * Start listening for multi-path suggestions.
 * @param callback The callback when the multi-path suggestions changes.
 * */
export function setOnMultiPathRecommendation(callback?: NetRecommendationCallback) {
  try {
    netHandover.on('multiPathRecommendation', (data: netHandover.MultiPathRecommendationInfo) => {
      if (data.action === netHandover.MultiPathAction.MULTIPATH_ACTION_REQUEST) {
        hilog.info(DOMAIN, TAG, `[setOnMultiPathRecommendation] Recommend requestMultiPath`);
      } else if (data.action === netHandover.MultiPathAction.MULTIPATH_ACTION_RELEASE) {
        hilog.info(DOMAIN, TAG, `[setOnMultiPathRecommendation] Do not recommend requestMultiPath`);
      } else {
        hilog.error(DOMAIN, TAG, `[setOnMultiPathRecommendation] Not processed status:${data.action}`);
      }
      if (callback) {
        callback.onRecommend(data);
      }
    });
  } catch (err) {
    const error: BusinessError = err as BusinessError;
    hilog.error(DOMAIN, TAG, `[setOnMultiPathRecommendation] Error:${error.code},${error.name}`);
  }
}

/**
 * Stop listening for multi-path suggestions.
 * */
export function setOffMultiPathRecommendation() {
  try {
    netHandover.off('multiPathRecommendation');
  } catch (err) {
    const error: BusinessError = err as BusinessError;
    hilog.error(DOMAIN, TAG, `[setOffMultiPathRecommendation] Error:${error.code},${error.name}`);
  }
}

// [Start on_multi_path_change]
/**
 * Enable multi-network listening.
 * @param netHandleChange The callback when the netHandle changes.
 */
export function setOnMultiPathStateChange(netHandleChange: NetHandleChange) {
  try {
    netHandover.on('multiPathStateChange', (data: netHandover.MultiPathStateInfo) => {
      if (data.multiPathState === netHandover.MultiPathState.MULTIPATH_CREATED &&
        data.netHandle.netId >= CommonConst.MIN_USEFUL_NET_ID) {
        netHandleChange?.onMultiNetSuccess(data.netHandle);
      } else if (data.multiPathState === netHandover.MultiPathState.MULTIPATH_CREATING) {
        hilog.info(DOMAIN, TAG, `[setOnMultiPathStateChange.multiPathStateChange] ${data.netHandle.netId} Creating`);
      } else {
        netHandleChange?.onMultiNetRelease(data.netHandle);
      }
    });
  } catch (err) {
    const error: BusinessError = err as BusinessError;
    hilog.error(DOMAIN, TAG, `[setOnMultiPathStateChange] Error:${error.code},${error.name}`);
  }
}
// [End on_multi_path_change]
// [EndExclude release_multi_path]
/**
 * Stop listening on multiple network paths.
 * */
export function setOffMultiPathStateChange() {
  try {
    netHandover.off('multiPathStateChange');
  } catch (err) {
    const error: BusinessError = err as BusinessError;
    hilog.error(DOMAIN, TAG, `[setOffMultiPathStateChange] Error:${error.code},${error.name}`);
  }
}
// [End release_multi_path]

// [Start get_multi_path_quota]
/**
 * Obtain multi-network quota information.
 * @returns multi-network quota.
 * */
export function getMultiPathQuota(): netHandover.MultiPathQuota | undefined {
  try {
    let quota: netHandover.MultiPathQuota = netHandover.getMultiPathQuotaStats();
    return quota;
  } catch (err) {
    const error: BusinessError = err as BusinessError;
    hilog.error(DOMAIN, TAG, `[getMultiPathQuota] Error:${error.code},${error.name}`);
    return;
  }
}
// [End get_multi_path_quota]

// [Start bind_specified_net]
/**
 * Binds the socket to the specified network path.
 * @param socketInstance  socket client.
 * @param netId netHandle Id.
 * @param port binds port.
 * */
export async function bindSpecifiedNet(socketInstance: socket.TCPSocket, netId: number, port: number) {
  const netHandles = getAllNetHandles();
  if (netHandles) {
    for (let i = 0; i < netHandles.length; i++) {
      if (netHandles[i].netId === netId) {
        try {
          const connectionProperties = connection.getConnectionPropertiesSync(netHandles[i]);
          if (connectionProperties && connectionProperties.linkAddresses &&
            connectionProperties.linkAddresses.length > 0) {
            let netAddress: socket.NetAddress = {
              address: connectionProperties.linkAddresses[0].address.address,
              port: port
            };
            await socketInstance.bind(netAddress);
            await netHandles[i].bindSocket(socketInstance);
          } else {
            hilog.error(DOMAIN, TAG, `[socketBindNet] Get ConnectionProperties error`);
          }
        } catch (err) {
          const error: BusinessError = err as BusinessError;
          hilog.error(DOMAIN, TAG, `[socketBindNet] Error occurred:${error.code},${error.name}`);
        }
        break;
      }
    }
  } else {
    hilog.error(DOMAIN, TAG, `Net Empty`);
  }
}
// [End bind_specified_net]

/**
 * The callback when the netHandle changes.
 * */
export interface NetHandleChange {
  onMultiNetSuccess: (netHandle: connection.NetHandle) => void;
  onMultiNetRelease: (netHandle: connection.NetHandle) => void;
}

/**
 * The callback when the multi-path suggestions changes.
 * */
export interface NetRecommendationCallback {
  onRecommend: (data: netHandover.MultiPathRecommendationInfo) => void;
}