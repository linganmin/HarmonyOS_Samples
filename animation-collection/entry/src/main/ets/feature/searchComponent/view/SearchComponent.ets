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

import { curves, display, ShowDialogSuccessResponse } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { NavDestinationItem } from '../../../viewmodel/NavDestinationItem';
import { Constants } from '../common/Constants';
import Logger from '../../../common/Logger';
import { hilog } from '@kit.PerformanceAnalysisKit';

// Persistent data storage.
PersistentStorage.persistProp('searchHistoryData', []);

@Component
export struct SearchComponent {
  // Search raw data.
  @StorageLink('listData') searchListData: NavDestinationItem[] | undefined = AppStorage.get('listData');
  // Search history array.
  @StorageLink('searchHistoryData') searchHistoryData: NavDestinationItem[] = [];
  @StorageLink('context') UIContext: common.UIAbilityContext | undefined = AppStorage.get('context');
  @Consume('NavPathStack') pageInfos: NavPathStack;
  // Search inputs.
  @State searchContext: string = '';
  // Display flag on search page.
  @State isSearchPageShow: boolean = false;
  // Implicit shared element transition ID in the component.
  @State geometryId: string = '';
  @State searchNewListData: NavDestinationItem[] = [];
  @State screenWidth: number = 0;

  aboutToAppear(): void {
    display.getAllDisplays((err: BusinessError, data: Array<display.Display>) => {
      this.screenWidth = data[0].width;
      const errCode: number = err.code;
      if (errCode) {
        Logger.error('testTag', 'Failed to obtain all the display objects. Code: ' + JSON.stringify(err) ?? '');
        return;
      }
      Logger.info('testTag', 'Succeeded in obtaining all the display objects. Data: ' + JSON.stringify(data));
    });
  }

  /**
   * Search Logic
   * @param value: Content entered in the text box.
   */
  searchFunc(value: string) {
    let newListData: NavDestinationItem[] = [];
    if (this.searchListData !== undefined) {
      for (let i = 0; i < this.searchListData.length; i++) {
        // Query the entered characters through includes.
        if (this.searchListData[i].detail.toLowerCase().includes(value.toLowerCase())) {
          newListData.push(this.searchListData[i]);
        }
      }
    }
    // Determine whether there is an input value.
    if (value.length !== 0) {
      this.searchNewListData = newListData;
    } else {
      this.searchNewListData = [];
    }
  }

  /**
   * 1.Search box into the search page this.getUIContext().animateTo Explicit animation.
   * 2.Two search boxes are bound to the same geometryId.
   */
  private onSearchClicked(): void {
    this.geometryId = 'search';
    this.getUIContext().animateTo({
      duration: Constants.CLICK_SEARCH_ANIMATION_DURATION,
      // Constructs an interpolator spring curve object to generate an animation curve from 0 to 1.
      curve: curves.interpolatingSpring(
        Constants.ANIMATION_CURVE_VELOCITY,
        Constants.ANIMATION_CURVE_MASS,
        Constants.ANIMATION_CURVE_STIFFNESS,
        Constants.ANIMATION_CURVE_DAMPING
      ),
      onFinish: () => {
        this.geometryId = '';
      }
    }, () => {
      this.isSearchPageShow = true;
    })
  }

  private onArrowClicked(): void {
    this.geometryId = 'search';
    this.getUIContext().animateTo({
      curve: curves.interpolatingSpring(
        Constants.ANIMATION_CURVE_VELOCITY,
        Constants.ANIMATION_CURVE_MASS,
        Constants.ANIMATION_CURVE_STIFFNESS,
        Constants.ANIMATION_CURVE_DAMPING
      ),
      onFinish: () => {
        this.geometryId = '';
      }
    }, () => {
      this.searchNewListData = [];
      this.isSearchPageShow = false;
    })
  }

  // Click Prompt List/History to enter the example page.
  private onItemClicked(): void {
    this.geometryId = 'search';
    this.getUIContext().animateTo({
      curve: Curve.Ease,
      duration: Constants.TO_EXAMPLE_PAGE_DURATION,
      onFinish: () => {
        this.geometryId = '';
      }
    }, () => {
      this.searchNewListData = [];
      this.isSearchPageShow = false;
    })
  }

  @Builder
  searchPage() {
    Column() {
      Row() {
        Image($r('app.media.ic_public_back'))
          .width($r('app.string.search_back_size_margin'))
          .onClick(() => {
            this.onArrowClicked();
          })
          // The transition attribute is used to configure transition parameters.
          // The transition effect is displayed when a component is inserted or deleted.
          .transition(TransitionEffect.asymmetric(
            TransitionEffect.opacity(Constants.TRANSITION_OPACITY)
              .animation({
                curve: curves.cubicBezierCurve(
                  Constants.ANIMATION_CURVE_X1,
                  Constants.ANIMATION_CURVE_Y1,
                  Constants.ANIMATION_CURVE_X2,
                  Constants.ANIMATION_CURVE_Y2
                ),
                duration: Constants.TRANSITION_ANIMATION_DURATION,
                delay: Constants.ANIMATION_DELAY
              }),
            TransitionEffect.opacity(Constants.TRANSITION_OPACITY)
              .animation({
                curve: curves.cubicBezierCurve(
                  Constants.ANIMATION_CURVE_X1,
                  Constants.ANIMATION_CURVE_Y1,
                  Constants.ANIMATION_CURVE_X2,
                  Constants.ANIMATION_CURVE_Y2
                ),
                duration: Constants.TRANSITION_ANIMATION_DURATION
              })
          ))
        Search({ value: this.searchContext, placeholder: $r('app.string.search_placeholder') })
          .defaultFocus(true)
          .backgroundColor($r('app.string.search_background_color'))
          .onChange((value: string) => {
            this.searchFunc(value);
          })
          .borderRadius($r('app.string.main_page_top_borderRadius'))
          .geometryTransition(this.geometryId, { follow: true })
          .width(this.getUIContext().px2vp(this.screenWidth) - Constants.SEARCH_WIDTH)
          .height($r('app.string.search_height'))
          .margin({ left: $r('app.string.search_back_size_margin') })
          .backgroundColor($r('app.string.search_background_color'))
      }
      .alignSelf(ItemAlign.Start)

      // Search history.
      Column() {
        Row() {
          Text($r('app.string.search_history'))
            .fontSize($r('app.string.search_history_font_size2'))
            .fontWeight(FontWeight.Bold)
          Blank()
          Image($r('app.media.ic_public_delete'))
            .width($r('app.string.search_history_delete_size'))
            .onClick(() => {
              this.getUIContext()
                .getPromptAction()
                .showDialog({
                  message: $r('app.string.search_delete_title'),
                  alignment: DialogAlignment.Center,
                  buttons: [
                    {
                      text: $r('app.string.delete_back'),
                      color: $r('app.string.button_text_color')
                    },
                    {
                      text: $r('app.string.delete_ok'),
                      color: $r('app.string.button_text_color')
                    }
                  ]
                })
                .then((data: ShowDialogSuccessResponse) => {
                  if (data.index === 1) {
                    this.searchHistoryData = [];
                  }
                })
                .catch((error: BusinessError) => {
                  hilog.error(0x0000, 'SearchComponent',
                    `showDialog failed. code=${error.code}, message=${error.message}`);
                })
            })
        }
        .height($r('app.string.search_history_delete_size'))
        .width($r('app.string.full_size'))
        .margin({ top: $r('app.string.search_history_text_padding_margin1') })

        // Search history content area.
        Scroll() {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.searchHistoryData, (item: NavDestinationItem) => {
              Column() {
                Text(item.detail)
                  .fontSize($r('app.string.search_history_font_size3'))
                  .backgroundColor($r('app.string.search_list_text_color'))
                  .padding($r('app.string.search_history_text_padding_margin3'))
                  .borderRadius($r('app.string.main_page_top_borderRadius'))
              }
              .margin({ top: $r('app.string.search_history_text_padding_margin4') })
              .padding({ right: $r('app.string.search_history_text_padding_margin2') })
              .onClick(() => {
                this.onItemClicked();
                // DynamicsRouter.push(item.routerInfo, item.param);
                this.pageInfos.pushPathByName(item.name, '');
                this.searchHistoryData.map((historyItem, index) => {
                  if (historyItem === item) {
                    this.searchHistoryData.unshift(this.searchHistoryData.splice(index, 1)[0])
                  }
                })
              })
            }, (item: NavDestinationItem) => JSON.stringify(item))
          }
          .margin({ top: $r('app.string.search_history_text_padding_margin3') })
        }
        .width($r('app.string.full_size'))
      }
      .visibility(this.searchHistoryData.length === 0 || this.searchContext.length !== 0 ||
        this.searchNewListData.length !== 0 ? Visibility.None : Visibility.Visible)
      .alignItems(HorizontalAlign.Start)

      List() {
        ForEach(this.searchNewListData, (item: NavDestinationItem) => {
          ListItem() {
            Column() {
              Row() {
                Image($r('app.media.search'))
                  .width($r('app.string.search_list_image_width'))
                Text(item.detail)
                  .fontSize($r('app.string.search_history_font_size2'))
                  .margin({ left: $r('app.string.search_history_text_padding_margin2') })
              }

              Divider()
                .width($r('app.string.full_size'))
                .height($r('app.string.search_divider_height'))
                .margin({ top: $r('app.string.search_history_text_padding_margin1') })
            }
            .width($r('app.string.full_size'))
            .alignItems(HorizontalAlign.Start)
          }
          .width($r('app.string.full_size'))
          .margin({ top: $r('app.string.search_history_text_padding_margin1') })
          .onClick(() => {
            if (!this.searchHistoryData.includes(item)) {
              this.searchHistoryData.unshift(item);
            } else {
              this.searchHistoryData.map((historyItem, index) => {
                if (historyItem === item) {
                  this.searchHistoryData.unshift(this.searchHistoryData.splice(index, 1)[0])
                }
              })
            }
            this.onItemClicked();
            // Invoke dynamic routing methods to implement page redirection.
            this.pageInfos.pushPathByName(item.name, '');
          })
        }, (item: NavDestinationItem) => JSON.stringify(item))
      }
      .edgeEffect(EdgeEffect.Spring)
      .sticky(StickyStyle.Header)
      .chainAnimation(false)
      .transition({ opacity: Constants.TRANSITION_OPACITY })
      .scrollBar(BarState.Off)
    }
    .transition(TransitionEffect.opacity(Constants.TRANSITION_OPACITY))
    .backgroundColor(Color.White)
    .padding({
      left: $r('app.string.main_page_padding'),
      right: $r('app.string.main_page_padding'),
      top: $r('app.string.main_page_padding_top')
    })
    .width($r('app.string.full_size'))
    .height($r('app.string.full_size'))
  }

  build() {
    // Top search box.
    Column() {
      Search({ placeholder: $r('app.string.search_placeholder') })
        .focusOnTouch(false)
        .focusable(false)
        .enableKeyboardOnFocus(false)
        .backgroundColor($r('app.string.search_background_color'))
        .width($r('app.string.width_ninety_percent'))
        .height($r('app.string.search_height'))
        .borderRadius($r('app.string.main_page_top_borderRadius'))
        .onClick(() => {
          this.onSearchClicked();
        })
        .geometryTransition(this.geometryId, {
          follow: true
        })// Transition animation of the search box. cubicBezierCurve indicates the third-order Bézier curve animation.
        .transition(TransitionEffect.OPACITY.animation({
          duration: Constants.TRANSITION_ANIMATION_DURATION,
          curve: curves.cubicBezierCurve(
            Constants.ANIMATION_CURVE_X1,
            Constants.ANIMATION_CURVE_Y1,
            Constants.ANIMATION_CURVE_X2,
            Constants.ANIMATION_CURVE_Y2
          )
        }))
        .backgroundColor($r('app.string.search_background_color'))
        .borderRadius($r('app.string.main_page_top_borderRadius'))
    }
    .width($r('app.string.full_size'))
    .borderRadius($r('app.string.main_page_top_borderRadius'))
    .bindContentCover(this.isSearchPageShow, this.searchPage(), {
      modalTransition: ModalTransition.NONE,
      onDisappear: () => {
        this.onArrowClicked();
        this.searchContext = '';
      }
    })
    .alignItems(HorizontalAlign.Center)
  }
}