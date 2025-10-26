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

import { CommonConstants } from '../common/constants/CommonConstants';

export class User {
  public id: string = CommonConstants.EMPTY_STRING;
  public name: string = CommonConstants.EMPTY_STRING;
  public account: string = CommonConstants.EMPTY_STRING;
  public nickname: string = CommonConstants.EMPTY_STRING;
  public age: string = CommonConstants.EMPTY_STRING;

  public setId(id: string): void {
    this.id = id;
  }

  public setName(name: string): void {
    this.name = name;
  }

  public setNickName(nickname: string): void {
    this.nickname = nickname;
  }

  public setAge(age: string): void {
    this.age = age;
  }

  public setAccount(account: string): void {
    this.account = account;
  }
}