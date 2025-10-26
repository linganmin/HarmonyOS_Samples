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

@Component
export struct ReturnHeader {
  title: string = '';
  returnFunc = () => {
  };

  build() {
    Flex({direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start}) {
      Button({buttonStyle: ButtonStyleMode.TEXTUAL}) {
        Image($r('app.media.chevron_left'))
          .width(40)
          .height(40)
          .objectFit(ImageFit.Contain);
      }
      .onClick(this.returnFunc)
      .backgroundColor($r('app.color.common_background_4'))
      .id('returnButton');

      Text(this.title)
        .fontSize(23)
        .fontWeight(FontWeight.Bold)
        .margin({left: 10});
    }
    .margin({top: 10, left: 10});
  }
}