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
* FAQ:如何用已有证书做RSA的公钥加密
*/

// [Start RsaPubKeyEncrypt]
import { cryptoFramework } from '@kit.CryptoArchitectureKit';

async function rsaPubKeyEncrypt(pubKey: cryptoFramework.PubKey, plainText: cryptoFramework.DataBlob) {
  try {
    let asyKeyGenerator = cryptoFramework.createAsyKeyGenerator('RSA1024');
    let keyGenPromise: cryptoFramework.KeyPair =
      await asyKeyGenerator.convertKey({ data: pubKey.getEncoded().data }, null);
    let cipher = cryptoFramework.createCipher('RSA1024|PKCS1');
    await cipher.init(cryptoFramework.CryptoMode.ENCRYPT_MODE, keyGenPromise.pubKey, null);
    let encryptData = await cipher.doFinal(plainText);
    return uint8ArrayToHexStr(encryptData.data);
  } catch (err) {
    console.info(err);
    return uint8ArrayToHexStr(new Uint8Array());
  }
}
// [End RsaPubKeyEncrypt]

// [Start RsaPubKeyEncrypt2]
function uint8ArrayToHexStr(data: Uint8Array): string {
  let hexString = '';
  let i: number;
  for (i = 0; i < data.length; i++) {
    let char = ('00' + data[i].toString(16)).slice(-2);
    hexString += char;
  }
  return hexString;
}
// [End RsaPubKeyEncrypt2]