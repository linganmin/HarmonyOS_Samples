/*
 *   Copyright (c) 2024 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

import {
  HMDefaultGlobalAnimator,
  HMRouterMgr,
  IHMAnimator,
  OpacityOption,
  ScaleOption,
  TemplateService,
  TranslateOption
} from '@hadss/hmrouter';
import { SelectAnimatorItem } from '../common/utils/SelectAnimatorItem';
import { MineContent } from './MineContent';
import { MineConstants } from '../common/constants/MineConstants'

/**
 * 最佳实践：转场动效场景
 */
@Component
export struct AnimatorTransition {
  @State selectIndex: number = 0;
  @State arr: SelectAnimatorItem[] = [
    new SelectAnimatorItem($r('app.media.left_to_right'), MineConstants.PERSONALIZED_ANIMATION_TYPE1),
    new SelectAnimatorItem($r('app.media.right_to_left'), MineConstants.PERSONALIZED_ANIMATION_TYPE2),
    new SelectAnimatorItem($r('app.media.scale'), MineConstants.PERSONALIZED_ANIMATION_TYPE3)
  ];
  @State isSelectWithSystem: boolean = false;
  @State isSelectCustomAnimation: boolean = false;
  @State translateOption: TranslateOption = new TranslateOption();
  @State scaleOption: ScaleOption = new ScaleOption();
  @State opacityOption: OpacityOption = new OpacityOption();
  @LocalStorageLink('system') system: string = '';
  private ndId: string = '';
  private nvId: string = '';

  setIsSelectWithSystem(isSelect: boolean) {
    this.isSelectWithSystem = isSelect;
    AppStorage.setOrCreate('isSelectWithSystem', this.isSelectWithSystem);
  }

  setIsSelectCustomAnimation(isSelect: boolean) {
    this.isSelectCustomAnimation = isSelect;
    AppStorage.setOrCreate('isSelectCustomAnimation', this.isSelectCustomAnimation);
  }

  aboutToAppear(): void {
    this.nvId = this.queryNavigationInfo()?.navigationId!;
    TemplateService.aboutToAppear(this.nvId, 'animatorTransition', false, this.translateOption, this.scaleOption,
      this.opacityOption);
    if (AppStorage.get('isSelectWithSystem') !== undefined) {
      this.isSelectWithSystem = AppStorage.get('isSelectWithSystem') as boolean;
    }
    if (AppStorage.get('isSelectCustomAnimation') !== undefined) {
      this.isSelectCustomAnimation = AppStorage.get('isSelectCustomAnimation') as boolean;
    }
    if (AppStorage.get('selectIndex') !== undefined) {
      this.selectIndex = AppStorage.get('selectIndex') as number;
    }
  }

  aboutToDisappear(): void {
    TemplateService.aboutToDisappear(this.nvId, MineContent.jumpPageUrl, this.ndId);
  }

  build() {
    // custom NavDestination
    NavDestination() {
      Column() {
        Text(MineConstants.MINE_ANIMATION_CONTENT)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor($r('app.color.animator_text_font_color'))
          .margin(10);
        Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Text(MineConstants.MINE_ANIMATION_TYPE2)
            .fontWeight(FontWeight.Bold);
          Toggle({ type: ToggleType.Switch, isOn: this.isSelectWithSystem })
            .width(36)
            .height(20)
            .selectedColor($r('app.color.animator_select_color'))
            .switchPointColor($r('app.color.animator_switch_point_color'))
            .onClick(() => {
              this.setIsSelectWithSystem(!this.isSelectWithSystem);
              if (this.isSelectWithSystem && this.isSelectCustomAnimation) {
                this.setIsSelectCustomAnimation(false);
              }
              if (this.isSelectWithSystem) {
                this.system = MineConstants.MINE_ANIMATION_TYPE2;
              } else if (this.isSelectCustomAnimation) {
                this.system = MineConstants.MINE_ANIMATION_TYPE3;
              } else {
                this.system = MineConstants.MINE_ANIMATION_TYPE1;
              }
              HMRouterMgr.unRegisterGlobalAnimator('mainNavigationId', 'standard');
              HMRouterMgr.unRegisterGlobalAnimator('mainNavigationId', 'dialog');
            })
            .id('systemAnimationButton');
        }
        .width('95%')
        .height(60)
        .margin(10)
        .padding(10)
        .backgroundColor($r('app.color.animator_flex_background_color'))
        .borderRadius(15);

        Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          Text(MineConstants.MINE_ANIMATION_TYPE3)
            .fontWeight(FontWeight.Bold);
          Toggle({ type: ToggleType.Switch, isOn: this.isSelectCustomAnimation })
            .width(36)
            .height(20)
            .selectedColor($r('app.color.animator_select_color'))
            .switchPointColor($r('app.color.animator_switch_point_color'))
            .onClick(() => {
              this.setIsSelectCustomAnimation(!this.isSelectCustomAnimation);
              if (this.isSelectCustomAnimation && this.isSelectWithSystem) {
                this.setIsSelectWithSystem(false);
              }
              if (this.isSelectWithSystem) {
                this.system = MineConstants.MINE_ANIMATION_TYPE2;
              } else if (this.isSelectCustomAnimation) {
                this.system = MineConstants.MINE_ANIMATION_TYPE3;
              } else {
                this.system = MineConstants.MINE_ANIMATION_TYPE1;
              }
            })
            .id('customAnimationButton');
        }
        .width('95%')
        .height(60)
        .margin({ left: 10, right: 10 })
        .padding(10)
        .backgroundColor($r('app.color.animator_flex_background_color'))
        .borderRadius(15);

        Column() {
          Text(MineConstants.PERSONALIZED_ANIMATION_TITLE)
            .fontColor($r('app.color.animator_text_font_color'))
            .margin(15);

          Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
            Row() {
              ForEach(this.arr, (item: SelectAnimatorItem, index: number) => {
                Flex({
                  direction: FlexDirection.Column,
                  justifyContent: FlexAlign.Center,
                  alignItems: ItemAlign.Center
                }) {
                  Row() {
                    Image(item.getImageUrl())
                      .objectFit(ImageFit.ScaleDown);
                  }
                  .backgroundColor($r('app.color.animator_row_background_color'))
                  .borderRadius(10)
                  .border(this.selectIndex === index ? { width: 1, color: $r('app.color.animator_select_color') } :
                    { width: 0, color: Color.Transparent })
                  .width(60)
                  .height(60);

                  Text(item.getDirectionText())
                    .margin({ top: 10 })
                    .fontColor(this.selectIndex === index ? $r('app.color.animator_select_color') :
                    $r('app.color.animator_text_not_select_color'))
                }
                .onClick(() => {
                  this.selectIndex = index;
                  AppStorage.setOrCreate('selectIndex', this.selectIndex);
                  if (this.selectIndex === 0) {
                    let effect: IHMAnimator.Effect = new IHMAnimator.Effect({
                      direction: IHMAnimator.Direction.LEFT_TO_RIGHT,
                      opacity: { opacity: 0.5 }
                    });
                    HMRouterMgr.registerGlobalAnimator('mainNavigationId', 'standard', effect.toAnimator());
                    HMRouterMgr.registerGlobalAnimator('mainNavigationId', 'dialog', effect.toAnimator());
                  } else if (this.selectIndex === 1) {
                    let effect: IHMAnimator.Effect = HMDefaultGlobalAnimator.STANDARD_ANIMATOR;
                    HMRouterMgr.registerGlobalAnimator('mainNavigationId', 'standard', effect.toAnimator());
                    HMRouterMgr.registerGlobalAnimator('mainNavigationId', 'dialog', effect.toAnimator());
                  } else if (this.selectIndex === 2) {
                    // [Start hm_animator]
                    let effect: IHMAnimator.Effect = new IHMAnimator.Effect({
                      scale: {
                        centerX: '50%',
                        centerY: '50%',
                        x: 0.5,
                        y: 0.5
                      },
                      opacity: { opacity: 0.3 }
                    });
                    // [End hm_animator]
                    HMRouterMgr.registerGlobalAnimator('mainNavigationId', 'standard', effect.toAnimator());
                    HMRouterMgr.registerGlobalAnimator('mainNavigationId', 'dialog', effect.toAnimator());
                  }
                })
                .margin({ right: 10 });
              }, (item: SelectAnimatorItem, index: number) => JSON.stringify(item) + index);
            };
          }
          .margin({ left: 10 })
          .height('15%');
        }.visibility(this.isSelectCustomAnimation ? Visibility.Visible : Visibility.Hidden);
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.tab_background_color'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
    }
    .translate(this.translateOption)
    .scale(this.scaleOption)
    .opacity(this.opacityOption.opacity)
    .title('转场动画设置')
    .hideTitleBar(false)
    .onReady((navContext: NavDestinationContext) => {
      this.ndId = navContext.navDestinationId!;
      TemplateService.onReady(this.nvId, 'animatorTransition', navContext);
    });
  }
}

@Builder
export function animatorTransitionBuilder() {
  AnimatorTransition();
}