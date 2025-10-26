/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
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

/*
* FAQ:汉字转拼音如何去掉音标
*/

// [Start convert_chinese_characters_to_pinyin]
import { i18n } from '@kit.LocalizationKit';

@Entry
@Component
struct RemovePinyin {
  @State message: string = 'Hello World';

  build() {
    RelativeContainer() {
      Text(this.message)
        .fontSize(50)
        .onClick(() => {
          // 1. Chinese characters to Pinyin
          let transliterator1 = i18n.Transliterator.getInstance('Any-Latn');
          let res = transliterator1.transform('中国');
          // 2. Remove tone marks
          let transliterator2 = i18n.Transliterator.getInstance('Latin-ASCII');
          let pinyinResult = transliterator2.transform(res);
          console.info('pinyinResult: ' + pinyinResult);
        })
    }
    .height('100%')
    .width('100%')
  }
}

// [End convert_chinese_characters_to_pinyin]