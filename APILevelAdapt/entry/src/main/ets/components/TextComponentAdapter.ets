/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { deviceInfo } from "@kit.BasicServicesKit";

class MyModifier implements AttributeModifier<TextAttribute> {
  applyNormalAttribute(instance: TextAttribute): void {
    // Judgment is made by the api version information of deviceInfo
    if (deviceInfo.sdkApiVersion >= 18) {
      // Adapts to the Text component API 18 marquee property
      instance.textOverflow({ overflow: TextOverflow.MARQUEE })
      instance.marqueeOptions({ start: true })
    }
  }
}

@Component
export struct TextComponentAdapter {
  private message: string = 'This a a simple Code of Text Marquee';
  private adaptModifier: MyModifier = new MyModifier();

  build() {
    Text(this.message)
      .fontSize(24)
      .height(200)
      .width('100%')
      .attributeModifier(this.adaptModifier)
  }
}
