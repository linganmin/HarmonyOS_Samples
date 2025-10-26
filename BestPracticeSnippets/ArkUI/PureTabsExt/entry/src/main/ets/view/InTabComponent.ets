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
import { AbilityConstant,Configuration } from "@kit.AbilityKit";
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from "@kit.PerformanceAnalysisKit";

// [Start tabs_bar_translate]
@Component
export default struct InTabComponent {
  // [StartExclude tabs_bar_translate]
  @State private tabItems: string[] = [];
  isFadingEdge:boolean = true;
  isSetTabBarTranslateAndOpacity:boolean = true;
  private contents = [1,2,3,4,5,6,7];
  // [EndExclude tabs_bar_translate]
  private subController: TabsController = new TabsController();

  onDidBuild(): void {
    if (this.isSetTabBarTranslateAndOpacity) {
      this.subController.setTabBarTranslate({x:-20,y:30});
      this.subController.setTabBarOpacity(0.5);
    }
  }
  // [StartExclude tabs_bar_translate]
  async aboutToAppear(): Promise<void> {
    this.updateTabItems();
    this.subscribeSystemLanguageUpdate();
  }

  private async updateTabItems(){
    await this.getUIContext().getHostContext()?.resourceManager.getStringArrayValue($r('app.strarray.in_tabs_items'))
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

    this.getUIContext().getHostContext()?.getApplicationContext().on('environment',{
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

  @Builder
  contentBuilder(){
    Flex({ direction: FlexDirection.Column }) {
      Row() {
        Image($r('app.media.avatar'))
          .width(30)
          .borderRadius(15)
        Column() {
          Text($r('app.string.content_item_username'))
            .fontSize(15)
          Text($r('app.string.content_item_publishTime'))
            .fontSize(12)
        }
        .margin({ left: 5 })
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
      }
      .margin(10)

      Column() {
        Text() {
          Span($r('app.string.content_item_title'))
        }
        .fontSize(16)
        .id('title')
        .width(350)
      }
      .margin({ left: 20, bottom: 20, right: 20 })

      Row() {
        Image($r('app.media.content4'))
          .width(111)
          .height(111)
          .margin({left:10, right: 10 })
        Image($r('app.media.content5'))
          .width(111)
          .height(111)
          .margin({ right: 10 })
        Image($r('app.media.content6'))
          .width(111)
          .height(111)
          .margin({ right: 10 })
      }
    }
  }
  // [EndExclude tabs_bar_translate]

  build() {
    // [Start tabs_fading_edge]
    Tabs({controller: this.subController}){
      // [StartExclude tabs_fading_edge]
      // [StartExclude tabs_bar_translate]
      ForEach(this.tabItems, (item: string, index: number) => {
        TabContent(){
          List({ space: 10 }) {
            ForEach(this.contents, (item: number, index: number) => {
              this.contentBuilder()
            })
          }
        }.tabBar(item)
      })
      // [EndExclude tabs_fading_edge]
      // [EndExclude tabs_bar_translate]
    }
    // [StartExclude tabs_bar_translate]
    .fadingEdge(this.isFadingEdge) // true set tab bar edge fade
    // [End tabs_fading_edge]
    .barBackgroundColor($r('app.color.out_tab_bar_background_color'))
    .barHeight(40)
    // [EndExclude tabs_bar_translate]
    .barMode(BarMode.Scrollable)
  }
}
// [End tabs_bar_translate]