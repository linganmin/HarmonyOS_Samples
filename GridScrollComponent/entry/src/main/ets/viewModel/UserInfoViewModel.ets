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

import { image } from '@kit.ImageKit';
import { UserInfoModel } from '../model/UserInfoModel';

@Observed
export default class UserInfoViewModel {
  id: number = IdGenerator.INSTANCE.generate();
  @Track role: string = 'user';
  @Track icon: string = '';
  @Track name: string = '';
  @Track abilities: string[] = [];
  @Track updateTime: string = '';
  @Track iconPixelMap?: image.PixelMap;

  updateModel(user: UserInfoModel) {
    this.role = user.role;
    this.icon = user.icon;
    this.name = user.name;
    this.abilities = user.abilities.concat();
    this.updateTime = user.updateTime;
  }
}

class IdGenerator {
  static INSTANCE: IdGenerator = new IdGenerator();
  private currentId: number = 0;

  public generate(): number {
    this.currentId++;
    return this.currentId;
  }
}