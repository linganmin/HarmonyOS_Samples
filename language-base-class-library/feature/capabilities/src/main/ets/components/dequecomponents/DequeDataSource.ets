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

import { Deque } from '@kit.ArkTS';
import { BaseDataSource } from '@ohos/common';
import { Information } from '../../model/Information';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class DequeDataSource extends BaseDataSource {
  private deque = new Deque<Information>();

  public totalCount(): number {
    return this.deque.length
  }

  public getData(index: number): Information {
    return this.deque[index]
  }

  public insertFront(information: Information): void {
    try {
      this.deque.insertFront(information);
      this.deque.forEach((value, index) => {
        value.clickAble = index === 0 || index === this.deque.length - 1;
      });
      this.notifyDataReload();
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'DequeDataSource', `insertFront failed, error code=${err.code}, message=${err.message}`);
    }
  }

  public insertEnd(information: Information): void {
    try {
      this.deque.insertEnd(information);
      this.deque.forEach((value, index) => {
        value.clickAble = index === 0 || index === this.deque.length - 1;
      });
      this.notifyDataReload();
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'DequeDataSource', `insertEnd failed, error code=${err.code}, message=${err.message}`);
    }
  }

  public deleteFront(): void {
    try {
      this.deque.popFirst();
      this.deque.forEach((value, index) => {
        value.clickAble = index === 0 || index === this.deque.length - 1;
      });
      this.notifyDataReload();
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'DequeDataSource', `deleteFront failed, error code=${err.code}, message=${err.message}`);
    }
  }

  public deleteEnd(): void {
    try {
      this.deque.popLast();
      this.deque.forEach((value, index) => {
        value.clickAble = index === 0 || index === this.deque.length - 1;
      });
      this.notifyDataReload();
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'DequeDataSource', `deleteEnd failed, error code=${err.code}, message=${err.message}`);
    }
  }
}