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
* FAQ:如何合并两个列表并支持懒加载
*/

// [Start merge_two_lists_and_support_lazy_loading_two]
// DataUtil.ets
export class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: string[] = [];


  public totalCount(): number {
    return 0;
  }


  public getData(index: number): string {
    return this.originDataArray[index];
  }


  // This method is called on the framework side to add listener listening to the LazyForEach component at its data source
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      console.info('add listener');
      this.listeners.push(listener);
    }
  }


  // This method is called on the framework side to remove listener listening for the corresponding LazyForEach component at the data source
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      console.info('remove listener');
      this.listeners.splice(pos, 1);
    }
  }


  // Notify LazyForEach component to reload all child components
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }


  // Notify LazyForEach component to add a sub component at the index corresponding to the index
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }


  // Notify LazyForEach component that there is a change in data at the index corresponding to the index, and that the sub component needs to be rebuilt
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }


  // Notify LazyForEach component to remove the sub component at the index corresponding to the index
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }


  // Notify LazyForEach component to swap the subcomponents at the from index and to index
  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    })
  }
}


export class MyDataSource extends BasicDataSource {
  private dataArray: string[] = [];


  public totalCount(): number {
    return this.dataArray.length;
  }


  public getData(index: number): string {
    return this.dataArray[index];
  }


  public addData(index: number, data: string): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }


  public pushData(data: string): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }
}
// [End merge_two_lists_and_support_lazy_loading_two]