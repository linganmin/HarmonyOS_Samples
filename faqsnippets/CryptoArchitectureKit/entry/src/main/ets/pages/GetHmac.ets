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
* FAQ:如何使用SM3算法进行消息认证码计算
*/

// [Start GetHmac]
import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { buffer } from '@kit.ArkTS';

@Entry
@Component
struct Hmac {
  @State message: string = 'Hello World';

  build() {
    Row() {
      Column() {
        Button('使用SM3算法进行消息鉴别码计算')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            getHmac('密钥')
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}

// Convert understandable strings into byte streams
function stringToUint8Array(str: string) {
  let arr = new Uint8Array(str.length);
  for (let i = 0, j = str.length; i < j; ++i) {
    arr[i] = str.charCodeAt(i);
  }
  return arr;
}

async function getHmac(message:string){

  try {
    let macAlgName = 'SM3';
    let mac =cryptoFramework.createMac(macAlgName)
    let arr = stringToUint8Array('30a86dc9056c44cc05420fec269270214bbb6914954e871e83771c9810ac1db0')
    let KeyBlob: cryptoFramework.DataBlob = {data:arr};
    let symKeyGenerator = cryptoFramework.createSymKeyGenerator('HMAC');
    const  symKey=await symKeyGenerator.convertKey(KeyBlob);
    await mac.init(symKey)
    await mac.update({data:stringToUint8Array(message)});
    let macOutpt= await mac.doFinal();
    const res=buffer.from(macOutpt.data).toString('hex');
    console.log('Hmac---:'+res);
  }catch (err){
    console.log('err:'+err)
  }

}
// [End GetHmac]