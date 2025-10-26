/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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

import { fileManagerService } from '@kit.FileManagerServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { picker } from '@kit.CoreFileKit'
import { PromptAction } from '@kit.ArkUI';

const domain = 0x0000;
const tag = 'deleteTag';

@Entry
@Component
struct Index {
  build() {
    Column() {
      Button($r('app.string.select_files_to_delete'))
        .onClick(async () => {
          try {
            let context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
            let promptAction: PromptAction = this.getUIContext().getPromptAction();
            let selectOptions: picker.DocumentSelectOptions = new picker.DocumentSelectOptions();
            selectOptions.defaultFilePathUri = 'file://docs/storage/Users/currentUser';
            let documentPicker = new picker.DocumentViewPicker(context);
            documentPicker.select(selectOptions, async (err: BusinessError, documentSelectResult: Array<string>) => {
              if (err) {
                hilog.error(domain, tag, 'DocumentViewPicker.select failed with err: ' + JSON.stringify(err));
                return;
              }
              try {
                for (let uri of documentSelectResult) {
                  hilog.info(domain, tag, 'deleteToTrash start');
                  const ret: string = await fileManagerService.deleteToTrash(uri);
                  hilog.info(domain, tag, 'deleteToTrash end, ret:%{public}', ret);
                }
                promptAction.showToast({
                  message: `delete success`,
                  duration: 5
                })
              } catch (error) {
                hilog.error(domain, tag, `error.code: ${error.code}, error.message: ${error.message}`);
                promptAction.showToast({
                  message: `delete failed, error.code: ${error.code}, error.message: ${error.message}`,
                  duration: 5
                })
              }
            });
          } catch (error) {
            let err: BusinessError = error as BusinessError;
            hilog.error(domain, tag, 'DocumentViewPicker failed with err: ' + JSON.stringify(err));
          }
        })
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}