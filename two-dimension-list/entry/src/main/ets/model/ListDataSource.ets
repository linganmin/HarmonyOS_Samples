/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { CommonConstants } from '../common/CommonConstants';
import { GoodsName, MessageItem, MessageList } from './MessageList';

const createMessageList = (): MessageItem[] => {
  let result = new Array<MessageItem>();
  for (let i = 0; i < CommonConstants.LOOP_COUNT; i++) {
    result = result.concat(MessageList);
  }
  return result;
}

const createGoodsNameListRange = (): string[] => {
  let result = new Array<string>();
  for (let i = 0; i < CommonConstants.LOOP_COUNT; i++) {
    result = result.concat(GoodsName);
  }
  return result;
}

class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];

  public totalCount(): number {
    return 0;
  }

  public getData(index: number): MessageItem | string | undefined {
    return undefined;
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const position = this.listeners.indexOf(listener);
    if (position >= 0) {
      this.listeners.splice(position, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataReloaded();
    })
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataAdd(index);
    })
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataChange(index);
    })
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataDelete(index);
    })
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataMove(from, to);
    })
  }
}

export class MessageListDataSource extends BasicDataSource {
  private listData = createMessageList();

  public totalCount(): number {
    return this.listData.length;
  }

  public getData(index: number): MessageItem {
    return this.listData[index];
  }

  public pushData(): void {
    if (this.listData.length < CommonConstants.MAX_DATA_LENGTH) {
      this.listData.concat(MessageList);
      this.notifyDataAdd(this.listData.length - 1);
    }
  }
}

export class GoodsNameListDataSource extends BasicDataSource {
  private listData = createGoodsNameListRange();

  public totalCount(): number {
    return this.listData.length;
  }

  public getData(index: number): string {
    return this.listData[index];
  }

  public getIndex(item: string): number {
    for (let i = 0; i < this.listData.length; i++) {
      if (this.listData[i] === item) {
        return i;
      }
    }
    return 0;
  }

  public pushData(): void {
    if (this.listData.length < CommonConstants.MAX_DATA_LENGTH) {
      this.listData.concat(GoodsName);
      this.notifyDataAdd(this.listData.length - 1);
    }
  }
}