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

import { AttributeUpdater, KeyboardAvoidMode, window } from '@kit.ArkUI';
import {
  HMAnimator,
  HMAnimatorHandle,
  HMLifecycle,
  HMLifecycleContext,
  HMRouter,
  HMRouterMgr,
  IHMAnimator,
  IHMLifecycle,
  OpacityOption,
  ScaleOption,
  TranslateOption
} from '@hadss/hmrouter';
import { BreakpointConstants } from '../common/constants/BreakpointConstants';
import { CommonConstants } from '../common/constants/CommonConstants';
import { BreakpointType } from '../common/utils/BreakpointType';
import { Live } from './Live';
import { PageConstant } from '../../constant/PageConstant';
import { CommentNodeController } from './CommentInput';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');

@Observed
export class VideoSrc {
  src: string | Resource;

  constructor(src: string | Resource) {
    this.src = src;
  }
}

// [Start live_home_life_cycle]
@HMLifecycle({ lifecycleName: 'liveHomeLifecycle' })
export class LiveHomeLifecycle implements IHMLifecycle {
  commentRenderNode: CommentNodeController = new CommentNodeController();
  // [StartExclude live_home_life_cycle]
  videoSrc: VideoSrc = new VideoSrc($rawfile('camera-ais.mp4'));

  onShown(ctx: HMLifecycleContext): void {
    window.getLastWindow(uiContext!.getHostContext(), (err, data) => {
      if (err.code > 0) {
        console.error(`${err.code} ${err.message}`);
        return;
      }
      data.setWindowSystemBarProperties({
        statusBarContentColor: Color.White.toString()
      });
    });
  }

  onHidden(ctx: HMLifecycleContext): void {
    window.getLastWindow(uiContext!.getHostContext(), (err, data) => {
      if (err.code > 0) {
        console.error(`${err.code} ${err.message}`);
        return;
      }
      data.setWindowSystemBarProperties({
        statusBarContentColor: Color.Black.toString()
      });
    });
  }

  // [EndExclude live_home_life_cycle]
  onAppear(ctx: HMLifecycleContext): void {
    this.commentRenderNode.makeNode(ctx.uiContext);
  }

  onDisAppear(ctx: HMLifecycleContext): void {
    this.commentRenderNode.dispose();
  }
}

// [End live_home_life_cycle]

// [Start live_inter_active]
@HMAnimator({ animatorName: 'liveInteractiveAnimator' })
export class LiveInteractiveAnimator implements IHMAnimator {
  effect(enterHandle: HMAnimatorHandle, exitHandle: HMAnimatorHandle): void {
    // [StartExclude live_inter_active]
    enterHandle.start((modifier: AttributeUpdater<NavDestinationAttribute>) => {
      modifier.attribute?.translate({ x: '100%' }).opacity(0.4)
    }).finish((modifier: AttributeUpdater<NavDestinationAttribute>) => {
      modifier.attribute?.translate({ x: '0' }).opacity(1)
    }).onFinish((modifier: AttributeUpdater<NavDestinationAttribute>) => {
      modifier.attribute?.translate({ x: '0' }).opacity(1)
    })

    exitHandle.start((modifier: AttributeUpdater<NavDestinationAttribute>) => {
      modifier.attribute?.translate({ x: '0' }).opacity(1)
    }).finish((modifier: AttributeUpdater<NavDestinationAttribute>) => {
      modifier.attribute?.translate({ x: '100%' }).opacity(0.4)
    }).onFinish((modifier: AttributeUpdater<NavDestinationAttribute>) => {
      modifier.attribute?.translate({ x: '100%' }).opacity(0.4)
    })
    // [EndExclude live_inter_active]
  }

  interactive(handle: HMAnimatorHandle): void {
    handle.actionStart((event: GestureEvent) => {
      if (event.offsetX > 0) {
        HMRouterMgr.pop();
      }
    });
    handle.updateProgress((event, proxy, operation, startOffset) => {
      if (!proxy?.updateTransition || !startOffset) {
        return;
      }
      let offset = 0;
      if (event.fingerList[0]) {
        offset = event.fingerList[0].localX - startOffset;
      }
      if (offset < 0) {
        proxy?.updateTransition(0);
        return;
      }
      let rectWidth = event.target.area.width as number;
      let rate = offset / rectWidth;
      proxy?.updateTransition(rate);
    });
    handle.actionEnd((event, proxy, operation, startOffset) => {
      if (!startOffset) {
        return;
      }
      let rectWidth = event.target.area.width as number;
      let rate = 0;
      if (event.fingerList[0]) {
        rate = (event.fingerList[0].localX - startOffset) / rectWidth;
      }
      if (rate > 0.4) {
        proxy?.finishTransition();
      } else {
        proxy?.cancelTransition?.();
      }
    });
  }
}

// [End live_inter_active]

// [Start HMRouter_singleton]
@HMRouter({
  pageUrl: 'liveHome',
  singleton: true,
  animator: 'liveInteractiveAnimator',
  lifecycle: 'liveHomeLifecycle'
})
@Component
export struct LiveHome {
  // [StartExclude HMRouter_singleton]
  @State isMoreDetail: boolean = false;
  @State detailType: string = CommonConstants.BIND_SHEET_PAGE_TYPES[0];
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('changeVideoHeight') videoHeight: string | number = CommonConstants.FULL_PERCENT;

  aboutToAppear(): void {
    window.getLastWindow(uiContext!.getHostContext(), (err, win) => {
      win.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
    });
  }

  build() {
    Column() {
      Live({
        currentBreakpoint: this.isMoreDetail ? new BreakpointType(BreakpointConstants.BREAKPOINT_SM,
          BreakpointConstants.BREAKPOINT_SM, BreakpointConstants.BREAKPOINT_MD).getValue(this.currentBreakpoint) :
        this.currentBreakpoint,
        detailType: $detailType,
        isMoreDetail: $isMoreDetail
      });
    }
    .height('100%')
    .width('100%');
  }

  // [EndExclude HMRouter_singleton]
}

// [End HMRouter_singleton]