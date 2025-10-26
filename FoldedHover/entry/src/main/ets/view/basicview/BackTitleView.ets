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

import { promptAction } from '@kit.ArkUI';
import { CommonConstants as Const } from '../../common/CommonConstants';

@Component
export struct BackTitleView {
  @StorageLink('isHover') isHover: boolean = false;
  @StorageLink('pageID') pageID: number = 3;
  @StorageLink('creaseRegion') creaseRegion: number[] = [];
  @Consume('pageInfos') pageInfos: NavPathStack;
  public title: Resource = Const.PAGE_TITLES[0];

  build() {
    // [Start save_scroll_distance]
    Row() {
      // [StartExclude save_scroll_distance]
      Image($r('app.media.back'))
        .height('40vp')
        .width('40vp')
        .fillColor(Color.White)
        .onClick(() => {
          this.pageInfos.pop();
        })

      Text(this.title)
        .fontSize('20fp')
        .fontWeight(700)
        .fontColor(Color.White)
        .margin({ left: '8vp' })
        .onClick(() => {
          this.getUIContext().getPromptAction().showToast({
            message: this.pageID.toString()
          })
        })
      // [EndExclude save_scroll_distance]
    }
    .width('80%')
    .height('24vp')
    .justifyContent(FlexAlign.Start)
    .position({
      x: '24vp',
      y: this.isHover ? this.creaseRegion[0] + this.creaseRegion[1] + 36 : '36vp'
    })
    // [End save_scroll_distance]
  }
}