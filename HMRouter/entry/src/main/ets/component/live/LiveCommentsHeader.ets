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

import {
  HMAnimator,
  HMAnimatorHandle,
  HMRouterMgr,
  IHMAnimator,
  OpacityOption,
  ScaleOption,
  TranslateOption
} from '@hadss/hmrouter';
import { CommonConstants } from '../common/constants/CommonConstants';
import { LiveConstants } from '../common/constants/LiveConstants'
import { AttributeUpdater } from '@kit.ArkUI';

@HMAnimator({animatorName: 'closeLiveCommentsAnimator'})
export class CloseLiveCommentsAnimator implements IHMAnimator {
  effect(enterHandle: HMAnimatorHandle, exitHandle: HMAnimatorHandle): void {

    // exit animation
    exitHandle.start((modifier: AttributeUpdater<NavDestinationAttribute>) => {
      modifier.attribute?.translate({ y: '0' })
    }).finish((modifier: AttributeUpdater<NavDestinationAttribute>) => {
      modifier.attribute?.translate({ y: '100%' })
    })
    exitHandle.duration = 500;
  }
}

@Component
export struct LiveCommentsHeader {
  @State commentsNum: number = 1593;
  @StorageLink('changeVideoHeight') videoHeight: string | number = CommonConstants.FULL_PERCENT;

  build() {
    Flex({direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center}) {
      Text(LiveConstants.LIVING_LEFT_TEXT + this.commentsNum + LiveConstants.LIVING_RIGHT_TEXT)
        .fontColor($r('app.color.live_comment_header_font_color'))
        .margin(10);
      Image($r('app.media.icon_close_1'))
        .width(20)
        .onClick(() => {
          HMRouterMgr.to('liveHome')
            .withNavigation(this.queryNavigationInfo()?.navigationId)
            .withAnimator(new CloseLiveCommentsAnimator())
            .popAsync()
          this.videoHeight = CommonConstants.FULL_PERCENT;
        });
    }
    .margin(10);
  }
}