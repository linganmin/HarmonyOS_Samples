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

// [Start set_volume_component]
import { AVVolumePanel } from '@kit.AudioKit';

@Component
export struct SetVolume {
  @Prop volume: number = 5
  @Prop volumeVisible: boolean = false

  build() {
    Column() {
      AVVolumePanel({
        volumeLevel: this.volume,
        volumeParameter: {
          position: {
            x: 150,
            y: 300
          }
        }
      })
        .width(10)
    }
    .visibility(this.volumeVisible ? Visibility.Visible : Visibility.Hidden)
    .height('50%')
  }
}
// [End set_volume_component]