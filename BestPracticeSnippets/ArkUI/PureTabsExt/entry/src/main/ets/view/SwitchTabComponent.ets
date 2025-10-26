/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
import { AbilityConstant, Configuration } from "@kit.AbilityKit";
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from "@kit.PerformanceAnalysisKit";

// [Start custom_switch_tab]
@Component
export default struct SwitchTabComponent {
  // [StartExclude custom_switch_tab]
  @State tabItems: string[] = [];
  // [EndExclude custom_switch_tab]
  @State currentIndex: number = 0;
  private tabController: TabsController = new TabsController();

  // [StartExclude custom_switch_tab]
  async aboutToAppear(): Promise<void> {
    this.updateTabItems();
    this.subscribeSystemLanguageUpdate();
  }

  private async updateTabItems() {
    await this.getUIContext()
      .getHostContext()?.resourceManager.getStringArrayValue($r('app.strarray.switch_tabs_items'))
      .then((strarray: string[]) => {
        this.tabItems = strarray;
      })
      .catch((err: BusinessError) => {
        hilog.error(0x000, 'testTag', `getStringArrayValue failed, code=${err.code}, message=${err.message}`)
      })
  }

  subscribeSystemLanguageUpdate() {
    let thisComponent = this;
    let systemLanguage: string | undefined;

    this.getUIContext().getHostContext()?.getApplicationContext().on('environment', {
      async onConfigurationUpdated(newConfig: Configuration) {
        if (systemLanguage !== newConfig.language) {
          thisComponent.updateTabItems();
          systemLanguage = newConfig.language;
        }
      },
      onMemoryLevel: (level: AbilityConstant.MemoryLevel): void => {
        // do nothing
      }
    });
  }

  // [EndExclude custom_switch_tab]

  build() {
    Column() {
      Row() {
        Button('Previous Tab')
          .onClick(() => {
            this.tabController.changeIndex((this.currentIndex + 3) % 4); // call tabController.changeIndex() to switch tab
          })
           // [StartExclude custom_switch_tab]
          .width(158)
          .height(40)
          .margin({top:10, right: 10 })
          .backgroundColor('rgba(0,0,0,0.05)')
          .fontColor('#0A59F7')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          // [EndExclude custom_switch_tab]

        Button('Next Tab')
          .onClick(() => {
            this.currentIndex = (this.currentIndex + 1) % 4; // change currentIndex to switch tab
          })
           // [StartExclude custom_switch_tab]
          .width(158)
          .height(40)
          .margin({top:10, left: 10 })
          .backgroundColor('rgba(0,0,0,0.05)')
          .fontColor('#0A59F7')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          // [EndExclude custom_switch_tab]
      }

      Tabs({
        controller: this.tabController,
        index: $$this.currentIndex // use $$ for two-way data binding
      }) {
        // [StartExclude custom_switch_tab]
        ForEach(this.tabItems, (item: string, index: number) => {
          TabContent() {
            Column() {
              Text(`${item}`)
            }
            .width('100%')
            .height('70%')
            .justifyContent(FlexAlign.Center)
          }.tabBar(item).align(Alignment.Top)
        })
        // [EndExclude custom_switch_tab]
      }
    }

  }
}

// [End custom_switch_tab]