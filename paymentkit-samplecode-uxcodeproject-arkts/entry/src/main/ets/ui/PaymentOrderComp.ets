/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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

import { Amount } from "./Amount";

@Component
export struct PaymentOrderComp {
  @Prop mercShortName: ResourceStr = '';
  @Prop paymentAmount: string = '';

  build() {
    Column() {
      Text(this.mercShortName)
        .fontFamily('HarmonyHeiTi')
        .fontSize($r('sys.float.ohos_id_text_size_body2'))
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Normal)

      Amount({
        amount: this.paymentAmount,
      }).margin({ top: 2 })
    }
  }
}