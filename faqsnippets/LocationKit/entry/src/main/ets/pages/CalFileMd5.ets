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
* FAQ:如何校验文件一致性
 */

// [Start calFileMd5]
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { fileIo } from '@kit.CoreFileKit'
import { buffer } from '@kit.ArkTS';

async function calFileMd5(fileUrl: string) {
  let md = cryptoFramework.createMd('MD5');
  let file = fileIo.openSync(fileUrl, fileIo.OpenMode.READ_ONLY);
  let arrayBuffer = new ArrayBuffer(2048);
  let len: number = 0;
  let position: number = 0;
  do {
    len = fileIo.readSync(file.fd, arrayBuffer, { offset: position });
    if (len > 0) {
      let uint8Array = new Uint8Array(arrayBuffer.slice(0, len));
      let updateMessageBlob: cryptoFramework.DataBlob = { data: uint8Array };
      await md.update(updateMessageBlob);
      position += len;
    }
  } while (len > 0);
  fileIo.closeSync(file);
  let mdOutput = await md.digest();
  console.info('...calFileMd5: ' + buffer.from(mdOutput.data).toString('hex'));
}

// [End calFileMd5]