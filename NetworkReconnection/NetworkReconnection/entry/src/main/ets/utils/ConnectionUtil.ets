/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import { connection } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../utils/Logger';

export class ConnectionUtil {
  // [Start net_capabilities_change]
  private netCon: connection.NetConnection = connection.createNetConnection();

  register() {
    this.netCon.register((error: BusinessError) => {
      Logger.error('net register' + JSON.stringify(error));
    });
  }

  netCapabilitiesChange() {
    this.netCon.on('netCapabilitiesChange', (data: connection.NetCapabilityInfo) => {
      let netAvailable = false;
      data.netCap.networkCap?.forEach((value) => {
        if (value === connection.NetCap.NET_CAPABILITY_INTERNET) {
          netAvailable = true;
        }
      })
      Logger.info('ConnectionUtil.netAvailable:' + netAvailable);
      AppStorage.setOrCreate('netAvailable', netAvailable);
    })

    this.netCon.on('netLost', (data: connection.NetHandle) => {
      AppStorage.setOrCreate('netAvailable', false);
      Logger.info("WifiChangeListen-- Succeeded to get data: " + JSON.stringify(data));
    });
  }
  // [End net_capabilities_change]

  unregister() {
    this.netCon.unregister((error: BusinessError) => {
      Logger.info(JSON.stringify(error));
    });
  }
}

export default new ConnectionUtil();