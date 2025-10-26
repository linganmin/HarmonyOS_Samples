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

import { NetworkUtil } from '../utils/NetworkUtil';
import { WaterFlowData } from './WaterFlowData';
import { CommonConstants } from '../constants/CommonConstants';

export class WaterFlowListData {
  public dataSource: BasicDataSource = new BasicDataSource();
  public netWorkUtil: NetworkUtil = new NetworkUtil();

  getData(): BasicDataSource {
    return this.dataSource;
  }

  async addData(fileName: string, pageNo: number, pageSize: number): Promise<void> {
    let tmp: WaterFlowData[] =
      await this.netWorkUtil.getWaterFlowData(CommonConstants.MOCK_INTERFACE_PATH_NAME, fileName, pageNo, pageSize);
    this.dataSource.addData(tmp);
  }
}

class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: WaterFlowData[] = [];

  totalCount(): number {
    return this.originDataArray.length;
  }

  getData(index: number): WaterFlowData {
    return this.originDataArray[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < CommonConstants.ARR_FIRST_INDEX) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= CommonConstants.ARR_FIRST_INDEX) {
      this.listeners.splice(pos, CommonConstants.DEAL_COUNT_ONE);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    });
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    });
  }

  public addData(data: WaterFlowData[]): void {
    let len = this.originDataArray.length;
    this.originDataArray = this.originDataArray.concat(data);
    this.notifyDataAdd(len);
  }

  public clearData(): void {
    this.originDataArray = [];
    this.notifyDataReload();
  }
}