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

@Component
export struct StandardButtonList {
  @Prop data: StandardButtonListItem[];

  build() {
    List({ space: 12 }) {
      ForEach(this.data, (item: StandardButtonListItem) => {
        ListItem() {
          Button(item.text)
            .width('100%')
            .fontSize(16)
            .fontWeight(500)
            .height(40)
            .backgroundColor('rgba(10,89,247)')
            .onClick(item.callback)
        }
      }, (item: StandardButtonListItem) => item.id)
    }
    .width('100%')
  }
}

export class StandardButtonListItem {
  private _id: string;

  public set id(value: string) {
    this._id = value;
  }

  public get id(): string {
    return this._id;
  }

  private _text: ResourceStr;

  public set text(value: ResourceStr) {
    this._text = value;
  }

  public get text(): ResourceStr {
    return this._text;
  }

  private _callback?: (() => void) | undefined;

  public set callback(value: (() => void) | undefined) {
    this._callback = value;
  }

  public get callback(): (() => void) | undefined {
    return this._callback;
  }

  constructor(id: string, text: ResourceStr, callback?: () => void) {
    this._id = id;
    this._text = text;
    this._callback = callback;
  }
}