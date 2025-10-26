/*
 *  Copyright (c) 2025 Huawei Device Co., Ltd.
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
@Builder
export function Segment06Builder() {
  NavDestination(){
    UserInfoView()
  }
}

interface IUserAccountRepository {
  getUserData(): Promise<UserData>;
}
// [Start Case3_start]
// Data structure of user information UserData
export interface UserData {
  id: string;
  username: string;
  description: string;
  // ...
}
// [StartExclude Case3_start]
class bb {
  private userAccountRepository: IUserAccountRepository;

  constructor(repository: IUserAccountRepository) {
    this.userAccountRepository = repository;
  }
  // [EndExclude Case3_start]
  // Getting server-side user information in a business class
  getUserData(): void {
    this.userAccountRepository.getUserData().then((data: UserData) => {
      // 1.Storing user information data into AppStorage
      AppStorage.setOrCreate('userData', data);
    });
  }
  // [StartExclude Case3_start]
}
// [EndExclude Case3_start]
// View component for displaying user information at the top of the “My” module
@Component
struct UserInfoView {
  // 2.Receive user information stored in AppStorage using @StorageLink decorator in UI
  @StorageLink('userData') userData: UserData | null = null;
  build() {
    Column() {
      Row() {
        // ...
        Column() {
          // 3.Display the user name in the userData.
          Text(this.userData ? this.userData.username : 'default_login')
          // ...
        }
      }
      // ...
    }
    // ...
  }
}
// [End Case3_start]