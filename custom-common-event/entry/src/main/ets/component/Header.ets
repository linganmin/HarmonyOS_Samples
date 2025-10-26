/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import { router } from '@kit.ArkUI';

@Component
export struct Header {
  @State src: Resource | undefined = undefined;

  build() {
    Column() {
    }
    .backgroundImage(this.src)
    .backgroundImageSize(ImageSize.Cover)
    .position({ x: '2%', y: '2%' })
    .size({ width: 200, height: 50 })
    .onClick(() => {
      this.getUIContext().getRouter().back();
    })
  }
}