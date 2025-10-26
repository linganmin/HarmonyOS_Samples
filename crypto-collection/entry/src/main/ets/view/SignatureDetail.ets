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

import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { buffer } from '@kit.ArkTS';
import CommonConstants from '../constants/CommonConstants';
import { SignatureItem } from '../viewmodel/SignatureItem';
import { genRsa2048KeyPairSpec } from '../utils/SignatureUtil';
import { getResourceString } from '../utils/ResourceString';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Builder
export function SignatureDetailBuilder() {
  SignatureDetail();
}

const TAG: string = 'SignatureDetail';

@Component
export struct SignatureDetail {
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State sign: string = '';
  @State signResult: string = '';
  @State SignatureItem: SignatureItem = new SignatureItem($r('app.string.empty'), '', '', false);
  @State input: cryptoFramework.DataBlob = { data: new Uint8Array(buffer.from(this.sign, 'utf8').buffer) };
  @State keyPair: cryptoFramework.KeyPair | undefined = undefined;
  @State signData: cryptoFramework.DataBlob = { data: new Uint8Array(buffer.from('', 'utf8').buffer) };
  @State signFlag: boolean = false;

  aboutToAppear(): void {
    this.SignatureItem = this.pageInfos.getParamByName('SignatureDetail')[0] as SignatureItem;
  }

  async signMessagePromise() {
    try {
      if (this.SignatureItem.type === 'RSA1024|PKCS1|SHA256' && this.SignatureItem.isSegment) {
        // PKCS1 segment signature.
        let signAlg = this.SignatureItem.type;
        let signer = cryptoFramework.createSign(signAlg);
        await this.generatorKey();
        let key = this.keyPair as cryptoFramework.KeyPair;
        await signer.init(key.priKey);
        let textSplitLen = 64; // User-defined data splitting length. The value is 64.
        let plainText = new Uint8Array(buffer.from(this.sign, 'utf8').buffer)
        for (let i = 0; i < plainText.length; i += textSplitLen) {
          let updateMessage = plainText.subarray(i, i + textSplitLen);
          let updateMessageBlob: cryptoFramework.DataBlob = { data: updateMessage };
          // Segment update.
          await signer.update(updateMessageBlob);
        }
        let signData = await signer.sign(null);
        this.signData = signData;
      } else if (this.SignatureItem.type === 'RSA|PASS|SHA256|MGF1_SHA256') {
        // Parameters for obtaining an RSA key pair.
        let rsaKeyPairSpec = genRsa2048KeyPairSpec();
        // RSA key pair generator.
        let rsaGeneratorSpec = cryptoFramework.createAsyKeyGeneratorBySpec(rsaKeyPairSpec);
        // Both sign and verfiy support RSA keys with or without length.
        let signer = cryptoFramework.createSign('RSA|PSS|SHA256|MGF1_SHA256');
        let keyPair = await rsaGeneratorSpec.generateKeyPair();
        await signer.init(keyPair.priKey);
        // After the signature is initialized,perform the set and get operations on the PSS parameters.
        let setN = 32;
        signer.setSignSpec(cryptoFramework.SignSpecItem.PSS_SALT_LEN_NUM, setN);
        signer.getSignSpec(cryptoFramework.SignSpecItem.PSS_SALT_LEN_NUM);
        signer.getSignSpec(cryptoFramework.SignSpecItem.PSS_TRAILER_FIELD_NUM);
        signer.getSignSpec(cryptoFramework.SignSpecItem.PSS_MD_NAME_STR);
        signer.getSignSpec(cryptoFramework.SignSpecItem.PSS_MGF_NAME_STR);
        signer.getSignSpec(cryptoFramework.SignSpecItem.PSS_MGF1_MD_STR);
        await signer.update(this.input);
        let signData = await signer.sign(null);
        this.signData = signData;
      } else {
        let signAlg = this.SignatureItem.type;
        let signer = cryptoFramework.createSign(signAlg);
        await this.generatorKey();
        let key = this.keyPair as cryptoFramework.KeyPair;
        await signer.init(key.priKey);
        await signer.update(this.input);
        let signData = await signer.sign(null);
        this.signData = signData;
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `signMessagePromise failed, error code=${err.code}, message=${err.message}`);
    }
  }

  async verifyMessagePromise() {
    try {
      if (this.SignatureItem.type === 'RSA1024|PKCS1|SHA256' && this.SignatureItem.isSegment) {
        let verifyAlg = this.SignatureItem.type;
        let verifier = cryptoFramework.createVerify(verifyAlg);
        let key = this.keyPair as cryptoFramework.KeyPair;
        await verifier.init(key.pubKey);
        let textSplitLen = 64; // User-defined data splitting length. The value is 64.
        let plainText = new Uint8Array(buffer.from(this.sign, 'utf8').buffer)
        for (let i = 0; i < plainText.length; i += textSplitLen) {
          let updateMessage = plainText.subarray(i, i + textSplitLen);
          let updateMessageBlob: cryptoFramework.DataBlob = { data: updateMessage };
          // Segment update.
          await verifier.update(updateMessageBlob);
        }
        let res = await verifier.verify(null, this.signData);
        res === true ? this.signResult = 'verify success' : this.signResult = 'verify failed';
      } else if (this.SignatureItem.type === 'RSA|PASS|SHA256|MGF1_SHA256') {
        // Parameters for obtaining an RSA key pair.
        let rsaKeyPairSpec = genRsa2048KeyPairSpec();
        // RSA key pair generator.
        let rsaGeneratorSpec = cryptoFramework.createAsyKeyGeneratorBySpec(rsaKeyPairSpec);
        let verifyer = cryptoFramework.createVerify("RSA2048|PSS|SHA256|MGF1_SHA256");
        let keyPair = await rsaGeneratorSpec.generateKeyPair();
        let setN = 32;
        verifyer.setVerifySpec(cryptoFramework.SignSpecItem.PSS_SALT_LEN_NUM, setN);
        verifyer.getVerifySpec(cryptoFramework.SignSpecItem.PSS_SALT_LEN_NUM);
        verifyer.getVerifySpec(cryptoFramework.SignSpecItem.PSS_TRAILER_FIELD_NUM);
        verifyer.getVerifySpec(cryptoFramework.SignSpecItem.PSS_MD_NAME_STR);
        verifyer.getVerifySpec(cryptoFramework.SignSpecItem.PSS_MGF_NAME_STR);
        verifyer.getVerifySpec(cryptoFramework.SignSpecItem.PSS_MGF1_MD_STR);
        verifyer.initSync(keyPair.pubKey);
        verifyer.updateSync(this.input);
        let verifyResult = verifyer.verifySync(null, this.signData);
        verifyResult === true ? this.signResult = 'verify success' : this.signResult = 'verify failed';
      } else {
        let verifyAlg = this.SignatureItem.type;
        let verifier = cryptoFramework.createVerify(verifyAlg);
        let key = this.keyPair as cryptoFramework.KeyPair;
        await verifier.init(key.pubKey);
        await verifier.update(this.input);
        let res = await verifier.verify(null, this.signData);
        res === true ? this.signResult = 'verify success' : this.signResult = 'verify failed';
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `verifyMessagePromise failed, error code=${err.code}, message=${err.message}`);
    }
  }

  async generatorKey() {
    try {
      let keyGenAlg = this.SignatureItem.keyGenAlg;
      let generator = cryptoFramework.createAsyKeyGenerator(keyGenAlg);
      let keyPair = await generator.generateKeyPair();
      this.keyPair = keyPair;
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `generatorKey failed, error code=${err.code}, message=${err.message}`);
    }
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          TextInput({ text: this.sign, placeholder: $r('app.string.text_signature') })
            .margin({ top: $r('app.float.margin_top_sixteen') })
            .backgroundColor(Color.White)
            .onChange((value) => {
              this.sign = value;
              this.input = { data: new Uint8Array(buffer.from(value, 'utf8').buffer) };
            })

          Column() {
            Text($r('app.string.signature_result'))
              .margin({ left: $r('app.float.margin_left_five') })

            TextInput({ text: this.signResult })
              .margin({ top: $r('app.float.margin_top_sixteen') })
              .backgroundColor(Color.White)
              .enabled(false)
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ top: $r('app.float.margin_top_sixteen') })
        }

        Column() {
          Button() {
            Text($r('app.string.Signed'))
              .fontSize($r('app.float.common_font'))
              .fontColor(Color.White)
          }
          .onClick(() => {
            this.signMessagePromise();
            this.signFlag = true;
          })
          .enabled(this.sign ? true : false)
          .width(CommonConstants.FULL_PERCENT)
          .height($r('app.float.button_height'))
          .margin({ top: $r('app.float.margin_top_sixteen') })

          Button() {
            Text($r('app.string.signature_verification'))
              .fontSize($r('app.float.common_font'))
              .fontColor(Color.White)
          }
          .onClick(() => {
            this.verifyMessagePromise();
            this.signFlag = true;
          })
          .enabled(this.signFlag ? true : false)
          .width(CommonConstants.FULL_PERCENT)
          .height($r('app.float.button_height'))
          .margin({ top: $r('app.float.margin_top_sixteen') })
        }
      }
      .padding({
        left: $r('app.float.medium_padding'),
        right: $r('app.float.medium_padding'),
        bottom: $r('app.float.medium_padding')
      })
      .height(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .title(getResourceString(this.SignatureItem.name, this.getUIContext()))
    .backgroundColor($r('app.color.background_page'))
  }
}