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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { netHandover } from '@kit.NetworkBoostKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { connection } from '@kit.NetworkKit';

@Entry
@Component
struct requestContent {
  @State content: string = '';

  build() {
    Scroll() {
      Column({ space: 5 }) {
        Row() {
          Text('NetworkHandover')
            .fontSize(30)
            .fontWeight(500)
            .fontColor($r('sys.color.black'))
            .height(30)
            .width(400)
            .margin({ top: '11%' })
        }
        .height(40)
        .width(124)
        .margin({ top: 32 })

        Divider().color('gray').strokeWidth(1)
        Column({ space: 20 }) {
          Button($r('app.string.Subscribe'))
            .width('100%')
            .height(40)
            .margin({ top: '11%' })
            .fontColor($r('sys.color.navigation_drag_bar_item_default'))
            .fontSize(24)
            .fontWeight(500)
            .borderRadius(20)
            .onClick(this.getNetworkHandoverOn)

          Button($r('app.string.UnSubscribe'))
            .width('100%')
            .height(40)
            .margin({ top: '11%' })
            .fontColor($r('sys.color.navigation_drag_bar_item_default'))
            .fontSize(24)
            .fontWeight(500)
            .borderRadius(20)
            .onClick(this.getNetworkHandoverOff)

          Text($r('app.string.Result'))
            .width('100%')
            .height(40)
            .margin({ top: '11%' })
            .fontColor($r('sys.color.black'))
            .fontSize(24)
            .fontWeight(500)
          TextArea({
            text: this.content
          })
            .width('100%')
            .height(260)
            .margin({ top: '11%' })
            .backgroundColor($r('sys.color.gray_01'))
            .fontColor($r('sys.color.black'))
            .fontSize(24)
            .fontWeight(500)
            .borderRadius(10)
        }
      }
      .padding({ left: '16vp', right: '16vp' })
      .alignItems(HorizontalAlign.Start)
    }
    .height('100%')
    .width('100%')
  }

  private getNetworkHandoverOn = async () => {
    try {
      netHandover.on('handoverChange', (info: netHandover.HandoverInfo) => {
        this.content = `callback info + ${JSON.stringify(info)}`;
        hilog.info(0x0000, 'testTag', 'on receive netQosChange event:' + `callback info + ${JSON.stringify(info)}`);
        if (info.handoverStart) {
          // callback for the handoverStart, app may adjusts the data transmission
          // policy based on the suggestion of handoverStart
          hilog.info(0x0000, 'testTag', 'on receive handoverStart callback');
          switch (info.handoverStart.dataSpeedAction.dataSpeedSimpleAction) {
            case 'suspendData':
              hilog.info(0x0000, 'testTag', 'app should suspend sending data');
              break;
            case 'decreaseData':
              hilog.info(0x0000, 'testTag', 'app should decrease the data packet' +
                'transmission((data/coding)rate/frame/resolution ratio/redundancy or other low data methods)');
              break;
            case 'increaseData':
              hilog.info(0x0000, 'testTag', 'app should increase data rate');
              break;
            case 'keepData':
              hilog.info(0x0000, 'testTag', 'app should keep data rate');
              break;
            default:
              break;
          }
        } else if (info.handoverComplete) {
          hilog.info(0x0000, 'testTag', 'on receive handoverComplete callback');
          // callback for the handoverComplete,
          if (info.handoverComplete.result == netHandover.ErrorResult.ERROR_NONE) {
            // handover success
            // process old socket
            if (info.handoverComplete.oldPathLifetime == 0) {
              hilog.info(0x0000, 'testTag', 'app should close all old socket immediately');
            } else if (info.handoverComplete.oldPathLifetime > 0) {
              hilog.info(0x0000, 'testTag', 'app should close all old socket before timer expired');
            }
            switch (info.handoverComplete.reEstAction) {
              case netHandover.ReEstAction.QUERY_DNS:
                // data path type changed, e.g. wifi -> cell, or operator changed.
                if (info.handoverComplete.pathTypeChanged) {
                  // pathTypeChanged is true, e.g. wifi -> cell, or operator changed.
                  let netHandle = info.handoverComplete.newNetHandle;
                  if (netHandle != undefined) {
                    hilog.info(0x0000, 'testTag', 'app invoke getAddressesByName by new netHandle');
                    let host = 'xxx'; // xxx indicate test host, app can also bind socket with netHandle
                    // call getAddressesByName API may need start a new thread, otherwise may block main thread,
                    // following code is just an example.
                    netHandle.getAddressesByName(host, (error: BusinessError, data: connection.NetAddress[]) => {
                      if (error) {
                        hilog.error(0x0000, 'testTag',
                          `Failed to get addresses. Code:${error.code}, message:${error.message}`);
                        return;
                      }
                      hilog.info(0x0000, 'testTag', 'Succeeded to get data: ' + JSON.stringify(data));
                    });
                  }
                } else {
                  // pathTypeChanged is false, app invoke getAddressesByName by old netHandle
                  hilog.info(0x0000, 'testTag', 'app invoke getAddressesByName by old netHandle');
                }
                break;
              case netHandover.ReEstAction.CHANGE_REMOTE_IP:
                // the remote IP needs to be changed, and the App needs to re-establish
                // the connection using the new remote IP
                break;
              case netHandover.ReEstAction.CHANGE_IP_VERSION:
                // the IP version needs to be changed, e.g. ipv4 <-> ipv6.
                break;
              case netHandover.ReEstAction.DEFAULT:
                // the App needs to re-establish the connection through the same remote IP address.
                break;
              case netHandover.ReEstAction.NO_EST:
                // the data path and IP do not change.
                // the App needs to retry to fetch the resource from the remote in the current connection.
                break;
              default:
                break;
            }

            if (!info.handoverComplete.handoverContinue) {
              // whether is still new path to be activated, if value set to false, means the last new path.
              hilog.info(0x0000, 'testTag', 'the last new path');
            }
          } else {
            // handover fail, app may obtains the default active data network through getDefaultNet API in Network Kit.
            hilog.error(0x0000, 'testTag', 'handover fail');
          }
        }
      });
      hilog.info(0x0000, 'testTag', 'on--success');
      this.content = `on--success`;
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      this.content = `on--err` + JSON.stringify(err);
      hilog.error(0x0000, 'testTag', 'on netQosChange error: %{public}d %{public}s', e.code, e.message);
    }
  }
  private getNetworkHandoverOff = async () => {
    try {
      netHandover.off('handoverChange');
      hilog.info(0x0000, 'testTag', 'off--success');
      this.content = `off--success`;
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      this.content = `off--err` + JSON.stringify(err);
      hilog.error(0x0000, 'testTag', 'off handoverChange error: %{public}d %{public}s', e.code, e.message);
    }
  }
}