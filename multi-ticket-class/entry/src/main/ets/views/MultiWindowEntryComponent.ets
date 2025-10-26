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

import { MultiWindowEntryInAPP } from '@kit.UIDesignKit';
import { TextModifier } from '@kit.ArkUI';
import { Want } from '@kit.AbilityKit';

@Component
export struct MultiWindowEntryComponent {
  @Link textModifier: TextModifier;
  @Link want: Want;

  build() {
    Row() {
      MultiWindowEntryInAPP({
        want: this.want,
        isShowSubtitle: false,
        multiWindowEntryInAPPStyle: {
          iconOptions: {
            iconSize: 24,
            iconColor: $r('sys.color.font_primary'),
            iconWeight: FontWeight.Normal,
            backgroundColor: $r('sys.color.comp_background_tertiary')
          },
          subtitleOptions: {
            modifier: this.textModifier.fontColor(Color.Black)
          }
        }
      })
    }
  }
}
