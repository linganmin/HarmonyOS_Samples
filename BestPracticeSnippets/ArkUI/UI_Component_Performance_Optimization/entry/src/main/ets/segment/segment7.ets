/*
* Copyright (C) 2025 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

// [Start Case5]
import { util } from '@kit.ArkTS';

interface User {
  id: string;
  name: string;
  age?: number;
  avatarImage?: ResourceStr;
  //introduction: string;
  // ...
}

// create data
const DEFAULT_BACKGROUND_COLOR = Color.Pink;
const getUsers = () => {
  const USERS: User[] = [{
    id: '1',
    name: '张三',
  }, {
    id: '2',
    name: '李四',
  }, {
    id: '3',
    name: '王五',
  }];
  return Array.from(Array(30), (item: User, i: number) => {
    return {
      id: util.generateRandomUUID(),
      name: USERS[i%3].name,
      avatarImage: $r('app.media.startIcon'),
      age: 18 + i
    } as User;
  });
}

// User Card List Component
@Component
export struct UserCardList {
  @State users: User[] = getUsers();

  build() {
    List({ space: 8 }) {
      ForEach(this.users, (item: User) => {
        ListItem() {
          UserCard({ name: item.name, age: item.age, avatarImage: item.avatarImage })
        }
      }, (item: User) => item.id)
    }
    .alignListItem(ListItemAlign.Center)
  }
}

// User Card Customization Component
@Component
struct UserCard {
  @Prop avatarImage: ResourceStr;
  @Prop name: string;
  @Prop age: number;

  build() {
    Row() {
      Row() {
        Image(this.avatarImage)
          .size({ width: 50, height: 50 })
          .borderRadius(25)
          .margin(8)
        Text(this.name)
          .fontSize(30)
      }
      Text(`age：${this.age.toString()}`)
        .fontSize(20)
    }
    .backgroundColor(DEFAULT_BACKGROUND_COLOR)
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius(8)
    .padding(8)
    .height(66)
    .width('80%')
  }
}
// [End Case5]