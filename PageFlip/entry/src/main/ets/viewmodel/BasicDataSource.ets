/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { Constants } from '../common/Constants';

export class BasicDataSource implements IDataSource {
  private elements: string[] = [];
  private listeners: Set<DataChangeListener>;

  constructor(elements: string[]) {
    this.elements = elements;
    this.listeners = new Set();
  }

  public totalCount(): number {
    return this.elements.length;
  }

  public getData(index: number): string {
    return this.elements[index];
  }

  public indexOf(item: string): number {
    return this.elements.indexOf(item);
  }

  public registerDataChangeListener(listener: DataChangeListener): void {
    this.listeners.add(listener);
  }

  public unregisterDataChangeListener(listener: DataChangeListener): void {
    this.listeners.delete(listener);
  }

  public pinItem(item: string, index: number): void {
    this.elements.splice(index, Constants.PAGE_FLIP_ONE);
    this.elements.unshift(item);
    this.listeners.forEach(listeners => listeners.onDataReloaded());
  }

  public addItem(item: string): void {
    this.elements.unshift(item);
    this.listeners.forEach(listeners => listeners.onDataAdd(Constants.PAGE_FLIP_ZERO));
  }

  public pushItem(item: string): void {
    this.elements.push(item);
    this.listeners.forEach(listeners => listeners.onDataAdd(this.elements.length - Constants.PAGE_FLIP_ONE));
  }

  public insertItem(item: string, index: number): void {
    this.elements.splice(index, Constants.PAGE_FLIP_ZERO, item);
    this.listeners.forEach(listeners => listeners.onDataAdd(index));
  }

  public deleteItem(item: string): void {
    const index = this.elements.indexOf(item);
    if (index < Constants.PAGE_FLIP_ZERO) {
      return;
    }
    this.elements.splice(index, Constants.PAGE_FLIP_ONE);
    this.listeners.forEach(listeners => listeners.onDataDelete(index));
  }

  public deleteItemByIndex(index: number): void {
    this.elements.splice(index, Constants.PAGE_FLIP_ONE);
    this.listeners.forEach(listeners => listeners.onDataDelete(index));
  }
}