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

import { ImageKnifeComponent, ImageKnifeOption } from '@ohos/imageknife';
import Constants from '../common/Constants';

@Component
export default struct ManualModeView {
  private readonly IMAGE_KNIFE_TASK: string = 'ImageKnifeTask';
  @State option: ImageKnifeOption = {
    loadSrc: $r('app.media.resource_image'),
    border: { radius: 15 }
  };

  build() {
    Column() {
      Text(this.IMAGE_KNIFE_TASK)
        .fontSize(14)
        .fontWeight(500)
        .lineHeight(20)
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
        .width(Constants.FULL_PERCENT)
      ImageKnifeComponent({ imageKnifeOption: this.option })
        .width(Constants.FULL_PERCENT)
        .margin({ top: 8 })
    }
    .justifyContent(FlexAlign.Start)
    .width(Constants.FULL_PERCENT)
    .height(240)
    .margin({ top: 12 })
  }
}