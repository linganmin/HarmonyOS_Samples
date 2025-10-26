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

import { CommonModifier } from "@kit.ArkUI";
import { EnvironmentCallback, Configuration, AbilityConstant } from "@kit.AbilityKit";
import SelectTabsViewModel from "../viewmodel/SelectTabsViewModel";
import BannerComponent from "./BannerComponent";
import TabItemViewModel from "../viewmodel/TabItemViewModel";
import ContentItemViewModel from "../viewmodel/ContentItemViewModel";
import ContentItemComponent from "./ContentItemComponent";
import SelectTabsComponent from "./SelectTabsComponent";
import InTabsViewModel from "../viewmodel/InTabsViewModel";
import { Constants } from "../common/constant/Constants";

// [Start alignment]
// [Start load_data]
// [Start double_tabs_2]
// [Start select_tabs_2]
// [Start switch_animation_1]
// [Start switch_animation_3]
@Component
export default struct InTabsComponent {
  // [StartExclude alignment]
  // [StartExclude load_data]
  // [StartExclude double_tabs_2]
  // [StartExclude switch_animation_1]
  // [StartExclude switch_animation_3]
  @State selectTabsViewModel: SelectTabsViewModel = new SelectTabsViewModel();
  // [StartExclude select_tabs_2]
  @State inTabsViewModel: InTabsViewModel = new InTabsViewModel();
  // [EndExclude alignment]
  @State tabBarModifier: CommonModifier = new CommonModifier();
  // [StartExclude alignment]
  @State focusIndex: number = 0;
  // [EndExclude switch_animation_1]
  // [EndExclude switch_animation_3]
  @State scaleList: number[] = [];
  @State opacityList: number[] = [];
  // [StartExclude switch_animation_1]
  // [StartExclude switch_animation_3]
  @State showSelectTabsComponent: boolean = false;
  @State selectTabsComponentZIndex: number = -1;
  // [EndExclude double_tabs_2]
  @Link switchNext: boolean;
  // [StartExclude double_tabs_2]
  private ctx: Context = this.getUIContext().getHostContext() as Context;
  // [EndExclude load_data]
  private subsController: TabsController = new TabsController();
  // [StartExclude load_data]
  private tabBarItemScroller: Scroller = new Scroller();
  // [EndExclude switch_animation_3]
  private animateDuration: number = 1000;
  private animateTimeout: number = 1000;
  private customContentTransition: (from: number, to: number) => TabContentAnimatedTransition =
    (from: number, to: number) => {
      let tabContentAnimatedTransition = {
        timeout: this.animateTimeout,
        transition: (proxy: TabContentTransitionProxy) => {
          // start frame
          this.scaleList[from] = 1.0;
          this.scaleList[to] = 0.5;
          this.opacityList[from] = 1.0;
          this.opacityList[to] = 0.5;
          this.getUIContext().animateTo({
            duration: this.animateDuration,
            onFinish: () => {
              proxy.finishTransition();
            }
          }, () => {
            // end frame
            this.scaleList[from] = 0.5;
            this.scaleList[to] = 1.0;
            this.opacityList[from] = 0.5;
            this.opacityList[to] = 1.0;
          });
        }
      } as TabContentAnimatedTransition;
      return tabContentAnimatedTransition;
    };

  // [StartExclude switch_animation_3]
  subscribeSystemLanguageUpdate() {
    let systemLanguage: string | undefined;
    let inTabsViewModel = this.inTabsViewModel;
    let selectTabsViewModel = this.selectTabsViewModel;

    let applicationContext = this.ctx.getApplicationContext();

    let environmentCallback: EnvironmentCallback = {
      async onConfigurationUpdated(newConfig: Configuration) {
        if (systemLanguage !== newConfig.language) {
          await inTabsViewModel.loadContentData(applicationContext);

          await selectTabsViewModel.loadTabs(applicationContext);

          systemLanguage = newConfig.language;
        }
      },
      onMemoryLevel: (level: AbilityConstant.MemoryLevel): void => {
        // do nothing
      }
    };
    applicationContext.on('environment', environmentCallback);
  }

  // [EndExclude alignment]
  // [EndExclude select_tabs_2]
  async aboutToAppear() {
    // [StartExclude alignment]
    // [StartExclude select_tabs_2]
    await this.inTabsViewModel.loadContentData(this.ctx);
    // [EndExclude select_tabs_2]

    await this.selectTabsViewModel.loadTabs(this.ctx);
    // [EndExclude alignment]
    // [StartExclude select_tabs_2]
    this.tabBarModifier.margin({ right: 56 }).align(Alignment.Start);
    // [StartExclude alignment]
    for (let i = 1; i <= this.selectTabsViewModel.selectedTabs.length; i++) {
      this.scaleList.push(1.0);
      this.opacityList.push(1.0);
    }

    this.subscribeSystemLanguageUpdate();
    // [EndExclude alignment]
    // [EndExclude select_tabs_2]
  }
  // [StartExclude alignment]
  // [StartExclude select_tabs_2]
  @Builder
  tabBuilder(index: number, tab: TabItemViewModel) {
    Row() {
      Text(tab.name)
        .fontSize(14)
        .fontWeight(this.focusIndex === index ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.focusIndex === index ? Color.White : $r('app.color.in_tab_bar_text_normal_color'))
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.focusIndex === index
      ? $r('app.color.in_tab_bar_background_active_color')
      : $r('app.color.in_tab_bar_background_inactive_color'))
    .borderRadius(20)
    .height(40)
    .margin({ left: 4, right: 4 })
    .padding({ left: 18, right: 18 })
    .onClick(() => {
      this.focusIndex = index;
      this.subsController.changeIndex(index);
      this.tabBarItemScroller.scrollToIndex(index, true, ScrollAlign.CENTER);
    })
  }

  // [Start select_tabs_4]
  @Builder
  sheetBuilder() {
    //select tabs to show
    SelectTabsComponent({ selectTabsViewModel: this.selectTabsViewModel })
  }
  // [EndExclude alignment]
  // [EndExclude load_data]
  // [EndExclude double_tabs_2]
  build() {
    // [StartExclude alignment]
    // [StartExclude load_data]
    // [StartExclude double_tabs_2]
    // [Start ceiling]
    Scroll() {
      Column() {
        BannerComponent()

        // [Start scroll_and_more]
        Stack({ alignContent: Alignment.TopEnd }) {
          // [StartExclude ceiling]
          Row() {
            Image($r('app.media.more'))
              // [StartExclude scroll_and_more]
              // [StartExclude select_tabs_4]
              .width(20)
              .height(20)
              .margin({ left: 10 })
                // [EndExclude scroll_and_more]
                // [EndExclude select_tabs_4]
              .onClick(() => {
                this.showSelectTabsComponent = !this.showSelectTabsComponent;
              })
          }
          // [StartExclude scroll_and_more]
          // [StartExclude select_tabs_4]
          .margin({ top: 8, bottom: 8, right: 5 })
          .backgroundColor($r('app.color.in_tab_bar_background_inactive_color'))
          .width(40)
          .height(40)
          .borderRadius(20)
          // [EndExclude scroll_and_more]
          // [EndExclude select_tabs_4]
          .zIndex(1)
          .bindSheet($$this.showSelectTabsComponent, this.sheetBuilder(), {
            detents: [SheetSize.MEDIUM, SheetSize.MEDIUM, 500],
            preferType: SheetType.BOTTOM,
            title: { title: $r('app.string.bind_sheet_title') },
            onWillDismiss: (dismissSheetAction: DismissSheetAction) => {
              // update tab when closing modal box
              this.selectTabsViewModel.updateSelectedTabs();
              if (this.selectTabsViewModel.selectedTabs.length > 0) {
                this.subsController.changeIndex(0);
              }
              dismissSheetAction.dismiss();
            }
          })
          // [EndExclude ceiling]
          // [StartExclude select_tabs_4]
          Column() {
            // [EndExclude alignment]
            // [EndExclude load_data]
            // [EndExclude double_tabs_2]
            // [Start double_tabs_3]
            // [Start scroll]
            // [Start select_tabs_3]
            // [Start switch_animation_2]
            // [Start switch_animation_4]
            // [Start bar_position_start]
            Tabs({
              // [StartExclude ceiling]
              // [StartExclude load_data]
              // [StartExclude scroll_and_more]
              // [StartExclude alignment]
              // [StartExclude double_tabs_2]
              // [StartExclude scroll]
              // [StartExclude select_tabs_3]
              // [StartExclude switch_animation_2]
              barPosition: BarPosition.Start,
              // [EndExclude load_data]
              // [StartExclude bar_position_start]
              controller: this.subsController,
              // [EndExclude alignment]
              // [StartExclude load_data]
              barModifier: this.tabBarModifier
              // [EndExclude scroll_and_more]
              // [EndExclude load_data]
              // [EndExclude double_tabs_2]
              // [EndExclude ceiling]
              // [EndExclude scroll]
              // [EndExclude select_tabs_3]
              // [EndExclude switch_animation_2]
              // [EndExclude bar_position_start]
            }) {
              // [StartExclude load_data]
              // [StartExclude scroll_and_more]
              // [StartExclude alignment]
              // [StartExclude double_tabs_3]
              // [StartExclude scroll]
              // [StartExclude switch_animation_4]
              // [StartExclude bar_position_start]
              // bind selected tabs to ui
              ForEach(this.selectTabsViewModel.selectedTabs, (tab: TabItemViewModel, index: number) => {
                if (index === this.selectTabsViewModel.selectedTabs.length - 1) {
                  TabContent() {
                    // [StartExclude double_tabs_2]
                    // [StartExclude select_tabs_3]
                    // [StartExclude switch_animation_2]
                    List({ space: 10 }) {
                      // [StartExclude ceiling]
                      ForEach(this.inTabsViewModel.contentItems, (item: ContentItemViewModel, index: number) => {
                        ContentItemComponent({
                          contentItemViewModel: item,
                        })
                      }, (item: ContentItemViewModel, index: number) => index + '_' + JSON.stringify(item))
                      // [EndExclude ceiling]
                    }
                    // [StartExclude ceiling]
                    .padding({ left: 5, right: 5 })
                    .width(Constants.FULL_WIDTH)
                    .height(Constants.FULL_HEIGHT)
                    .scrollBar(BarState.Off)
                    // [EndExclude ceiling]
                    // set the sliding behavior to move up parent first, and move down self first
                    .nestedScroll({
                      scrollForward: NestedScrollMode.PARENT_FIRST,
                      scrollBackward: NestedScrollMode.SELF_FIRST
                    })
                    // [EndExclude double_tabs_2]
                    // [EndExclude select_tabs_3]
                    // [EndExclude switch_animation_2]
                  }
                  // [StartExclude ceiling]
                  // [StartExclude switch_animation_2]
                  .tabBar(this.tabBuilder(index, tab))
                  // [StartExclude select_tabs_3]
                  .gesture(PanGesture(new PanGestureOptions({ direction: PanDirection.Left })).onActionStart(() => {
                    this.switchNext = true;
                  }))
                  // [StartExclude double_tabs_2]
                  // [EndExclude switch_animation_2]
                  // bind animation properties
                  .opacity(this.opacityList[index])
                  .scale({
                    x: this.scaleList[index], y: this.scaleList[index]
                  })
                  // [EndExclude double_tabs_2]
                  // [EndExclude ceiling]
                  // [EndExclude select_tabs_3]
                } else {
                  // [StartExclude double_tabs_2]
                  // [StartExclude ceiling]
                  // [StartExclude select_tabs_3]
                  // [StartExclude switch_animation_2]
                  TabContent() {
                    List({ space: 10 }) {
                      ForEach(this.inTabsViewModel.contentItems, (item: ContentItemViewModel, index: number) => {
                        ContentItemComponent({
                          contentItemViewModel: item,
                        })
                      }, (item: ContentItemViewModel, index: number) => index + '_' + JSON.stringify(item))
                    }
                    .padding({ left: 5, right: 5 })
                    .width(Constants.FULL_WIDTH)
                    .height(Constants.FULL_HEIGHT)
                    .scrollBar(BarState.Off)
                    .nestedScroll({
                      scrollForward: NestedScrollMode.PARENT_FIRST,
                      scrollBackward: NestedScrollMode.SELF_FIRST
                    })
                  }
                  .tabBar(this.tabBuilder(index, tab))
                  // bind animation properties
                  .opacity(this.opacityList[index])
                  .scale({
                    x: this.scaleList[index], y: this.scaleList[index]
                  })
                  // [EndExclude double_tabs_2]
                  // [EndExclude ceiling]
                  // [EndExclude select_tabs_3]
                  // [EndExclude switch_animation_2]
                }
              }, (tab: TabItemViewModel, index: number) => index + '_' + JSON.stringify(tab))
              // [EndExclude alignment]
              // [EndExclude scroll_and_more]
              // [EndExclude load_data]
              // [EndExclude double_tabs_3]
              // [EndExclude scroll]
              // [EndExclude switch_animation_4]
              // [EndExclude bar_position_start]
            }
            // [End bar_position_start]
            // [StartExclude double_tabs_2]
            // [StartExclude scroll_and_more]
            // [StartExclude alignment]
            // [StartExclude load_data]
            // [StartExclude ceiling]
            // [StartExclude scroll]
            // [End select_tabs_3]
            // [End switch_animation_2]
            // add animation function
            .customContentTransition(this.customContentTransition) // comment out to slide to switch
            // [End switch_animation_4]
            // [End double_tabs_3]
            // [EndExclude scroll_and_more]
            // [EndExclude scroll]
            .barMode(BarMode.Scrollable)
            // [StartExclude scroll_and_more]
            // [StartExclude scroll]
            .width(Constants.FULL_WIDTH)
            .height(Constants.FULL_HEIGHT)
            .barBackgroundColor($r('app.color.out_tab_bar_background_color'))
            .scrollable(true)
            // [EndExclude load_data]
            .onChange((index: number) => {
              this.focusIndex = index;
              this.tabBarItemScroller.scrollToIndex(index, true, ScrollAlign.CENTER);
              // preload the left and right item
              let preloadItems: number[] = [];
              if (index - 1 >= 0) {
                preloadItems.push(index - 1);
              }
              if (index + 1 < this.selectTabsViewModel.selectedTabs.length) {
                preloadItems.push(index + 1);
              }
              this.subsController.preloadItems(preloadItems);
            })
            // [EndExclude scroll_and_more]
            // [EndExclude ceiling]
            // [EndExclude scroll]
            // [End scroll]
            // [StartExclude load_data]
          }
          .width(Constants.FULL_WIDTH)
          .height(Constants.FULL_HEIGHT)
          .backgroundColor($r('app.color.out_tab_bar_background_color'))
          // [EndExclude select_tabs_4]
        }
        // [End scroll_and_more]
      }
    }
    // [End ceiling]
    // [StartExclude select_tabs_4]
    .scrollBar(BarState.Off)
    .width(Constants.FULL_WIDTH)
    .height(Constants.FULL_HEIGHT)
    .backgroundColor($r('app.color.out_tab_bar_background_color'))
    .padding({left:5,right:5})
    // [EndExclude alignment]
    // [EndExclude load_data]
    // [EndExclude double_tabs_2]
    // [EndExclude select_tabs_4]
  }
  // [EndExclude select_tabs_2]
  // [End select_tabs_4]
  // [EndExclude switch_animation_1]
  // [EndExclude switch_animation_3]
}
// [End alignment]
// [End load_data]
// [End double_tabs_2]
// [End select_tabs_2]
// [End switch_animation_1]
// [End switch_animation_3]