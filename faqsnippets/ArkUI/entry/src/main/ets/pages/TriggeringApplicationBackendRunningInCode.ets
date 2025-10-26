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
* FAQ:如何在代码中触发应用后台运行
*/

// [Start triggering_application_backend_running_in_code]
import { window } from '@kit.ArkUI';

@Component
export struct BackgroundExecution {
  @State message: string = 'Run in the background';

  build() {
    Column() {
      Button(this.message)
        .width('40%')
        .onClick(() => {
          let windowStage = AppStorage.get('context') as window.WindowStage;
          if (windowStage) {
            // It can be minimized when it is the main window and hidden when it is a sub-window.
            windowStage.getMainWindowSync().minimize();
          }
        })
    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}
// [End triggering_application_backend_running_in_code]