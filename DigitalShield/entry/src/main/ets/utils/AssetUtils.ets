/*
* Copyright (c) 2025 Huawei Device Co., Ltd.
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
import { asset } from '@kit.AssetStoreKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000

class AssetUtils {
  hasShield: boolean = false;

  stringToArray(str: string): Uint8Array {
    let textEncoder: util.TextEncoder = new util.TextEncoder();
    return textEncoder.encodeInto(str);
  }

  DeleteDataFromAssetStore(name: string): void {
    let query: asset.AssetMap = new Map();
    query.set(asset.Tag.ALIAS, this.stringToArray(name));
    try {
      asset.remove(query).then(() => {
        hilog.info(DOMAIN, 'testTag', 'Asset removed successfully');
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, 'testTag', `Failed to remove Asset. Code is ${err.code}, message is ${err.message}`);
      });
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(DOMAIN, 'testTag', `Failed to remove Asset. Code is ${err.code}, message is ${err.message}`);
    }
  }

  AddDataToAssetStore(data: Uint8Array, name: string, label: string): void {
    let attr: asset.AssetMap = new Map();
    hilog.info(DOMAIN, 'testTag', 'secret input', data);
    attr.set(asset.Tag.SECRET, data);
    attr.set(asset.Tag.ALIAS, this.stringToArray(name));
    attr.set(asset.Tag.ACCESSIBILITY, asset.Accessibility.DEVICE_FIRST_UNLOCKED);
    attr.set(asset.Tag.DATA_LABEL_NORMAL_1, this.stringToArray(label));
    try {
      asset.add(attr).then(() => {
        hilog.info(DOMAIN, 'testTag', 'Asset Added successfully');
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, 'testTag', `Failed to add Asset. Code is ${err.code}, message is ${err.message}`);
        if (err.code === 24000003) {
          this.UpdateDataToAssetStore(data, name, label);
        }
      });
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(DOMAIN, 'testTag', `Failed to add Asset. Code is ${err.code}, message is ${err.message}`);
    }
  }

  UpdateDataToAssetStore(newData: Uint8Array, name: string, label: string): void {
    let query: asset.AssetMap = new Map();
    query.set(asset.Tag.ALIAS, this.stringToArray(name));
    let attrsToUpdate: asset.AssetMap = new Map();
    attrsToUpdate.set(asset.Tag.SECRET, newData);
    attrsToUpdate.set(asset.Tag.DATA_LABEL_NORMAL_1, this.stringToArray(label));
    try {
      asset.update(query, attrsToUpdate).then(() => {
        hilog.info(DOMAIN, 'testTag', 'Asset updated successfully');
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, 'testTag', `Failed to update Asset. Code is ${err.code}, message is ${err.message}`);
      });
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(DOMAIN, 'testTag', `Failed to update Asset. Code is ${err.code}, message is ${err.message}`);
    }
  }

  async QueryDataFromAssetStore(name: string): Promise<Uint8Array>{
    let query: asset.AssetMap = new Map();
    query.set(asset.Tag.ALIAS, this.stringToArray(name));
    query.set(asset.Tag.RETURN_TYPE, asset.ReturnType.ALL);
    let emptyArray = new Uint8Array(0);
    hilog.info(DOMAIN, 'testTag', 'Asset query begin');
    try {
      hilog.info(DOMAIN, 'testTag', 'Asset query begin in try');
      let res: Array<asset.AssetMap> = await asset.query(query);
      for (let i = 0; i < res.length; i++) {
        hilog.info(DOMAIN, 'testTag', 'Asset query begin in loop');
        let secret: Uint8Array = res[i].get(asset.Tag.SECRET) as Uint8Array;
        hilog.info(DOMAIN, 'testTag', 'secret output', secret);
        return secret;
      }
      hilog.info(DOMAIN, 'testTag', 'Asset query begin again');
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(DOMAIN, 'testTag', `Failed to query Asset. Code is ${err.code}, message is ${err.message}`);
      return emptyArray;
    }
    return emptyArray;
  }
}

export default new AssetUtils();