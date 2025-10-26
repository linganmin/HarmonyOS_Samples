/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/*
* FAQ:预览流黑屏但无报错信息该怎么解决
*/
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct ResolvePreviewStreamBlackScreenIssuePage {
  @State message: string = 'Hello World';
  surfaceId: string = '';

  // [Start ResolvePreviewStreamBlackScreenIssuePage]
  async onPageShow() {
    let baseContext = this.getUIContext().getHostContext()! as common.BaseContext;
    await this.initCamera(baseContext, this.surfaceId);
  }

  async onPageHide() {
    await this.releaseCamera();
  }
  // [End ResolvePreviewStreamBlackScreenIssuePage]

  async initCamera(context: common.BaseContext, surfaceId: string) {}

  async releaseCamera() {}

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('ResolvePreviewStreamBlackScreenIssuePageHelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          this.message = 'Welcome';
        })
    }
    .height('100%')
    .width('100%')
  }
}