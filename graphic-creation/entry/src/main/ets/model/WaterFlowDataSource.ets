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
import { HashSet } from '@kit.ArkTS';

export class WaterFlowDataSource implements IDataSource {
  public dataList: WaterFlowData[] = []
  private listeners: HashSet<DataChangeListener> = new HashSet()
  private authorArray =
    [$r('app.string.author_1'), $r('app.string.author_2'), $r('app.string.author_3'), $r('app.string.author_4')];

  constructor() {
    for (let i = 0; i < 20; i++) {
      this.dataList.push({
        coverPath: $rawfile(`picture/${i % 6}.png`),
        descriptions: $r('app.string.descriptions'),
        author: this.authorArray[i % 4],
        favorites: $r('app.string.favorites_number'),
      });
    }
  }

  addPageData() {
    for (let i = 0; i < 10; i++) {
      this.dataList.push({
        coverPath: $rawfile(`picture/${i % 6}.png`),
        descriptions: $r('app.string.descriptions'),
        author: this.authorArray[i % 4],
        favorites: $r('app.string.favorites_number'),
      });
    }
    this.notifyDataAdd(this.dataList.length - 1)
  }

  totalCount(): number {
    return this.dataList.length;
  }

  getData(index: number): WaterFlowData {
    return this.dataList[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    this.listeners.add(listener);
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    this.listeners.remove(listener)
  }

  onDataAdd(data: WaterFlowData) {
    this.dataList.unshift(data)
    this.notifyDataAdd(0);
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener?.onDataAdd(index);
    })
  }
}


export declare class WaterFlowData {
  public coverPath: string | Resource
  public descriptions: string | Resource
  public favorites: string | Resource
  public author: Resource
}