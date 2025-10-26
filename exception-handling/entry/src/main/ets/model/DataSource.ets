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

import { PreferencesManager } from './PreferencesManager';

// Basic implementation of IDataSource to handle data listener
class BasicDataSource implements IDataSource {
  // Data change listener
  private listeners: DataChangeListener[] = [];
  // Data sources that require data iteration
  private originDataArray: string[] = [];

  // Obtain the length of data
  public totalCount(): number {
    return 0;
  }

  // Get specified data items
  public getData(index: number): string {
    return this.originDataArray[index];
  }

  // This method is called on the framework side to add a listener listener
  // to the LazyForEach component's data source for listening
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      console.info('add listener');
      this.listeners.push(listener);
    }
  }

  // This method is called on the framework side to remove listener listening
  // at the data source for the corresponding LazyForEach component
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      console.info('remove listener');
      this.listeners.splice(pos, 1);
    }
  }

  // Notify LazyForEach component to overload all child components
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  // Notify LazyForEach component to add sub components at
  // the index corresponding to the index
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  // Notify the LazyForEach component that there is a change in data at
  // the index corresponding to the index, and that the subcomponent needs to be rebuilt
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  // Notify LazyForEach component to delete the subcomponent at the index corresponding to the index
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }
}

export class FaultDataSource extends BasicDataSource {
  // Lazy loading data
  private faultMessage: Array<string> = [];

  // Knowledge point: Obtaining the data length of lazy loading data sources
  totalCount(): number {
    return this.faultMessage.length;
  }

  // Get specified data items
  getData(index: number): string {
    return this.faultMessage[index];
  }

  // Knowledge point: Storing data into lazy loading data sources
  pushData(data: string): void {
    this.faultMessage.unshift(data);
    // Add data to the array header
    this.notifyDataAdd(0);
    AppStorage.setOrCreate('faultDataSourceLength', this.totalCount());
  }

  // Knowledge point: Persisting storage exception information collection
  persistenceStorage(): void {
    PreferencesManager.putFaultMessage(this.faultMessage);
  }
}