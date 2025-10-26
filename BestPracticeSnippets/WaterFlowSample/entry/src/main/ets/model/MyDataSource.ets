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

import { BasicDataSource } from "./BasicDataSource";

export class MyDataSource extends BasicDataSource<number> {
  private cursorOffset: number = 0;

  public totalCount(): number {
    return this.dataArray.length - this.cursorOffset;
  }

  getData(index: number): number {
    return this.dataArray[index + this.cursorOffset];
  }

  public addData(index: number, data: number): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: number): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  public getTopMastData(num: number): number[] {
    this.cursorOffset = num;
    return this.dataArray.slice(0, num);
  }
}