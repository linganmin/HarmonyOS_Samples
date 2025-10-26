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

export class TabDataModel {
  private tabMap: Map<string, string[]>;

  constructor(tabMap: Map<string, string[]>) {
    this.tabMap = tabMap;
  }

  getTabMap(): Map<string, string[]> {
    return this.tabMap;
  }

  getFirstList(): string[] {
    let firstList: string[] = [];
    let index: number = 0;
    this.tabMap.forEach((_value: string[], key: string) => {
      firstList[index] = key;
      index++;
    }, (value: string[], key: string) => JSON.stringify(value) + key);
    return firstList;
  }

  getSecondList(firstTab: string): string[] {
    if (this.tabMap.has(firstTab) && this.tabMap.get(firstTab)) {
      return this.tabMap.get(firstTab)!;
    } else {
      return [];
    }
  }
}