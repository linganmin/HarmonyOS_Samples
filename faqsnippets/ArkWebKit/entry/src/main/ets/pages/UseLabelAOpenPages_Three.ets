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
* FAQ:在Web组件的H5页面中，如何使用a标签实现打开各种页面
*/

// [Start UseLabelAOpenPages_Three]
import { webview } from '@kit.ArkWeb'
import { common } from '@kit.AbilityKit';
import { Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

function startSettingsInfo(context: common.UIAbilityContext,uri : string): void {
  let want: Want = {
    bundleName: 'com.huawei.hmos.settings',
    abilityName: 'com.huawei.hmos.settings.MainAbility',
    uri: uri
  };
  context.startAbility(want)
    .then(() => {
      // ...
    })
    .catch((err: BusinessError) => {
      console.error(`Failed to startAbility. Code: ${err.code}, message: ${err.message}`);
    });
}
@Entry
@Component
struct WebComponent {
  context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  controller: webview.WebviewController = new webview.WebviewController();
  build() {
    Column() {
      Column() {
        Web({ src: $rawfile('hello.html'), controller: this.controller })
          .onLoadIntercept((event) => {
            if(event){
              let url = event.data.getRequestUrl();
              console.log(url);
              if(url.indexOf('hmos://') === 0){
                startSettingsInfo(this.context,url.substring(7))
                return true;
              }
            }
            return false;
          })
          .width('100%')
          .height('100%')
      }
      .layoutWeight(1)
    }
  }
}
// [End UseLabelAOpenPages_Three]