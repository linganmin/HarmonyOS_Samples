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
* FAQ:当一个组件同时绑定了点击事件（onClick）和并行手势（parallelGesture），为什么当操作为长按时，两个手势都会响应？
*/

// [Start onClickAndParallelGestureSolution]
@Entry
@Component
struct onClickAndParallelGestureSolution {
  @State message: string = '多种手势，长按这里';

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .parallelGesture(
          GestureGroup(GestureMode.Exclusive,
            TapGesture({ count: 1, fingers: 1 })
              .onAction(() => {
                console.info('TapGesture--单击');
              }),
            LongPressGesture({ repeat: false })
              .onAction(() => {
                console.info('LongPressGesture--长按');
              })
          )
        )
    }
    .height('100%')
    .width('100%')
  }
}

// [Start onClickAndParallelGestureSolution]
