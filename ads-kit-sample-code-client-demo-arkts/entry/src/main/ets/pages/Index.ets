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

import { abilityAccessCtrl, common, PermissionRequestResult } from '@kit.AbilityKit';
import { advertising, identifier } from '@kit.AdsKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AdType } from '../constant/AdType';
import { AdsViewModel } from '../viewmodel/AdsViewModel';
import { BannerAdPage } from './ads/BannerAdPage';
import { NativeAdPage } from './ads/NativeAdPage';
import { RollAdPage } from './ads/RollAdPage';
import { SplashAdPage } from './ads/SplashAdPage';

const TAG: string = 'Ads Demo-Index';

@Entry
@ComponentV2
struct Index {
  @Local private buttonsOptions: ButtonOptions[] = [];
  private context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private navPathStack: NavPathStack = AppStorageV2.connect(NavPathStack, () => new NavPathStack())!;
  private viewModel: AdsViewModel = new AdsViewModel(this.getUIContext());

  async aboutToAppear() {
    const oaid = await requestOAID(this.context);
    // Banner Ad.
    this.buttonsOptions.push({
      text: $r('app.string.request_banner_ad_btn'),
      adRequestParams: {
        adId: 'testw6vs28auh3',
        adType: AdType.BANNER,
        adWidth: 360,
        adHeight: 57,
        oaid: oaid
      }
    });
    // Native video ad.
    this.buttonsOptions.push({
      text: $r('app.string.request_native_video_ad_btn'),
      adRequestParams: {
        adId: 'testy63txaom86',
        adType: AdType.NATIVE,
        adCount: 1,
        enableDirectReturnVideoAd: true,
        oaid: oaid
      }
    });
    // Native large image ad.
    this.buttonsOptions.push({
      text: $r('app.string.request_native_large_image_ad_btn'),
      adRequestParams: {
        adId: 'testu7m3hc4gvm',
        adType: AdType.NATIVE,
        adCount: 1,
        enableDirectReturnVideoAd: true,
        oaid: oaid
      }
    });
    // Native small image ad.
    this.buttonsOptions.push({
      text: $r('app.string.request_native_small_image_ad_btn'),
      adRequestParams: {
        adId: 'testb65czjivt9',
        adType: AdType.NATIVE,
        adCount: 1,
        enableDirectReturnVideoAd: true,
        oaid: oaid
      }
    });
    // Native three-image ad.
    this.buttonsOptions.push({
      text: $r('app.string.request_native_three_image_ad_btn'),
      adRequestParams: {
        adId: 'testr6w14o0hqz',
        adType: AdType.NATIVE,
        adCount: 1,
        enableDirectReturnVideoAd: true,
        oaid: oaid
      }
    });
    // Rewarded ad.
    this.buttonsOptions.push({
      text: $r('app.string.request_reward_ad_btn'),
      shouldShowAd: true,
      adRequestParams: {
        adId: 'testx9dtjwj8hp',
        adType: AdType.REWARD,
        oaid: oaid
      }
    });
    // Interstitial video ad.
    this.buttonsOptions.push({
      text: $r('app.string.request_interstitial_video_ad_btn'),
      shouldShowAd: true,
      adRequestParams: {
        adId: 'testb4znbuh3n2',
        adType: AdType.INTERSTITIAL,
        oaid: oaid
      }
    });
    // Interstitial image ad.
    this.buttonsOptions.push({
      text: $r('app.string.request_interstitial_image_ad_btn'),
      shouldShowAd: true,
      adRequestParams: {
        adId: 'teste9ih9j0rc3',
        adType: AdType.INTERSTITIAL,
        oaid: oaid
      }
    });
    // Splash video ad.
    this.buttonsOptions.push({
      text: $r('app.string.request_splash_video_ad_btn'),
      adRequestParams: {
        adId: 'testd7c5cewoj6',
        adType: AdType.SPLASH,
        adCount: 1,
        oaid: oaid
      }
    });
    // Splash image ad.
    this.buttonsOptions.push({
      text: $r('app.string.request_splash_image_ad_btn'),
      adRequestParams: {
        adId: 'testq6zq98hecj',
        adType: AdType.SPLASH,
        adCount: 1,
        oaid: oaid
      }
    });
    // Roll ad.
    this.buttonsOptions.push({
      text: $r('app.string.request_roll_ad_btn'),
      adRequestParams: {
        adId: 'testy3cglm3pj0',
        adType: AdType.ROLL,
        isPreload: false,
        oaid: oaid
      }
    });
  }

  build() {
    Navigation(this.navPathStack) {
      Column() {
        List() {
          Repeat<ButtonOptions>(this.buttonsOptions).each((repeatItem: RepeatItem<ButtonOptions>) => {
            ListItem() {
              Button(repeatItem.item.text)
                .fontSize(20)
                .fontWeight(FontWeight.Normal)
                .width('90%')
                .margin({ top: 10, bottom: 10 })
                .onClick(() => {
                  const options: ButtonOptions = repeatItem.item;
                  if (options.shouldShowAd) {
                    this.viewModel.loadAd(options.adRequestParams);
                    return;
                  }
                  if (options.adRequestParams?.adType) {
                    this.navPathStack.pushPathByName(AdType[options.adRequestParams?.adType], options.adRequestParams);
                  }
                })
            }
          })
        }
        .height('100%')
        .width('100%')
        .alignListItem(ListItemAlign.Center)
      }
      .height('100%')
      .width('100%')
    }
    .title($r('app.string.ads_demo_title'))
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .hideBackButton(true)
    .navDestination(this.pageMap)
  }

  @Builder
  pageMap(name: string) {
    if (name === AdType[AdType.BANNER]) {
      BannerAdPage()
    } else if (name === AdType[AdType.NATIVE]) {
      NativeAdPage()
    } else if (name === AdType[AdType.ROLL]) {
      RollAdPage()
    } else if (name === AdType[AdType.SPLASH]) {
      SplashAdPage()
    }
  }
}

interface ButtonOptions {
  text: ResourceStr;
  adRequestParams: advertising.AdRequestParams;
  shouldShowAd?: boolean;
}

async function requestOAID(context: Context): Promise<string | undefined> {
  let isPermissionGranted: boolean = false;
  try {
    const atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    const result: PermissionRequestResult =
      await atManager.requestPermissionsFromUser(context, ['ohos.permission.APP_TRACKING_CONSENT']);
    isPermissionGranted = result.authResults[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
  } catch (err) {
    hilog.error(0x0000, TAG, `Failed to request permission. Code is ${err.code}, message is ${err.message}`);
  }
  if (isPermissionGranted) {
    hilog.info(0x0000, TAG, 'Succeeded in requesting permission');
    try {
      const oaid = await identifier.getOAID();
      hilog.info(0x0000, TAG, 'Succeeded in getting OAID');
      return oaid;
    } catch (err) {
      hilog.error(0x0000, TAG, `Failed to get OAID. Code is ${err.code}, message is ${err.message}`);
    }
  } else {
    hilog.error(0x0000, TAG, 'Failed to request permission. User rejected');
  }
  return undefined;
}