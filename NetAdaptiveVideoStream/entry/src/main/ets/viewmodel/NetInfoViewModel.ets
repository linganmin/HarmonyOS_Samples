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

import { netQuality } from '@kit.NetworkBoostKit';
import Logger from '../common/utils/Logger';
import { NetInfoModel } from '../model/NetInfoModel';

@Observed
export class NetInfoViewModel {
  @Track netInfoList: Array<NetInfoModel>;

  constructor() {
    this.netInfoList = [
      new NetInfoModel(netQuality.PathType.CELLULAR_PRIMARY),
      new NetInfoModel(netQuality.PathType.CELLULAR_SECONDARY),
      new NetInfoModel(netQuality.PathType.WIFI_PRIMARY),
      new NetInfoModel(netQuality.PathType.WIFI_SECONDARY)
    ];
  }

  public setAllCallback(weakNetCallback: Callback<string>) {
    try {
      netQuality.on('netQosChange', (netQosList: Array<netQuality.NetworkQos>) => {
        this.netQosChangeCallback(netQosList);
      });
      netQuality.on('netSceneChange', (netSceneList: Array<netQuality.NetworkScene>) => {
        this.netSceneChangeCallback(netSceneList);
        this.weakNetCallback(netSceneList, weakNetCallback);
      });
    } catch (error) {
      Logger.error(`setAllCallback error: ${JSON.stringify(error)}`);
    }
  }

  public clearAllCallback() {
    try {
      netQuality.off('netQosChange');
      netQuality.off('netSceneChange');
    } catch (error) {
      Logger.error(`clearAllCallback error: ${JSON.stringify(error)}`);
    }
  }

  private netQosChangeCallback(netQosList: Array<netQuality.NetworkQos>) {
    if (netQosList.length <= 0) {
      return;
    }
    netQosList.forEach((qos) => {
      const pathType = qos.pathType;
      this.netInfoList[pathType].qosDownBandWidth = qos.linkDownBandwidth;
      this.netInfoList[pathType].qosDownRate = qos.linkDownRate;
      this.netInfoList[pathType].qosRttMs = qos.rttMs;
    });
  }

  private netSceneChangeCallback(netSceneList: Array<netQuality.NetworkScene>) {
    if (netSceneList.length <= 0) {
      return;
    }
    netSceneList.forEach((scene) => {
      const pathType = scene.pathType;
      this.netInfoList[pathType].scene = scene.scene;
      this.netInfoList[pathType].recommendedAction = scene.recommendedAction;
    });
  }

  private weakNetCallback(netSceneList: Array<netQuality.NetworkScene>, customCallback: Callback<string>) {
    if (netSceneList.length <= 0) {
      return;
    }
    netSceneList.forEach((scene) => {
      customCallback(scene.scene);
    });
  }
}