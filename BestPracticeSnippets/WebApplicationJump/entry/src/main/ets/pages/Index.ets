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

import { webview } from '@kit.ArkWeb';
import { common, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { distributedDeviceManager } from '@kit.DistributedServiceKit';
import { OriginPage } from './OriginPage';
import { Constants } from '../common/Constants';
import { Logger } from '../common/Logger';

const regex = /^resource:\/\//;

@Entry
@Component
struct Index {
  @Provide navPathStack: NavPathStack = new NavPathStack();
  @StorageProp(Constants.SYSTEM_LANGUAGE_KEY) la: string = ''
  private controller: WebviewController = new webview.WebviewController();
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private functionsMap: Map<string, () => void> = new Map();
  private bundleName: string = '';

  aboutToAppear(): void {
    this.bundleName = this.context.abilityInfo.bundleName;
    this.initFunctionsMap();
  }

  getRemoteDeviceId() {
    let networkIdRet: string | undefined = undefined;
    let dmInstance: distributedDeviceManager.DeviceManager =
      distributedDeviceManager.createDeviceManager(this.bundleName);
    if (typeof dmInstance === 'object' && dmInstance !== null) {
      try {
        let list = dmInstance.getAvailableDeviceListSync();
        if (typeof (list) === 'undefined' || typeof (list.length) === 'undefined') {
          Logger.info('EntryAbility onButtonClick getRemoteDeviceId err: list is null')
          return networkIdRet;
        }
        networkIdRet = list[0].networkId;
      } catch (error) {
        hilog.error(0x0000, 'testTag', 'Execution failed, code = %{public}d, message = %{public}s',
          error.code, error.message);
      }
    } else {
      Logger.error('EntryAbility onButtonClick getRemoteDeviceId err: dmClass is null');
    }
    return networkIdRet;
  }

  onBackPress(): boolean | void {
    try {
      if (this.controller.accessBackward()) {
        this.controller.backward();
        return true;
      }
    } catch (error) {
      hilog.error(0x0000, 'testTag', 'Execution failed, code = %{public}d, message = %{public}s',
        error.code, error.message);
    }
  }

  @Builder
  PageMap(name: string) {
    if (name === Constants.ORIGIN_PAGE) {
      OriginPage()
    }
  }

  initFunctionsMap() {
    this.functionsMap.set('arkts://pages/toOriginPage',
      () => this.navPathStack.pushPath({ name: Constants.ORIGIN_PAGE }));
    this.functionsMap.set('third-party://pages/toThirdPage', () => {
      this.context.openLink('appScheme://www.test.com:80/path1').then(() => {
        Logger.info('Succeeded in starting FuncAbility');
      }).catch((err: BusinessError) => {
        Logger.error(`Failed to start FuncAbility. Code is ${err.code}, message is ${err.message}`);
      });
    });
    this.functionsMap.set('network://pages/toSystemApp', () => {
      const want: Want = {
        bundleName: 'com.huawei.hmos.settings',
        abilityName: 'com.huawei.hmos.settings.MainAbility',
        uri: 'wifi_entry',
      };
      this.context.startAbility(want).then(() => {
        Logger.info(`Successfully to startAbility. `);
      }).catch((err: BusinessError) => {
        Logger.error(`Failed to startAbility. Code: ${err.code}, message: ${err.message}`);
      });
    });
    this.functionsMap.set('appgallery://pages/toMarketDetailPage', () => {
      this.context.openLink('https://appgallery.huawei.com/app/detail?id=com.huawei.hmsapp.appgallery')
        .catch((error: BusinessError<void>) => {
          hilog.error(0x0000, 'testTag', 'Execution failed, code = %{public}d, message = %{public}s',
            error.code, error.message);
        });
    });
    this.functionsMap.set('cross-device://pages/crossDevice', () => {
      try {
        let remoteDeviceId = this.getRemoteDeviceId();
        if (!remoteDeviceId) {
          this.getUIContext().getPromptAction().showToast({
            message: $r('app.string.not_found_toast'),
            duration: 2000
          })
          return;
        }
        const want: Want = {
          deviceId: remoteDeviceId,
          bundleName: this.bundleName,
          abilityName: 'EntryAbility',
          moduleName: 'entry',
        }
        this.context.startAbility(want);
      } catch (err) {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.not_found_toast'),
          duration: 2000
        })
        Logger.error(`err: ${err.code}  ${err.message}`);
      }
    })
  }

  build() {
    Navigation(this.navPathStack) {
      Column() {
        Web({
          src: $rawfile(this.la == Constants.ENGLISH_LANGUAGE ? 'index_en.html' : 'index_cn.html'),
          controller: this.controller
        })
          .zoomAccess(false)
          .onLoadIntercept((event) => {
            const url: string = event.data.getRequestUrl();
            const callFunc = this.functionsMap.get(url) as () => void;
            callFunc && callFunc();
            return !regex.test(url);
          })
      }
    }
    .hideTitleBar(true)
    .navDestination(this.PageMap)
    .mode(NavigationMode.Stack)
  }
}
