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

import { common } from '@kit.AbilityKit'
import { picker } from '@kit.CoreFileKit'
import { BehaviorChoice } from './BehaviorChoice'
import { Record } from './Record'
import { CommonConstants as Const } from '../common/CommonConstants'
import Logger from '../common/utils/Logger'
import { BusinessError } from '@kit.BasicServicesKit'

const TAG: string = Const.INDEX_TAG

@Entry
@Component
struct Index {
  @State message: string = 'Hello World'
  @Provide pageInfos: NavPathStack = new NavPathStack()
  private selectFilePath: string | undefined = undefined

  @Builder
  PagesMap(name: string) {
    if (name === 'BehaviorChoice') {
      BehaviorChoice()
    }
    if (name === 'Record') {
      Record()
    }
  }

  selectFile() {
    let audioSelectOptions = new picker.AudioSelectOptions()
    let audioPicker = new picker.AudioViewPicker(this.getUIContext().getHostContext() as common.UIAbilityContext)
    audioPicker.select(audioSelectOptions)
      .then((audioSelectResult: Array<string>) => {
        this.selectFilePath = audioSelectResult[0]
        if (this.selectFilePath === undefined) {
          try {
            this.getUIContext().getPromptAction().showToast({
              message: $r('app.string.alert'),
              duration: Const.DURATION,
              bottom: Const.BOTTOM
            })
          } catch (err) {
            Logger.error('showToast failed with err:' + JSON.stringify(err));
          }
        } else {
          this.pageInfos.pushPath({ name: 'BehaviorChoice', param: this.selectFilePath })
          Logger.info(TAG, 'documentViewPicker.select to file succeed and URI is:' + this.selectFilePath)
        }
      })
      .catch((err: BusinessError) => {
        Logger.error('select failed:' + JSON.stringify(err));
      })
  }

  build() {
    Navigation(this.pageInfos) {
      Column({ space: 12 }) {
        Button($r('app.string.select_audio'))
          .onClick(() => {
            this.selectFile()
          })
          .size({
            width: '100%',
            height: $r('app.float.index_button_height')
          })

        Button($r('app.string.record'))
          .onClick(() => {
            this.pageInfos.pushPath({ name: 'Record' })
          })
          .size({
            width: '100%',
            height: $r('app.float.index_button_height')
          })
      }
      .width('100%')
      .height('100%')
      .padding($r('app.float.button_container_margin_horizontal'))
      .justifyContent(FlexAlign.End)
    }
    .title($r('app.string.main_title'))
    .height('100%')
    .width('100%')
    .backgroundColor($r('app.color.audio_background'))
    .navDestination(this.PagesMap)
  }
}
