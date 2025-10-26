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
import { emitter } from '@kit.BasicServicesKit';
import { ID_EVENT_CLOSE } from '../common/Constants';

@Entry
@Component
struct SubPage {
  @State message: string = 'SubPage';

  build() {
    Column() {
      Text(this.message)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20 })
      Button($r('app.string.text_close_sub_window'))
        .type(ButtonType.Normal)
        .stateEffect(true)
        .borderRadius(8)
        .margin({ top: 20 })
        .onClick(() => {
          emitter.emit(ID_EVENT_CLOSE);
        })
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
    .height('100%')
    .width('100%')
  }
}