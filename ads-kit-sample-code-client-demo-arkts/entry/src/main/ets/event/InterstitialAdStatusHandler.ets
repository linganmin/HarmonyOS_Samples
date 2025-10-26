/*
 * Copyright 2023. Huawei Technologies Co., Ltd. All rights reserved.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
 */

import { BusinessError, commonEventManager } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AdStatus } from '../constant/AdStatus';

const TAG: string = 'Ads Demo-InterstitialAdStatusHandler';
const KEY_INTERSTITIAL_STATUS: string = 'interstitial_ad_status';

export class InterstitialAdStatusHandler {
  // Used to save the created subscriber object for subsequent subscription and unsubscription.
  private subscriber: commonEventManager.CommonEventSubscriber | null = null;

  registerPPSReceiver(): void {
    if (this.subscriber) {
      this.unRegisterPPSReceiver();
    }
    const subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
      events: ['com.huawei.hms.pps.action.PPS_INTERSTITIAL_STATUS_CHANGED'],
      publisherBundleName: 'com.huawei.hms.adsservice'
    };
    commonEventManager.createSubscriber(subscribeInfo,
      (err: BusinessError, commonEventSubscriber: commonEventManager.CommonEventSubscriber) => {
        if (err) {
          hilog.error(0x0000, TAG, `Failed to create subscriber. Code is ${err.code}, message is ${err.message}`);
          return;
        }
        hilog.info(0x0000, TAG, 'Succeeded in creating subscriber');
        this.subscriber = commonEventSubscriber;
        commonEventManager.subscribe(this.subscriber,
          (err: BusinessError, commonEventData: commonEventManager.CommonEventData) => {
            if (err) {
              hilog.error(0x0000, TAG, `Failed to subscribe. Code is ${err.code}, message is ${err.message}`);
            } else {
              hilog.info(0x0000, TAG, 'Succeeded in subscribing data');
              const status: string = commonEventData?.parameters?.[KEY_INTERSTITIAL_STATUS];
              switch (status) {
                case AdStatus.AD_OPEN:
                  hilog.info(0x0000, TAG, 'Status is onAdOpen');
                  break;
                case AdStatus.AD_CLICKED:
                  hilog.info(0x0000, TAG, 'Status is onAdClick');
                  break;
                case AdStatus.AD_CLOSED:
                  hilog.info(0x0000, TAG, 'Status is onAdClose');
                  this.unRegisterPPSReceiver();
                  break;
                case AdStatus.VIDEO_PLAY_BEGIN:
                  hilog.info(0x0000, TAG, 'Status is onVideoPlayBegin');
                  break;
                case AdStatus.VIDEO_PLAY_END:
                  hilog.info(0x0000, TAG, 'Status is onVideoPlayEnd');
                  break;
              }
            }
          });
      });
  }

  unRegisterPPSReceiver(): void {
    commonEventManager.unsubscribe(this.subscriber, (err: BusinessError) => {
      if (err) {
        hilog.error(0x0000, TAG, `Failed to unsubscribe. Code is ${err.code}, message is ${err.message}`);
      } else {
        hilog.info(0x0000, TAG, 'Succeeded in unsubscribing');
        this.subscriber = null;
      }
    });
  }
}