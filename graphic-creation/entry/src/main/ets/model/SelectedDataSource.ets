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

export class SelectedDataSource implements IDataSource {
  private data: PixelMap[] = [];
  private listenerMap: HashSet<DataChangeListener> = new HashSet();

  unshiftData(pixelMap: PixelMap) {
    this.data.unshift(pixelMap);
    for (let i = 0; i < this.data.length; i++) {
      this.notifyAddData(i);
    }
  }

  deleteData(index: number) {
    this.data.splice(index, 1);
    this.notifyDeleteData(index);
  }

  private notifyDeleteData(index: number) {
    this.listenerMap.forEach((listener: DataChangeListener) => {
      listener.onDataDelete(index);
    })
  }

  addData(pixelMap: PixelMap) {
    this.data.push(pixelMap);
    this.notifyAddData(this.data.length - 1);
  }

  private notifyAddData(index: number) {
    this.listenerMap.forEach((listener: DataChangeListener) => {
      listener.onDataAdd(index);
    });
  }

  totalCount(): number {
    return this.data.length;
  }

  getData(index: number): PixelMap {
    return this.data[index];
  }

  getItemIndex(item: PixelMap): number {
    return this.data.indexOf(item);
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    this.listenerMap.add(listener);
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    this.listenerMap.remove(listener);
  }
}