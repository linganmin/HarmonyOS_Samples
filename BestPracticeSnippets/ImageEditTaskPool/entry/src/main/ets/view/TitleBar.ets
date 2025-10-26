/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { CommBackgroundIcon } from './CommBackgroundIcon';

@Component
export default struct TitleBar {
  onBack: () => void = () => {
  };
  onReset: () => void = () => {
  };
  onSave: () => void = () => {
  };

  build() {
    Row() {
      Row() {
        CommBackgroundIcon({
          icon: $r('app.media.ic_backward'),
          onClickImage: () => {
            this.onBack();
          }
        })
        Text($r('app.string.image_edit'))
          .fontSize(20)
          .fontColor(Color.White)
          .margin({ left: 8 })
      }

      Row() {
        CommBackgroundIcon({
          icon: $r('app.media.ic_reset'),
          onClickImage: () => {
            this.onReset();
          }
        })
        Blank().width(8)
        CommBackgroundIcon({
          icon: $r('app.media.ic_save'),
          onClickImage: () => {
            this.onSave();
          }
        })
      }
    }
    .padding({
      right: 16,
      left: 16
    })
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .backgroundColor(Color.Black)
  }
}