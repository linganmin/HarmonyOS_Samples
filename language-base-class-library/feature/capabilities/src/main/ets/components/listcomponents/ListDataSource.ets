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

import { List} from '@kit.ArkTS';
import { BaseDataSource } from '@ohos/common';
import { Information } from '../../model/Information';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class ListDateSource extends BaseDataSource {
  private dataArr: List<Information> = new List();

  public totalCount(): number {
    return this.dataArr.length;
  }

  public getData(index: number): Information {
    try {
      return this.dataArr.get(index);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'ListDateSource', `getData failed, error code=${err.code}, message=${err.message}`);
      return new Information('', 0, '');
    }
  }

  public addData(information: Information): void {
    try {
      this.dataArr.add(information);
      this.notifyDataAdd(this.dataArr.length - 1);
      this.notifyDataReload();
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'ListDateSource', `addData failed, error code=${err.code}, message=${err.message}`);
    }
  }

  public deleteData(index: number): void {
    try {
      this.dataArr.removeByIndex(index);
      this.notifyDataDelete(index);
      this.notifyDataReload();
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'ListDateSource', `deleteData failed, error code=${err.code}, message=${err.message}`);
    }
  }
}