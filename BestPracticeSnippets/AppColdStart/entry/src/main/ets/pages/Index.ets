/*
* Copyright (C) 2025 Huawei Device Co., Ltd.
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

// [Start request_in_home]
// entry/src/main/ets/pages/Index.ets
import { httpRequest } from '../utils/NetRequest';

import { number } from '../utils/Calculator';

AppStorage.link('netData');
PersistentStorage.persistProp('netData', undefined);

@Entry
@Component
struct Index {
  // In order to reflect the performance benefits, refer to the execution result number of the time-consuming function.
  @State message: string = 'Hello World' + number;
  @StorageLink('netData') netData: PixelMap | undefined = undefined;

  build() {
    Column() {
      Text(this.message)
        .fontSize(32)
      Image(this.netData)
        .objectFit(ImageFit.Contain)
        .width('50%')
        .height('50%')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onAppear(() => {
      // Send a network request
      httpRequest();
    })
  }
}
// [End request_in_home]
