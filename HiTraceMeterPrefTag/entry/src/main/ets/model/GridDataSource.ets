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
/**
 * Grid data source.
 */
export class MyDataSource implements IDataSource {
  private dataArray: string[] = [];

  /**
   * Add data.
   */
  public pushData(data: string): void {
    this.dataArray.push(data);
  }

  /**
   * Total data count.
   */
  public totalCount(): number {
    return this.dataArray.length;
  }

  /**
   * Return the data of index.
   */
  public getData(index: number): string {
    return this.dataArray[index];
  }

  /**
   * Register data change listener.
   */
  registerDataChangeListener(listener: DataChangeListener): void {
  }

  /**
   * Unregister data change listener.
   */
  unregisterDataChangeListener(listener: DataChangeListener): void {
  }
}