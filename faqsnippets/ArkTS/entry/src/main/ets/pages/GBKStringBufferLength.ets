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
import { util } from '@kit.ArkTS';

/*
* FAQ:gbk字符串TextEncoder编码结果属性buffer长度为何比编码结果长度略大
*/

// [Start GBKStringBufferLength]
let textEncoder = util.TextEncoder.create('gbk');
let rstEncodeData: Uint8Array = textEncoder.encodeInto('你好abc');
let length = rstEncodeData.length;
console.info("rstEncodeData.length = " + length);
let byteLength = rstEncodeData.buffer.byteLength;
console.info("rstEncodeData.buffer.byteLength = " + byteLength);
console.info("rstEncodeData.buffer.slice(0, length).byteLength = " + rstEncodeData.buffer.slice(0, length).byteLength);
// rstEncodeData.buffer.slice(0, length).byteLength = 7
// [End GBKStringBufferLength]
