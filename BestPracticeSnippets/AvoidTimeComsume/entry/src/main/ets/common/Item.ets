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

@Sendable
// [Start item]
export class Item {
  url: string = '';
  id: number = 0;
  name: string = '';
  // [StartExclude item]
  constructor(url:string,id:number,name:string) {
    this.url = url;
    this.id = id;
    this.name = name;
  }
  // [EndExclude item]
}
// [Start item]

export class ResponseData{
  public data: Item[] = [];
}

export function dataToItem(data: object[]): Item[]{
  let arr: Item[] = [];
  for(let dataElement of data){
    let temp = dataElement as Item;
    arr.push(new Item(temp.url,temp.id,temp.name));
  }
  return arr;
}