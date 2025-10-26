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
import { soter } from '@kit.OnlineAuthenticationKit'

/* sample data */

export class SoterModel {
  public generateAppSecureKey(keyType: soter.KeyType): Promise<Uint8Array> {
    // 检查ASK是否开通
    if (soter.hasAppSecureKeySync(keyType)) {
      return soter.getAppSecureKey(keyType);
    } else {
      return soter.generateAppSecureKey(keyType);
    }

  }

  public generateAuthKey(keyType: soter.KeyType, keyAlias: string): Promise<soter.SignedResult> {
    // 检查AK是否开通
    if (soter.hasAuthKeySync(keyAlias, keyType)) {
      return soter.getAuthKey(keyAlias, keyType);
    } else {
      return soter.generateAuthKey(keyAlias, keyType);
    }

  }

  public auth(keyAlias: string, authToken: Uint8Array, info: string): soter.SignedResult {
    if (authToken === null) {
      console.error('invalid parameters!');
      throw new Error('invalid parameters!');
    }
    return soter.signWithAuthKeySync(keyAlias, authToken, info);
  }

  public deleteAuthKey(keyAlias: string): Promise<void> {
    return soter.deleteAuthKey(keyAlias);
  }

  public getChallenge(keyAlias: string): Uint8Array {
    return soter.generateChallengeSync(keyAlias);
  }
}

let soterWrapper = new SoterModel();

export default soterWrapper as SoterModel;
