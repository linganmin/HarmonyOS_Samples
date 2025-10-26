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

export abstract class BasicDataSource<T> implements IDataSource {
  private listeners: DataChangeListener[] = [];

  public abstract totalCount(): number;

  public abstract getData(index: number): T | void;

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos > 0) {
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataAdd(index);
    })
  }
}

/**
 * product introduction data model
 */
export class ProductIntroductionModel {
  id: string;
  icon: Resource;
  title: ResourceStr;

  constructor(id: string, icon: Resource, title: ResourceStr) {
    this.id = id;
    this.icon = icon;
    this.title = title;
  }
}

/**
 * product detail data model
 */
export class ProductDetailModel {
  id: string;
  title: ResourceStr;
  icon: Resource;
  des: ResourceStr;
  price: ResourceStr;

  constructor(id: string, title: ResourceStr, icon: Resource, des: ResourceStr, price: ResourceStr) {
    this.id = id;
    this.title = title;
    this.icon = icon;
    this.des = des;
    this.price = price;
  }
}