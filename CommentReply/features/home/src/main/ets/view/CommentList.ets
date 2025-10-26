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
import { HomeConstants } from "../constants/HomeConstants";
import { NavigationDialog } from "./NavigationDialog";

@Component
export struct CommentList {
  private operateButtonIcons: Resource[] = [
    $r('app.media.at'),
    $r('app.media.face'),
    $r('app.media.picture'),
    $r('app.media.paper_plane')
  ]
  @Consume navDialogPageInfos: NavPathStack;

  aboutToDisappear(): void {
    AppStorage.setOrCreate('commentListHeight', 0);
  }

  openCommentKeyboard = () => {
    this.navDialogPageInfos.pushPath({ name: 'CommentKeyboard' });
  }

  closeCommentList = () => {
    this.navDialogPageInfos.pop();
  }

  onCommentListAreaChange = (oldArea: Area, newArea: Area) => {
    AppStorage.setOrCreate('commentListHeight', newArea.height)
  }

  @Builder
  TitleBar() {
    Row() {
      Text($r('app.string.comment_list_title'))
        .fontSize($r('app.float.comment_title_font_size'))
        .fontWeight(FontWeight.Bold)
      Blank()
      Button() {
        Image($r('app.media.cancel'))
          .width($r('app.float.close_button_icon_width'))
      }
      .padding($r('app.float.padding_small'))
      .backgroundColor($r('app.string.comment_button_bg_color'))
      .onClick(this.closeCommentList)
    }
    .padding($r('app.float.padding_medium'))
    .width(HomeConstants.FULL_SIZE)
  }

  @Builder
  ToolBar() {
    Row({ space: HomeConstants.SMALL_SPACE }) {
      Button($r('app.string.comment_button_text'))
        .layoutWeight(1)
        .align(Alignment.Start)
        .backgroundColor($r('app.string.comment_button_bg_color'))
        .fontColor($r('app.string.comment_button_text_color'))
        .onClick(this.openCommentKeyboard)
      ForEach(this.operateButtonIcons, (icon: Resource) => {
        Image(icon)
          .width($r('app.float.comment_operate_button_width'))
      })
    }
    .padding($r('app.float.padding_small'))
  }

  build() {
    NavigationDialog() {
      Column() {
        this.TitleBar()
        Image($r('app.media.comment_list'))
          .width(HomeConstants.FULL_SIZE)
        this.ToolBar()
      }
      .backgroundColor(Color.White)
      .borderRadius({
        topLeft: $r('app.float.comment_list_border_radius'),
        topRight: $r('app.float.comment_list_border_radius')
      })
      .padding({ bottom: 20 })
      .onAreaChange(this.onCommentListAreaChange)
    }
  }
}