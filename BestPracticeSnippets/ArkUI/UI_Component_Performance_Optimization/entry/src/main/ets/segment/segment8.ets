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

interface User {
  id: string;
  name: string;
  age?: number;
  avatarImage?: ResourceStr;
}

const getUsers = (): User[] => {
  return [];
};

// [Start Case6]
// 1. Customizing @Builder Function Components
@Builder
function UserCardBuilder(name: string, age?: number, avatarImage?: ResourceStr) {
  Row() {
    Row() {
      Image(avatarImage)
        .size({ width: 50, height: 50 })
        .borderRadius(25)
        .margin(8)
      Text(name)
        .fontSize(30)
    }
    Text(`age：${age?.toString()}`)
      .fontSize(20)
  }
  .backgroundColor(Color.Blue)
  .justifyContent(FlexAlign.SpaceBetween)
  .borderRadius(8)
  .padding(8)
  .height(66)
  .width('80%')
}

@Component
export struct UserCardList {
  @State users: User[] = getUsers();

  build() {
    List({ space: 8 }) {
      ForEach(this.users, (item: User) => {
        ListItem() {
          // 2. Using the @Builder function in a build function
          UserCardBuilder(item.name, item.age, item.avatarImage)
        }
      }, (item: User) => item.id)
    }
    .alignListItem(ListItemAlign.Center)
  }
}
// [End Case6]