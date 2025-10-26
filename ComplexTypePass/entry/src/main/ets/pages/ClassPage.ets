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

// [Start class_page]
// entry/src/main/ets/pages/ClassPage.ets
import ParamPassing from 'libentry.so';
import { OutputArea } from '../model/IOModel';

const HINT_STRING: string = 'Calculation completed:\n';

class SampleClassTs2Napi implements ParamPassing.SampleClassTs2Napi {
  public result: string = '';

  add(a: number, b: number) {
    this.result = `${a} + ${b} = ${a + b}`;
    return HINT_STRING;
  }
}
// [End class_page]

@Builder
export function classPage(_entry: string, param: string) {
  NavDestination() {
    MainComponent()
  }
  .title(param)
  .backgroundColor($r('app.color.sub_window_background'))
}

@Preview
@Component
struct MainComponent {
  @Provide printStr: string = '';

  build() {
    Column() {
      OutputArea()
      Blank()
      Row() {
        Button($r('app.string.button_text_Ts2Napi'))
          .onClick(() => {
            this.printStr = ParamPassing.classPassingTs2Napi(new SampleClassTs2Napi());
          })
          .flexGrow(1)
          .fontSize($r("app.string.button_text_font_size_small"))
        Blank()
          .width($r("app.string.margin_m"))
        Button($r('app.string.button_text_Napi2Ts'))
          .onClick(() => {
            // [Start napi_class]
            // entry/src/main/ets/pages/ClassPage.ets
            let napiClass: ParamPassing.SampleClassNapi2Ts = new ParamPassing.SampleClassNapi2Ts(HINT_STRING);
            napiClass.hintStr += 'modify by ArkTS: \n';
            this.printStr = napiClass.hintStr + napiClass.times(6, 9);
            // [End napi_class]
          })
          .flexGrow(1)
          .fontSize($r("app.string.button_text_font_size_small"))
      }
      .width($r('app.string.100percent'))
    }
    .padding($r("app.string.margin_l"))
    .width($r('app.string.100percent'))
    .height($r('app.string.100percent'))
  }
}