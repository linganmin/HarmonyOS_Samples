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
* FAQ:如何获取手机屏幕信息
*/

// [Start get_phone_screen_information]
import { display } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  private screenWidth: number = 0;
  private screenHeight: number = 0;

  aboutToAppear() {
    try {
      this.screenWidth = display.getDefaultDisplaySync().width;
      this.screenHeight = display.getDefaultDisplaySync().height;
    } catch (e) {
      console.error('Fail with code: ' + JSON.stringify(e));
    }
  }

  build() {
    Row() {
      Column() {
        Text('---->width: ' + this.screenWidth)
        Text('---->height: ' + this.screenHeight)
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End get_phone_screen_information]