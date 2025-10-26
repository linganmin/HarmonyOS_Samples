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
 * 最佳实践：根据条件呈现不同转场动效
 */

import {
  HMAnimator,
  HMAnimatorHandle,
  HMRouterMgr,
  IHMAnimator,
} from "@hadss/hmrouter";
import { AttributeUpdater } from "@kit.ArkUI";

// [Start my_animator1]
@HMAnimator({ animatorName: 'myAnimator1' })
export class MyAnimator1 implements IHMAnimator {
  effect(enterHandle: HMAnimatorHandle, exitHandle: HMAnimatorHandle): void {
    enterHandle.start((modifier: AttributeUpdater<NavDestinationAttribute>) => {
      modifier.attribute?.translate({ y: '100%' })
    }).finish((modifier: AttributeUpdater<NavDestinationAttribute>) => {
      modifier.attribute?.translate({ y: '0' })
    })

    exitHandle.start((modifier: AttributeUpdater<NavDestinationAttribute>) => {
      modifier.attribute?.translate({ y: '0' })
    }).finish((modifier: AttributeUpdater<NavDestinationAttribute>) => {
      modifier.attribute?.translate({ y: '100%' })
    })
  }
}

// [End my_animator1]

// [Start my_animator2]
@HMAnimator({ animatorName: 'myAnimator2' })
export class MyAnimator2 implements IHMAnimator {
  effect(enterHandle: HMAnimatorHandle, exitHandle: HMAnimatorHandle): void {
    enterHandle.start((modifier: AttributeUpdater<NavDestinationAttribute>) => {
      modifier.attribute?.translate({ x: '100%', y: '0' })
    }).finish((modifier: AttributeUpdater<NavDestinationAttribute>) => {
      modifier.attribute?.translate({ x: 0 })
    })
    enterHandle.duration = 500;

    exitHandle.start((modifier: AttributeUpdater<NavDestinationAttribute>) => {
      modifier.attribute?.translate({ x: '0' })
    }).finish((modifier: AttributeUpdater<NavDestinationAttribute>) => {
      modifier.attribute?.translate({ x: '100%' })
    })
    exitHandle.duration = 500;
  }
}

// [End my_animator2]

// [Start comment_input_amimator]
@Component
export struct CommentInput {
  // [StartExclude comment_input_amimator]
  @State isLandscape: boolean = true;
  @State videoWidth: string = ''
  @State videoHeight: string = ''

  // [EndExclude comment_input_amimator]

  build() {
    Row() {
      Image($r('app.media.icon_comments'))
        .width(24)
        .height(24)
        .margin({ right: 16 })
        .onClick(() => {
          if (this.isLandscape) {
            HMRouterMgr.to('liveComments')
              .withNavigation(this.queryNavigationInfo()?.navigationId)
              .withParam({commentRenderNode: ''})
              .withAnimator(new MyAnimator2())
              .onResult((paramInfo: PopInfo)=>{
                this.videoWidth = '100%';
              })
              .pushAsync()
            this.videoWidth = '50%';
          } else {
            HMRouterMgr.to('liveComments')
              .withNavigation(this.queryNavigationInfo()?.navigationId)
              .withParam({commentRenderNode: ''})
              .withAnimator(new MyAnimator1())
              .onResult((paramInfo: PopInfo)=>{
                this.videoHeight = '100%';
              })
              .pushAsync()
            this.videoHeight = '30%'
          }
        });
    }
  }
}

// [End comment_input_amimator]