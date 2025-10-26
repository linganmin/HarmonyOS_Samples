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

import { display } from "@kit.ArkUI";
import { HomeConstants } from "../constants/HomeConstants";
import { Logger } from "commons";

const TAG = 'HomeContent';

interface OperateButtonType {
  icon: Resource
  count: number
  onClick?: (event: ClickEvent) => void
}

@Component
struct OperateButton {
  @Require @Prop icon: Resource;
  @Require @Prop count: number;
  handleClick: (event: ClickEvent) => void = event => {
  }

  build() {
    Column() {
      Image(this.icon)
        .width($r('app.float.operate_button_icon_width'))
      Text(this.count.toString())
        .fontColor(Color.White)
    }
    .onClick(this.handleClick)
  }
}

@Extend(Text)
function videoInfoStyle() {
  .fontSize(14)
  .fontColor('rgba(255, 255, 255, 0.80)')
}

@Component
export struct HomeContent {
  private operateButtons: OperateButtonType[] = [
    {
      icon: $r('app.media.like'),
      count: HomeConstants.OPERATE_BUTTON_COUNTS[0]
    },
    {
      icon: $r('app.media.comment'),
      count: HomeConstants.OPERATE_BUTTON_COUNTS[1],
      onClick: this.onCommentButtonClick.bind(this)
    },
    {
      icon: $r('app.media.share'),
      count: HomeConstants.OPERATE_BUTTON_COUNTS[2]
    }
  ];
  private fullHeight: number = 0;
  @Consume navDialogPageInfos: NavPathStack;
  @StorageLink('commentListHeight') commentListHeight: number = 0;

  aboutToAppear(): void {
    this.setFullHeight();
  }

  async setFullHeight() {
    try {
      const rects = await display.getAllDisplays();
      this.fullHeight = this.getUIContext().px2vp(rects[0].height);
    } catch (exception) {
      Logger.error(TAG,
        `getAllDisplays Failed. Code:${exception.code}, message:${exception.message}`);
    }
  }

  onCommentButtonClick(event: ClickEvent) {
    this.navDialogPageInfos.pushPathByName('CommentList', null)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Image($r('app.media.bg'))
        .width(HomeConstants.FULL_SIZE)
        .height(this.commentListHeight ? this.fullHeight - this.commentListHeight : '100%')
        .objectFit(this.commentListHeight ? ImageFit.Contain : ImageFit.Cover)
      Row() {
        Column({ space: 15 }) {
          Row({ space: 10 }) {
            Text($r('app.string.video_title'))
              .fontColor(Color.White)
            Text($r('app.string.video_title_time'))
              .videoInfoStyle()
          }

          Text($r('app.string.video_info'))
            .videoInfoStyle()
          Row({ space: 5 }) {
            Image($r('app.media.video_music'))
              .width(16)
            Text($r('app.string.video_info_music'))
              .videoInfoStyle()
          }
        }
        .padding(16)
        .width('80%')
        .alignItems(HorizontalAlign.Start)

        Column({ space: HomeConstants.MEDIUM_SPACE }) {
          Image($r('app.media.avatar'))
            .width($r('app.float.avatar_width'))
          ForEach(this.operateButtons, (operateButton: OperateButtonType) => {
            OperateButton({
              icon: operateButton.icon,
              count: operateButton.count,
              handleClick: operateButton.onClick
            })
          }, (operateButton: OperateButtonType) => JSON.stringify(operateButton))
        }
        .width('20%')
        .padding(16)
      }
      .height(HomeConstants.FULL_SIZE)
      .alignItems(VerticalAlign.Bottom)
    }
  }
}