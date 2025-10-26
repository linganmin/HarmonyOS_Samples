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

import { StandardButtonListItem } from "../view/StandardButtonList";

export class MenuViewModel {
  private data: StandardButtonListItem[] = [];

  constructor() {
    this.data.push(new StandardButtonListItem('Demo01',
      $r('app.string.text1')));
    this.data.push(new StandardButtonListItem('Demo02',
      $r('app.string.text2')));
    this.data.push(new StandardButtonListItem('Demo03',
      $r('app.string.text3')));
  }

  public getData(): StandardButtonListItem[] {
    return this.data;
  }
}
