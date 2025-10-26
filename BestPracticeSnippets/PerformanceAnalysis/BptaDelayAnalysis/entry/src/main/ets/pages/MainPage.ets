/*
* Copyright (C) 2025 Huawei Device Co., Ltd.
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

import { AudioPlayerService } from '../components/AudioPlayerService';
import { AudioPlayerStatus } from '../components/AudioPlayerStatus';
import { ContinueModel } from '../components/ContinueModel';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0;

  build() {
    Column() {
      // [Start tabs]
      // products\phone\src\main\ets\pages\MainPage.ets
      Tabs({ index: this.currentIndex }) {
        // [StartExclude tabs]
        TabContent() {
          Button('tabBar1')
            .width('100%')
            .onClick(() => {
              this.getUIContext()
                .getRouter()
                .pushUrl({
                  url: 'pages/page1'
                })
                .then(() => {
                  hilog.info(0x000, 'testTag', `pushUrl succeed.`)
                })
                .catch((err: BusinessError) => {
                  hilog.warn(0x000, 'testTag', `pushUrl failed. code=${err.code}, message=${err.message}`);
                })
            })
        }
        .tabBar('tabBar1')

        TabContent() {
          Text('tabBar2 content')
        }
        .tabBar('tabBar2')
        // [EndExclude tabs]
      }
      .layoutWeight(1)
      .scrollable(false)
      .onChange((index) => {
        this.currentIndex = index;
        ContinueModel.getInstance().data.mainTabIndex = index;
        if (AppStorage.get('audioPlayerStatus') !== AudioPlayerStatus.IDLE) {
          AudioPlayerService.getInstance().stop().then(() => {
            AudioPlayerService.destroy();
          });
        }
      })
      // [End tabs]
    }
    .height('100%')
    .width('100%')
    .padding({ left: 12, right: 12 })
  }
}