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

/**
 * 最佳实践：基于HMRouter路由框架的页面跳转开发实践
 */

import { HMAnimator, HMAnimatorHandle, HMRouter, HMRouterMgr, IHMAnimator,
  OpacityOption,
  ScaleOption,
  TranslateOption } from '@hadss/hmrouter';
import { ConfirmDialog } from '../common/ConfirmDialog';
import { ColorOption } from './PayCard';

@HMAnimator({ animatorName: 'PayCancelDialog' })
export class DialogAnimator implements IHMAnimator {
  effect(enterHandle: HMAnimatorHandle, exitHandle: HMAnimatorHandle): void {
    enterHandle.start((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption, colorOption: ColorOption) => {
      scaleOption.x = 0.5;
      scaleOption.y = 0.5;
      colorOption.color = 'rgba(0, 0, 0, 0)';
    }).finish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption, colorOption: ColorOption) => {
      scaleOption.x = 1;
      scaleOption.y = 1;
      colorOption.color = 'rgba(0, 0, 0, 0.7)';
    }).passiveStart(() => {
    }).passiveFinish(() => {
    });

    exitHandle.start((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption, colorOption: ColorOption) => {
      scaleOption.x = 1;
      scaleOption.y = 1;
      colorOption.color = 'rgba(0, 0, 0, 0.7)';
    }).finish((translateOption: TranslateOption, scaleOption: ScaleOption,
      opacityOption: OpacityOption, colorOption: ColorOption) => {
      scaleOption.x = 0.5;
      scaleOption.y = 0.5;
      colorOption.color = 'rgba(0, 0, 0, 0)';
    }).passiveStart(() => {
    }).passiveFinish(() => {
    });
  }
}

// [Start HMRouter_confirmDialog]
@HMRouter({ pageUrl: 'PayCancel', dialog: true,animator:'PayCancelDialog' })
@Component
export struct PayCancel {
  // [StartExclude HMRouter_confirmDialog]
  pageUrl: string = '';

  aboutToAppear(): void {
    let pageUrl = HMRouterMgr.getCurrentParam() as string;
    this.pageUrl = pageUrl;
  }

  // [EndExclude HMRouter_confirmDialog]
  build() {
    Stack({ alignContent: Alignment.Center }) {
      ConfirmDialog({
        title: '取消订单',
        content: '您确认要取消此订单吗?',
        leftButtonName: '再看看',
        rightButtonName: '取消订单',
        leftButtonFunc: () => {
          HMRouterMgr.popAsync({
            navigationId: this.queryNavigationInfo()?.navigationId
          });
        },
        rightButtonFunc: () => {
          // [StartExclude HMRouter_confirmDialog]
          HMRouterMgr.popSkipDialog()
          // [EndExclude HMRouter_confirmDialog]
        }
      });
    }
    .width('100%')
    .height('100%')
    .position({
      x: '50%',
      y: '50%'
    })
    .markAnchor({
      x: '50%',
      y: '50%'
    });
  }
}

// [End HMRouter_confirmDialog]