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

import { MEMO_DATA } from './MockData';
import { MemoInfo } from './MemoInfo';

/**
 * Basic implementation of IDataSource to handle data listener.
 */
class BasicDataSource implements IDataSource {
  // Data change listener.
  private listeners: DataChangeListener[] = [];
  // Data sources that require data iteration.
  private originDataArray: MemoInfo[] = [];

  /**
   * Length of the obtained data.
   */
  public totalCount(): number {
    return 0;
  }

  /**
   * Obtaining a Specified Data Item.
   */
  public getData(index: number): MemoInfo {
    return this.originDataArray[index];
  }

  /**
   * This method is invoked by the framework to add a listener to the data source of the LazyForEach component.
   */
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  /**
   * Disable the listener for the corresponding LazyForEach component at the data source.
   */
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  /**
   * Notify the LazyForEach component that all subcomponents need to be reloaded.
   */
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  /**
   * Notify the LazyForEach component that a subcomponent needs to be added to the index.
   */
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  /**
   * This API is used to notify the LazyForEach component that the data corresponding to an index changes.
   */
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  /**
   * Notify LazyForEach that the subcomponent needs to be deleted at the index specified by index.
   */
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }
}

/**
 * Class that implements the BasicDataSource interface.
 * Data source for lazy loading and iteration of memo data.
 */
export class MemoDataSource extends BasicDataSource {
  // Lazy loading data.
  private memoData: Array<MemoInfo> = MEMO_DATA;

  totalCount(): number {
    return this.memoData.length;
  }

  /**
   * Obtaining a Specified Data Item.
   */
  getData(index: number): MemoInfo {
    return this.memoData[index];
  }

  /**
   * Storing Data to the Lazy Loading Data Source
   */
  pushData(data: MemoInfo): void {
    this.memoData.push(data);
    // Add data to the array header.
    this.notifyDataAdd(this.memoData.length - 1);
  }
}