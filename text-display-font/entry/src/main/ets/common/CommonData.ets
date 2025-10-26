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

export class ListItemData {
  id: number;
  content: Resource;
  type: Resource = $r('app.string.home');
  source: Resource = $r('app.string.home');
  time: Resource = $r('app.string.time');

  constructor(id: number, content: Resource, type: Resource) {
    this.id = id;
    this.content = content;
    this.type = type;
  }
}

// Homepage List Content
export const listData: ListItemData[] = [
  new ListItemData(0, $r('app.string.content1'), $r('app.string.type1')),
  new ListItemData(1, $r('app.string.content2'), $r('app.string.type2')),
  new ListItemData(2, $r('app.string.content3'), $r('app.string.type1')),
  new ListItemData(3, $r('app.string.content4'), $r('app.string.type2')),
  new ListItemData(4, $r('app.string.content5'), $r('app.string.type1')),
  new ListItemData(5, $r('app.string.content1'), $r('app.string.type2')),
  new ListItemData(6, $r('app.string.content2'), $r('app.string.type1')),
  new ListItemData(7, $r('app.string.content3'), $r('app.string.type1')),
];

// System font size ratio and font thickness
export interface FontType {
  fontSizeScale: number | undefined,
  fontWeightScale: number | undefined
}