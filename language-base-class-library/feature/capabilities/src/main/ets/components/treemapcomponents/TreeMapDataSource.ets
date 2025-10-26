/*
* Copyright (c) 2024 Hunan OpenValley Digital Industry Development Co., Ltd.
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

import { TreeMap, ArrayList } from '@kit.ArkTS';
import { BaseDataSource } from '@ohos/common';
import { KeyValuePair } from '../../model/KeyValuePair';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class TreeMapDataSource extends BaseDataSource {
  private dataArr: TreeMap<string, string> = new TreeMap();
  private arr: ArrayList<string> = new ArrayList();

  public totalCount(): number {
    return this.arr.length;
  }

  public getData(index: number): KeyValuePair {
    let keyValuePair: KeyValuePair = new KeyValuePair('', '');
    try {
      let key: string = this.arr[index];
      let value: string = this.dataArr.get(key);
      this.dataArr.get(this.arr[index]);
      keyValuePair = new KeyValuePair(`${this.arr[index]}`, value);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'TreeMapDataSource', `getData failed, error code=${err.code}, message=${err.message}`);
    }
    return keyValuePair;
  }

  public addData(keyValuePair: KeyValuePair): void {
    try {
      if (!this.dataArr.hasKey(keyValuePair.key)) {
        this.arr.add(keyValuePair.key)
      }
      this.dataArr.set(keyValuePair.key, keyValuePair.value);
      this.notifyDataChange(this.dataArr.length - 1);
      this.notifyDataReload();
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'TreeMapDataSource', `addData failed, error code=${err.code}, message=${err.message}`);
    }
  }

  public deleteData(key: string): void {
    try {
      this.dataArr.remove(key);
      let index = this.arr.getIndexOf(key);
      this.arr.remove(key);
      this.notifyDataDelete(index);
      this.notifyDataReload();
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'TreeMapDataSource', `deleteData failed, error code=${err.code}, message=${err.message}`);
    }
  }
}