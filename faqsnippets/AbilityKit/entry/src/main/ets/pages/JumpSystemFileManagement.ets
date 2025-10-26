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
* FAQ:如何跳转到系统文件管理App界面
*/

// [Start JumpSystemFileManagement]
import { common, OpenLinkOptions } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = '[UIAbilityComponentsOpenLink]';
const DOMAIN_NUMBER: number = 0xFF00;

@Entry
@Component
struct Index {
  @State message: string = '拉起文件管理';
  context = this.getUIContext();

  build() {
    Row() {
      Column() {
        Button(this.message)
          .width('100%')
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            let context: common.UIAbilityContext = this.context.getHostContext() as common.UIAbilityContext;
            let link: string = 'filemanager://openDirectory';
            let openLinkOptions: OpenLinkOptions = {
              parameters: {
                'fileUri': ''
              }
            };
            try {
              context.openLink(link, openLinkOptions)
                .then(() => {
                  hilog.info(DOMAIN_NUMBER, TAG, 'open link success.');
                }).catch((err: BusinessError) => {
                hilog.error(DOMAIN_NUMBER, TAG, `open link failed. Code is ${err.code}, message is ${err.message}`);
              });
            } catch (paramError) {
              hilog.error(DOMAIN_NUMBER, TAG,
                `Failed to start link. Code is ${paramError.code}, message is ${paramError.message}`);
            }
          })
      }
      .padding({ left: 16, right: 16 })
      .width('100%')
    }
    .height('100%')
  }
}
// [End JumpSystemFileManagement]