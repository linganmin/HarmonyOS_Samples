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

import { FunctionType } from '@ohos/commons/Index';
import { FormViewData } from '../viewmodel/FormViewData';
import { FormConstants } from '../constants/FormConstants';

@Entry
@Component
struct FormCard {
  /*
 * The action type.
 */
  readonly ACTION_TYPE: string = 'router';
  /*
   * The ability name.
   */
  readonly ABILITY_NAME: string = 'EntryAbility';
  /*
   * The message.
   */
  readonly MESSAGE: string = 'add detail';

  build() {
    // [Start form_card_column]
    Column() {
      FormLink({
        action: 'router',
        abilityName: 'EntryAbility',
        params: {
          message: 'add detail'
        }
      }) {
        Column() {
          Row() {
            Image($r('app.media.ic_public_input_search'))
              .width('15vp')
              .margin({
                left: '10vp',
                right: '10vp'
              })

            Text($r('app.string.textInput_holder'))
              .fontColor('#99000000')
              .width('80%')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .borderRadius('22vp')
          .width('100%')
          .height('44vp')
          .backgroundColor('#0d000000')
          .margin({ top: '20vp' })

          Row() {
            ForEach(FormViewData.FUNCTIONS, (item: FunctionType) => {
              Column() {
                Image(item.icon)
                  .width('40vp')
                  .height('40vp')

                Text(item.desc)
                  .fontSize('12vp')
                  .padding({ top: '4vp' })
              }
            }, (item: FunctionType) => item.id.toString())
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .height('60%')
          .width('100%')
        }
        .width('90%')
      }
    }
    .width('100%')
    // [End form_card_column]
  }
}