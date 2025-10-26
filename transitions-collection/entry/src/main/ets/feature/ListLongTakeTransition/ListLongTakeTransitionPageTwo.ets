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

import { curves } from '@kit.ArkUI';
import { ListDetailPageExtraInfo } from '../../utils/commonutils/ExtraInfo';
import Constants from '../../common/Constants';

@Builder
export function ListLongTakeTransitionPageTwoBuilder() {
  ListLongTakeTransitionPageTwo()
}

@Component
export default struct ListLongTakeTransitionPageTwo {
  private pageInfos: NavPathStack = new NavPathStack();
  private param: ListDetailPageExtraInfo = new ListDetailPageExtraInfo('', '', $r('app.string.DetailPage_text'));

  build() {
    // [Start list_long2]
    NavDestination() {
      Column({ space: 20 }) {
        Text(this.param.title)
          .fontSize(30)
          .fontWeight(FontWeight.Medium)
        Text(this.param.content)
          .fontColor($r('sys.color.password_icon_focus_color'))
          .lineHeight(28)
          .fontSize(16)
      }
      .alignItems(HorizontalAlign.Start)
      .clip(true)
      .size({
        width: '100%',
        height: '100%'
      })
      .geometryTransition(this.param.geometryId)
    }
    .padding({
      top: 46,
      left: 16,
      right: 16
    })
    .backgroundColor(Constants.DEFAULT_BG_COLOR)
    .transition(TransitionEffect.OPACITY)
    .hideTitleBar(true)
    .backgroundColor(Color.Transparent)
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
      this.param = (context.pathInfo.param as ListDetailPageExtraInfo);
    })
    .onBackPressed(() => {
      this.getUIContext().animateTo({ curve: curves.interpolatingSpring(0, 1, 342, 38) }, () => {
        this.pageInfos.pop(false);
      })
      return true;
    })

    // [End list_long2]
  }
}