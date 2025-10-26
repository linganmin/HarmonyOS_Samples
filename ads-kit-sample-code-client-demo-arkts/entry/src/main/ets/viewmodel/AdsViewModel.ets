/*
 * Copyright 2025. Huawei Technologies Co., Ltd. All rights reserved.

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

import { common } from '@kit.AbilityKit';
import { advertising } from '@kit.AdsKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AdType } from '../constant/AdType';
import { InterstitialAdStatusHandler } from '../event/InterstitialAdStatusHandler';
import { RewardAdStatusHandler } from '../event/RewardAdStatusHandler';
import { TimeOutHandler } from '../event/TimeOutHandler';

const TAG: string = 'Ads Demo-AdsViewModel';

@ObservedV2
export class AdsViewModel {
  @Trace ads: advertising.Advertisement[] = [];

  // Ad configuration.
  adOptions: advertising.AdOptions = {};

  // Ad display parameters.
  adDisplayOptions: advertising.AdDisplayOptions = {
    // Whether to mute the ad.
    mute: true,
    // Interval for displaying an ad in carousel mode, in ms.
    refreshTime: 30000
  };

  navPathStack: NavPathStack;

  private context: common.UIAbilityContext;

  constructor(uiContext: UIContext) {
    this.context = uiContext.getHostContext() as common.UIAbilityContext;
    this.navPathStack = AppStorageV2.connect(NavPathStack)!;
  }

  getParamsFromNav(adType: AdType): advertising.AdRequestParams {
    return this.navPathStack.getParamByName(AdType[adType])[0] as advertising.AdRequestParams;
  }

  async loadAd(adRequestParams: advertising.AdRequestParams): Promise<void> {
    const adType = adRequestParams.adType;
    let timeOutHandler: TimeOutHandler;
    if (adType === AdType.SPLASH) {
      timeOutHandler = new TimeOutHandler(() => this.routeToHome());
    }
    // Ad request callback listener.
    const adLoadListener: advertising.AdLoadListener = {
      onAdLoadFailure: (errorCode: number, errorMsg: string) => {
        hilog.error(0x0000, TAG, `Failed to load ad. Code is ${errorCode}, message is ${errorMsg}`);
      },
      onAdLoadSuccess: (ads: Array<advertising.Advertisement>) => {
        hilog.info(0x0000, TAG, 'Succeeded in loading ad');
        if (adType === AdType.SPLASH) {
          timeOutHandler?.clear();
          if (timeOutHandler?.isTimeOut) {
            return;
          }
        }
        if (adType === AdType.REWARD) {
          // Register a status listener for rewarded ads to monitor their playback status.
          new RewardAdStatusHandler().registerPPSReceiver();
          try {
            // Call the API for displaying ads.
            advertising.showAd(ads[0], this.adDisplayOptions, this.context);
          } catch (e) {
            hilog.error(0x0000, 'testTag', `Failed to show ad. Code is ${e.code}, message is ${e.message}`);
          }
          return;
        }
        if (adType === AdType.INTERSTITIAL) {
          // Register a status listener for interstitial ads to monitor their playback status.
          new InterstitialAdStatusHandler().registerPPSReceiver();
          try {
            // Call the API for displaying ads.
            advertising.showAd(ads[0], this.adDisplayOptions, this.context);
          } catch (e) {
            hilog.error(0x0000, 'testTag', `Failed to show ad. Code is ${e.code}, message is ${e.message}`);
          }
          return;
        }
        this.ads = ads;
      }
    };
    // Create an AdLoader ad object.
    const adLoader: advertising.AdLoader = new advertising.AdLoader(this.context);
    try {
      // Call the API for requesting ads.
      adLoader.loadAd(adRequestParams, this.adOptions, adLoadListener);
    } catch (e) {
      hilog.error(0x0000, 'testTag', `Failed to load ad. Code is ${e.code}, message is ${e.message}`);
    }
  }

  async loadAdWithMultiSlots(adRequestParamsArray: advertising.AdRequestParams[]): Promise<void> {
    // Ad request callback listener.
    const multiSlotsAdLoaderListener: advertising.MultiSlotsAdLoadListener = {
      onAdLoadFailure: (errorCode: number, errorMsg: string) => {
        hilog.error(0x0000, TAG, `Failed to load multiSlots ad. Code is ${errorCode}, message is ${errorMsg}`);
      },
      onAdLoadSuccess: (ads: Map<string, Array<advertising.Advertisement>>) => {
        hilog.info(0x0000, TAG, 'Succeeded in loading multiSlots ad');
        const returnAds: Array<advertising.Advertisement> = [];
        ads.forEach((adsArray) => returnAds.push(...adsArray));
        this.ads = returnAds;
      }
    };
    // Create an AdLoader ad object.
    const adLoader: advertising.AdLoader = new advertising.AdLoader(this.context);
    try {
      // Call the API for requesting ads.
      adLoader.loadAdWithMultiSlots(adRequestParamsArray, this.adOptions, multiSlotsAdLoaderListener);
    } catch (e) {
      hilog.error(0x0000, 'testTag', `Failed to load multiSlots ad. Code is ${e.code}, message is ${e.message}`);
    }
  }

  async routeToHome(): Promise<void> {
    try {
      hilog.info(0x0000, TAG, 'Start to route to home');
      // You can change the target page for redirection based on the actual situation.
      this.navPathStack.clear();
    } catch (e) {
      hilog.error(0x0000, TAG, `Failed to route to home. Code is ${e.code}, message is ${e.message}`);
    }
  }
}