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
* FAQ:ID Token的使用场景与使用方法
 */

// [Start IdToken3]
import { buffer } from '@kit.ArkTS';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { http } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
class IdToken {
  decodeBase64(data: string): string {
    return buffer.from(data,'base64').toString('utf8');
  }

  // Resolve ID Token and validate it
  decodeIdToken(idToken: string): void {
    const parts = idToken.split('.');
    if (parts.length !== 3) {
      return;
    }
    const idTokenObj: Record<string,Object> = {};
    // ID Token header
    idTokenObj['header'] = JSON.parse(this.decodeBase64(parts[0]));
    // ID Token Load
    idTokenObj['payload'] = JSON.parse(this.decodeBase64(parts[1]));
    // ID Token Signature
    idTokenObj['signature'] = parts[2];
    const header: Record<string,string> = idTokenObj['header'] as Record<string,string>;
    // Parse nonce and other data from the load
    const payLoad: Record<string,string> = idTokenObj['payload'] as Record<string,string>;
    const nonce: string = payLoad['nonce'];
    // Application Client ID, please replace before use
    const CLIENT_ID: string = '<应用Client ID>';
    const ID_TOKEN_ISSUE: string = 'https://accounts.huawei.com';
    const iss: string = payLoad['iss'];
    const aud: string = payLoad['aud'];
    if (iss !== ID_TOKEN_ISSUE) {
      // Verification failed, developers handle failure scenarios
      hilog.error(0x0000,'testTag','Failed to check iss');
      return;
    }
    if (aud !== CLIENT_ID) {
      // Verification failed, developers handle failure scenarios
      hilog.error(0x0000,'testTag','Failed to check aud');
      return;
    }
    // verify signature
    this.checkSignature(idToken,header['kid'],header['alg']);
  }

  private stringToUint8Array(str: string): Uint8Array {
    const arr: number[] = [];
    for (let i = 0,j = str.length; i < j; ++i) {
      arr.push(str.charCodeAt(i));
    }
    const tmpUint8Array: Uint8Array = new Uint8Array(arr);
    return tmpUint8Array;
  }

  // Verification method
  private checkSignature(idToken: string,kid: string,alg: string) {
    if (!idToken) {
      return;
    }
    const parts = idToken.split('.');
    if (parts.length !== 3) {
      return;
    }
    const url = 'https://oauth-login.cloud.huawei.com/oauth2/v3/certs';
    // To create an HTTP request, the application needs to apply for "ohos. permission. INTERNET" network permission
    // in the module.json5 file before the request can be sent successfully
    const httpRequest = http.createHttp();
    httpRequest.request(url,(err,data) => {
      if (err) {
        hilog.error(0x0000,'testTag',`Failed to httpRequest. Code: ${err.code}, message: ${err.message}`);
        httpRequest.destroy();
        return;
      }
      let nStr = '';
      let eStr = '';
      const keys: object[] = JSON.parse(data.result as string)["keys"];
      for (let item of keys) {
        if (kid === item['kid']) {
          nStr = item['n'];
          eStr = item['e'];
          break;
        }
      }
      const nBigInt = '0x' + buffer.from(nStr,"base64url").toString('hex');
      const eBigInt = '0x' + buffer.from(eStr,"base64url").toString('hex');
      const dsaCommonSpec: cryptoFramework.RSACommonParamsSpec = {
        algName: "RSA",
        specType: cryptoFramework.AsyKeySpecType.COMMON_PARAMS_SPEC,
        n: BigInt(nBigInt),
      }
      const rsaKeyPairSpec: cryptoFramework.RSAPubKeySpec = {
        algName: "RSA",
        specType: cryptoFramework.AsyKeySpecType.PUBLIC_KEY_SPEC,
        params: dsaCommonSpec,
        pk: BigInt(eBigInt),
      }
      const asyKeyGeneratorBySpec = cryptoFramework.createAsyKeyGeneratorBySpec(rsaKeyPairSpec);
      asyKeyGeneratorBySpec.generatePubKey(async (error,publicKey) => {
        if (error) {
          return;
        }
        if (publicKey === null) {
          return;
        }
        const idTokenSign = parts[2];
        const idTokenSignArr: cryptoFramework.DataBlob =
          { data: new Uint8Array(buffer.from(idTokenSign,"base64url").buffer) };
        const idToken = parts[0] + '.' + parts[1];
        const idTokenArr: cryptoFramework.DataBlob = { data: this.stringToUint8Array(idToken) };
        const verifier = alg === 'PS256' ? cryptoFramework.createVerify("RSA2048|PSS|SHA256|MGF1_SHA256")
          : cryptoFramework.createVerify("RSA2048|PKCS1|SHA256");
        verifier.init(publicKey,(initErr,result) => {
          verifier.verify(idTokenArr,idTokenSignArr,(verifyErr,data) => {
            // Print the verification result. If the result is true, the verification is passed
            hilog.info(0x0000,'testTag','verify result is: %{public}s',data);
          });
        });
      })
      httpRequest.destroy();
    });
  }
}
// [End IdToken3]
