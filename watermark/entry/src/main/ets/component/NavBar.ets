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

@Component
export struct NavBar {
  @Prop title: ResourceStr = (this.getUIContext().getRouter().getParams() as Record<string, ResourceStr>).title;
  @Prop isWhiteIcon: boolean = false;

  build() {
    Row() {
      Button() {
        Image($r('app.media.back'))
          .width(20)
          .height(20)
          .fillColor(this.isWhiteIcon ? Color.White : Color.Black)
          .opacity(0.9)
      }
      .width(40)
      .height(40)
      .backgroundColor('rgba(0, 0, 0, 0.05)')
      .margin({ right: 8 })
      .onClick(() => {
        this.getUIContext().getRouter().back()
      })
      Text(this.title)
        .fontSize(20)
        .fontColor(this.isWhiteIcon ? Color.White : Color.Black)
        .opacity(0.9)
        .fontWeight(FontWeight.Bold)
    }
    .height($r('app.float.navbar_height'))
    .width('100%')
    .borderWidth({ bottom: 0 })
    .justifyContent(FlexAlign.Start)
    .padding({ left: 16 })
  }
}