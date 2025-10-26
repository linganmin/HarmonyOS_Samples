/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
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

/*
* FAQ:如何判断当前网络能否上网
*/

// [Start HasNet]
import { connection } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';


@Entry
@Component
export struct NetJudge {
  public static netConnection: connection.NetConnection | undefined = undefined;
  private static JUDGE_NET_TAG: string = 'NetJudge.currNet.isUseful';

  init() {
    NetJudge.netConnection = connection.createNetConnection();
    NetJudge.netConnection.register(() => {
      console.info('connection register success');
    });

    NetJudge.netConnection.on('netAvailable', (data) => {
      console.info('NetJudge  netAvailable ');
      AppStorage.setOrCreate(NetJudge.JUDGE_NET_TAG, this.judgeHasNet());
    });

    NetJudge.netConnection.on('netUnavailable', () => {
      console.info('NetJudge  netUnavailable ');
      AppStorage.setOrCreate(NetJudge.JUDGE_NET_TAG, this.judgeHasNet());
    });

    NetJudge.netConnection.on('netCapabilitiesChange', (data: connection.NetCapabilityInfo) => {
      AppStorage.setOrCreate(NetJudge.JUDGE_NET_TAG, this.judgeHasNet());
    });

    // Subscribe to network connection information change events. You can only receive this event notification after calling register
    NetJudge.netConnection.on('netConnectionPropertiesChange', (data: connection.NetConnectionPropertyInfo) => {
      AppStorage.setOrCreate(NetJudge.JUDGE_NET_TAG, this.judgeHasNet());
    });

    NetJudge.netConnection.on('netLost', () => {
      AppStorage.setOrCreate(NetJudge.JUDGE_NET_TAG, this.judgeHasNet());
    });
  }

  regist() {
    if (NetJudge.netConnection === undefined) {
      this.init();
    }
  }

  judgeHasNet(): boolean {
    try { // Get current network connection
      let netHandle = connection.getDefaultNetSync();

      // 0-100 Reserved connections for the system
      if (!netHandle || netHandle.netId < 100) {
        return false;
      }

      // Get the properties of the connection
      let netCapability = connection.getNetCapabilitiesSync(netHandle);
      let cap = netCapability.networkCap;
      if (!cap) {
        return false;
      }

      for (let em of cap) {
        if (connection.NetCap.NET_CAPABILITY_VALIDATED === em) {
          return true;
        }
      }
    } catch (e) {
      let err = e as BusinessError;
      console.info('get netInfo error ：' + JSON.stringify(err));
    }
    return false;
  }

  build() {
    Column({ space: 10 }) {
      Button('如何判断当前网络能否上网')
        .onClick(() => {
          this.regist();
        })
    }
    .alignItems(HorizontalAlign.Center)
    .height('100%')
    .width('100%')
  }
}
// [End HasNet]

