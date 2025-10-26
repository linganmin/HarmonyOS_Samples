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
 
const storage = new LocalStorage();

@Entry(storage)
@Component
struct WidgetCard {
  @LocalStorageProp('formId') formId: string = '';
  @LocalStorageProp('text') text: string | boolean | number | null = 'Default';
  @LocalStorageProp('image') image: string = '';

  build() {
    Flex({ direction: FlexDirection.Column }) {
      Text() {
        Span($r('app.string.card_id'))
        Span(this.formId)
      }
      .fontSize(10)

      Row() {
        Text() {
          Span($r('app.string.card_content'))
          Span(this.text === null ? 'NULL' : String(this.text))
        }
        .fontSize(10)
        .flexGrow(1)
      }

      Row() {
        Image(this.image ? 'memory://' + this.image : $r('app.media.app_icon'))
          .width('80%')
          .height(80)
          .margin({ top: '5%', left: '10%', right: '10%' })
          .flexShrink(0)
      }
    }
    .padding(10)
    .onClick(() => {
      postCardAction(this, {
        action: 'router',
        abilityName: 'MainAbility',
      });
    })
  }
}




