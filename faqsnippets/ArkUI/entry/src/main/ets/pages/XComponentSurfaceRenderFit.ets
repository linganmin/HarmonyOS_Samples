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
* FAQ:Surface模式下的XComponent组件在设置RenderFit后如果出现显示异常，该如何调整以获得正确的显示效果
*/
// [Start XComponent_Surface_RenderFit]
@Entry
@Component
struct XComponentSurfaceRenderFit {
  @State xcWidth: number = 500;
  @State xcHeight: number = 700;
  myXComponentController: XComponentController = new XComponentController();

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Start }) {
      XComponent({
        id: 'myXComponent_RenderFitSurface', // When the string of the id contains "RenderFitSurface", RenderFit can be displayed correctly
        type: XComponentType.SURFACE,
        controller: this.myXComponentController
      })
        .width(this.xcWidth)
        .height(this.xcHeight)
        .renderFit(RenderFit.CENTER)
    }
    .width('100%')
  }
}

// [End XComponent_Surface_RenderFit]