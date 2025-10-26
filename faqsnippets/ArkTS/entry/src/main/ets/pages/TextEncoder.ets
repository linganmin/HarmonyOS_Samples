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
* FAQ:如何实现字符串编解码
 */

// [Start text_encoder]
import { util } from '@kit.ArkTS';
// Create Encoder
let textEncoder:util.TextEncoder = new util.TextEncoder('gbk');
let buffer:ArrayBuffer = new ArrayBuffer(20);
let encodeResult:Uint8Array = new Uint8Array(buffer);


// code
encodeResult = textEncoder.encodeInto('hello');
console.info('Encode result: ', encodeResult);


// Create decoder
let textDecoder = util.TextDecoder.create('gbk');


// decode
let decodeResult = textDecoder.decodeToString(encodeResult);
console.info('Decode result: ', decodeResult);
// [End text_encoder]