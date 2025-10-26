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
* FAQ:如何使用实现汉字转拼音
*/

// [Start toPingYin]
import { i18n } from '@kit.LocalizationKit';

let transliterator = i18n.Transliterator.getInstance('Any-Latn');
let res: string = transliterator.transform('中国'); // res = 'zhōng guó'

// Remove voice parts
let voiceRemovedTransliterator = i18n.Transliterator.getInstance('Latin-ASCII');
let res2 = voiceRemovedTransliterator.transform(res);
console.info('去除声部后拼音为：',res2);
// [End toPingYin]