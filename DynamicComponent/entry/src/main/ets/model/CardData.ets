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

import { hilog } from '@kit.PerformanceAnalysisKit';

// [Start CardData_start]
export class CardData {
  private id: string = '';
  private mIsAdCard: boolean = false;

  constructor(isAdCard: boolean, id: string) {
    this.mIsAdCard = isAdCard;
    this.id = id;
  }
  // [StartExclude CardData_start]
  public isAdCard(): boolean {
    return this.mIsAdCard;
  }

  public getId(): string {
    return this.id;
  }
  // [EndExclude CardData_start]
}
// [End CardData_start]


// Basic implementation of IDataSource to handle data listener
class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: CardData[] = [];

  public totalCount(): number {
    return 0;
  }

  public getData(index: number): CardData {
    return this.originDataArray[index];
  }

  // This method is invoked by the framework to add
  // the listener to the data source for the corresponding LazyForEach component.
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      hilog.info(0x0000, 'CardData', 'add listener');
      this.listeners.push(listener);
    }
  }

  // This method is invoked by the framework side to remove
  // the listener at the data source for the corresponding LazyForEach component.
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      hilog.info(0x0000, 'CardData', 'remove listener');
      this.listeners.splice(pos, 1);
    }
  }

  // Notify the LazyForEach component that all subcomponents need to be reloaded.
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  // Notify the LazyForEach component that a subcomponent needs to be added to the index.
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  // Notifies LazyForEach that the subcomponent corresponding to the index has changed and needs to be rebuilt.
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  // Notifies LazyForEach that the subcomponent corresponding to the index needs to be delete.
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }
}

export class CardDataSource extends BasicDataSource {
  private dataArray: CardData[] = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): CardData {
    return this.dataArray[index];
  }

  public addData(index: number, data: CardData): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: CardData): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }
}