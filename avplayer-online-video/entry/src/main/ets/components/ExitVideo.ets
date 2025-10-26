/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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


@Component
export struct ExitVideo {
  @Consume('pageStack') pageStack: NavPathStack;

  @Prop videoName?: string | Resource;
  @Link isFullScreen: boolean;

  build() {
    Row() {
      // Exit
      Column() {
        Image($r('app.media.ic_video_back'))
          .id('Exit')
          .width($r('app.float.size_15'))
      }
      .width($r('app.float.size_40'))
      .height($r('app.float.size_40'))
      .borderRadius($r('app.float.size_20'))
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.back_button'))
      .onClick(() => {
        this.isFullScreen = false;
        this.pageStack.pop();
      })

      Text(this.videoName)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
        .fontSize(20)
        .margin({ left: 16,right:5})
        .layoutWeight(1)
    }
    .margin({ top: $r('app.float.size_20'), left: $r('app.float.size_25') })
  }
}