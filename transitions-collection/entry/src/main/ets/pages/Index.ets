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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { SymbolGlyphModifier } from '@kit.ArkUI';
import Constants from '../common/Constants';
import { ListItemProp } from '../viewmodel/ListItemProp';
import { AnimateCallback, CustomTransition } from '../utils/customtransition/CustomNavigationUtils';

@Entry
@Component
struct Index {
  @State navList: ListItemProp[] = Constants.NavList;
  @Provide('NavPathStack') pageInfos: NavPathStack = new NavPathStack();
  @State isExpand: boolean = false;
  // The name of the page that allows custom transitions.
  private allowedCustomTransitionFromPageNames: string[] =
    ['CardLongTakeTransitionPageOne', 'LeftToRightTransitionPageOne',
      'VideoLongTakeTransitionWithCustomNavigationPageOne',
      'BookFlipLongTakeTransitionPageOne', 'NavigationInteractiveTransitionPageOne'];
  // The name of the page that allows custom transitions.
  private allowedCustomTransitionToPageNames: string[] =
    ['CardLongTakeTransitionPageTwo', 'LeftToRightTransitionPageTwo',
      'VideoLongTakeTransitionWithCustomNavigationPageTwo',
      'BookFlipLongTakeTransitionPageTwo', 'BookFlipLongTakeTransitionPageThree',
      'NavigationInteractiveTransitionPageTwo'
    ];
  @State isEnabled: boolean = true;
  @State endIconModifier: SymbolGlyphModifier =
    new SymbolGlyphModifier($r('sys.symbol.chevron_right')).fontSize('24vp');

  private isCustomTransitionEnabled(fromName: string, toName: string): boolean {
    // Both click and return require custom transitions, so they need to be judged separately.
    if ((this.allowedCustomTransitionFromPageNames.includes(fromName)
      && this.allowedCustomTransitionToPageNames.includes(toName))
      || (this.allowedCustomTransitionFromPageNames.includes(toName)
        && this.allowedCustomTransitionToPageNames.includes(fromName))) {
      return true;
    }
    return false;
  }

  @Builder
  TitleBuilder() {
    Row() {
      Text($r('app.string.EntryAbility_label'))
        .fontColor(Color.Black)
        .width('100%')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
    }
    .height(128)
    .padding({ top: 56 })
    .clip(true)
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  MyMenu(item: ListItemProp[]) {
    Menu() {
      ForEach(item, (menuItem: ListItemProp) => {
        MenuItem({ symbolEndIcon: this.endIconModifier, content: menuItem.title })
          .onClick(() => {
            this.pageInfos.pushPath({ name: menuItem.name }, false);
          })
      }, (menuItem: ListItemProp) => JSON.stringify(menuItem))
    }
  }

  build() {
    Navigation(this.pageInfos) {
      Scroll() {
        Column() {
          this.TitleBuilder()

          ForEach(this.navList, (item: ListItemProp) => {
            Row() {
              Text(item.title)
                .width('100%')
                .fontSize('18fp')
                .fontColor($r('sys.color.mask_secondary'))
            }
            .height(20)

            Column() {
              ForEach(item.children, (itemChild: ListItemProp) => {
                if (itemChild.children) {
                  Column() {
                    Text(itemChild.title)
                      .width('100%')
                      .height(48)
                      .fontWeight(FontWeight.Medium)
                      .padding({ left: 12 })
                      .fontSize(16)
                      .bindMenu(this.MyMenu(itemChild.children))

                    Row()
                      .height(0.5)
                      .backgroundColor('#0D000000')
                      .width('93%')
                  }
                  .onClick(() => {
                    this.pageInfos.pushPath({ name: itemChild.name }, false);
                  })
                } else {
                  Column() {
                    Row() {
                      Text(itemChild.title)
                        .height(48)
                        .fontWeight(FontWeight.Medium)
                        .padding({ left: 12 })
                        .fontSize(16)
                      Blank()
                      Row()
                        .width(10)
                        .height(10)
                        .margin({ right: 20 })
                        .border({
                          width: {
                            top: 2,
                            right: 2
                          },
                          color: '#ccc'
                        })
                        .rotate({ angle: 45 })
                    }
                    .width('100%')

                    Row()
                      .height(0.5)
                      .backgroundColor('#0D000000')
                      .width('93%')
                  }
                  .onClick(() => {
                    this.pageInfos.pushPath({ name: itemChild.name }, false);
                  })
                }
              })
            }
            .margin({
              top: 14,
              bottom: 18
            })
            .borderRadius(18)
            .backgroundColor(Color.White)
          })
        }
        .padding({
          left: 16,
          right: 16
        })
        .width('100%')
      }
      .scrollBar(BarState.Off)
      .scrollable(ScrollDirection.Vertical)
    }
    .mode(NavigationMode.Stack)
    .hideBackButton(true)
    .backgroundColor('#F1F3F5')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .enabled(this.isEnabled)
    .customNavContentTransition((from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation) => {
      if ((!from || !to) || (!from.name || !to.name) || (!from.navDestinationId || !to.navDestinationId)) {
        return undefined;
      }
      let fromParam: AnimateCallback = CustomTransition.getInstance().getAnimateParam(from.navDestinationId);
      let toParam: AnimateCallback = CustomTransition.getInstance().getAnimateParam(to.navDestinationId);
      CustomTransition.getInstance().operation = operation;
      // Follow the hand interaction transition.
      if (CustomTransition.getInstance().isInteractive) {
        let customAnimation: NavigationAnimatedTransition = {
          onTransitionEnd: () => {
            this.isEnabled = true;
            CustomTransition.getInstance().recoverState();
            CustomTransition.getInstance().proxy = undefined;
          },
          transition: (transitionProxy: NavigationTransitionProxy) => {
            CustomTransition.getInstance().proxy = transitionProxy;
            this.isEnabled = false;
            if (fromParam.onInteractive) {
              fromParam.onInteractive();
            }
            if (toParam.onInteractive) {
              toParam.onInteractive();
            }
          },
          isInteractive: true
        };
        return customAnimation;
      }

      // User-defined transition routes are controlled by the from and to names.
      if (!this.isCustomTransitionEnabled(from.name, to.name)) {
        return undefined;
      }

      // For the scene where button A is clicked to go to the custom transition and button B is clicked to go to the default transition,
      // it is necessary to judge whether the animation is registered to decide whether to go to the custom transition.
      // fromPage and toPage registerNavParam do not pass animation parameters, go to the default transition.
      if (!fromParam.animation && !toParam.animation) {
        return undefined;
      }

      // After all judgments are completed, construct customAnimation to the system side call, execute the custom transition animation.
      let customAnimation: NavigationAnimatedTransition = {
        onTransitionEnd: (isSuccess: boolean) => {
          hilog.info(0x0000, 'Index', `current transition result is ${isSuccess}`);
          this.isEnabled = true;
        },
        timeout: 1000,
        transition: (transitionProxy: NavigationTransitionProxy) => {
          this.isEnabled = false;
          if (fromParam.animation) {
            fromParam.animation(transitionProxy);
          }
          if (toParam.animation) {
            toParam.animation(transitionProxy);
          }
        }
      };
      return customAnimation;
    })
  }
}