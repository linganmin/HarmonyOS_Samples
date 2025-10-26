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

export class Todo {
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

  private _finished: boolean;

  public set finished(value: boolean) {
    this._finished = value;
  }

  public get finished(): boolean {
    return this._finished;
  }

  private _date: string;

  public set date(value: string) {
    this._date = value;
  }

  public get date(): string {
    return this._date;
  }

  private _time: string;

  public set time(value: string) {
    this._time = value;
  }

  public get time(): string {
    return this._time;
  }

  constructor(
    id: string,
    text: ResourceStr,
    date: string = '2024年10月15日',
    finished: boolean = false,
    time: string = '08:00'
  ) {
    this._id = id;
    this._text = text;
    this._finished = finished;
    this._date = date;
    this._time = time;
  }
}