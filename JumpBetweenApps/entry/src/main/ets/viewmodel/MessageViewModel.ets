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

import { bundleManager, common, OpenLinkOptions, Want } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

let getUIContext: UIContext

export class MessageViewModel {
  private messages: Message[] = [];

  constructor(UIContext: UIContext) {
    this.messages.push(new Message('001', pullUpAppGallery));
    this.messages.push(new Message('002', pullUpNavigationApp));
    this.messages.push(new Message('003', pullUpThirdApp));
    getUIContext = UIContext
  }

  public getMessages(): Message[] {
    return this.messages;
  }
}

export class Message {
  private id: string;
  private callback: Function;

  constructor(id: string, callback: Function) {
    this.id = id;
    this.callback = callback;
  }

  public getId(): string {
    return this.id;
  }

  public getCallBack(): Function {
    return this.callback;
  }
}

export const pullUpSystemSetting = (context: common.UIAbilityContext) => {
  const want: Want = {
    bundleName: 'com.huawei.hmos.settings',
    abilityName: 'com.huawei.hmos.settings.MainAbility',
    uri: 'wifi_entry',
  };
  context.startAbility(want);
}

// [Start pull_up_app_gallery]
const pullUpAppGallery = (context: common.UIAbilityContext) => {
  const link = 'https://appgallery.huawei.com/app/detail?id=com.huawei.hmsapp.books';
  context.openLink(link);
}
// [End pull_up_app_gallery]

// [Start pull_up_third_app]
const pullUpThirdApp = (context: common.UIAbilityContext) => {
  // Developers are required to replace it with the corresponding App Linking address.
  const link = 'https://www.huawei.com';
  const openLinkOptions: OpenLinkOptions = {
    appLinkingOnly: false,
    parameters: {
      targetPage: 'Goods'
    }
  };
  context.openLink(link, openLinkOptions, (err: BusinessError, result: common.AbilityResult) => {
    if (err) {
      getUIContext.getPromptAction().showToast({ message: $r('app.string.error_toast') });
      return;
    }
    console.info(`startAbilityForResult succeed, result is ${JSON.stringify(result)}`);
    if (result.resultCode === 200) {
      getUIContext.getPromptAction().showToast({ message: $r('app.string.payment_status') })
    }
  })
}
// [End pull_up_third_app]

// [Start pull_up_navigation_app]
const pullUpNavigationApp = (context: common.UIAbilityContext) => {
  const wantParam: Record<string, Object> = {
    'sceneType': 1,
    'destinationLatitude': 32.060844,
    'destinationLongitude': 118.78315,
    'destinationName': 'xx市xx路xx号',
    'destinationPoiIds': {
      1: '111111111111',
      2: '222222222222'
    } as Record<number, string>,
    'originName': 'xx市xx公园',
    'originLatitude': 31.060844,
    'originLongitude': 120.78315,
    'originPoiIds': {
      1: '333333333333',
      2: '444444444444'
    } as Record<number, string>,
    'vehicleType': 0
  };
  const abilityStartCallback: common.AbilityStartCallback = {
    onError: (code: number, name: string, message: string) => {
      console.log(`onError code ${code} name: ${name} message: ${message}`);
    },
    onResult: (result) => {
      console.log(`onResult result: ${JSON.stringify(result)}`);
    }
  }
  context.startAbilityByType('navigation', wantParam, abilityStartCallback);
}
// [End pull_up_navigation_app]