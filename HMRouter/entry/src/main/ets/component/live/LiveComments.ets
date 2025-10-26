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

import { window } from '@kit.ArkUI';
import { HMLifecycle, HMLifecycleContext, HMRouter, HMRouterMgr, IHMLifecycle } from '@hadss/hmrouter';
import { LiveCommentsHeader } from './LiveCommentsHeader';
import { CommentNodeController } from './CommentInput';
import { PageConstant } from '../../constant/PageConstant';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');

interface LiveCommentsParamType {
  commentRenderNode: CommentNodeController;
}

@HMLifecycle({lifecycleName: 'liveCommentLifecycle'})
export class LiveCommentLifecycle implements IHMLifecycle {
  onShown(ctx: HMLifecycleContext): void {
    window.getLastWindow(uiContext!.getHostContext(), (err, data) => {
      if(err.code > 0) {
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
      if(err.code > 0) {
        console.error(`${err.code} ${err.message}`);
        return;
      }
      data.setWindowSystemBarProperties({
        statusBarContentColor: Color.White.toString()
      });
    });
  }
}

@HMRouter({pageUrl: PageConstant.LIVE_COMMENTS, dialog: true, lifecycle: 'liveCommentLifecycle'})
@Component
export struct LiveComments {
  commentRenderNode?: CommentNodeController;

  aboutToAppear(): void {
    this.commentRenderNode =
      (HMRouterMgr.getCurrentParam() as LiveCommentsParamType)?.commentRenderNode;
  }

  build() {
    Row() {
      Column() {
        LiveCommentsHeader();

        Column() {
          NodeContainer(this.commentRenderNode).width('100%').height('100%');
        }.layoutWeight(1);
      }
      .backgroundColor($r('app.color.live_comment_background_color'))
      .border({radius: {topLeft: 20, topRight: 20}})
      .height('70%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
    }
    .alignItems(VerticalAlign.Bottom)
    .width('100%')
    .height('100%');
  }
}