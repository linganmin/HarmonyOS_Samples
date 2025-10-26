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

import { CommonConstants } from '../common/constants/CommonConstants';
import utils from '../common/utils/CompressionUtils';

@Entry
@Component
struct WebComponent {
  @State content: string = '';
  @State res: string = '';

  build() {
    Column() {
      TextInput({ placeholder: $r('app.string.input_content') })
        .onChange((value: string) => {
          this.content = value;
        })
      Button($r('app.string.Compression'))
        .margin({ top: $r('app.float.default_10') })
        .onClick(() => {
          utils.zipFiles(this.content);
        })
      Button($r('app.string.Decompression'))
        .margin({ top: $r('app.float.default_10') })
        .onClick(async () => {
          await utils.unZipFiles().then((value: string) => {
            this.res = value;
          })
        })
      Text(CommonConstants.RESULT + this.res)
        .margin({ top: $r('app.float.default_10') })
    }
  }
}