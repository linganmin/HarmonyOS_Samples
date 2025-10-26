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
export function Segment08Builder() {
  NavDestination(){
    ArticleCardView()
  }
}
@Component
struct ActionButtonView {
  imgResource: Resource = $r("app.media.icon");
  count: number = 0;
  textWidth: number = 0;

  build() {
    Column() {
      Image(this.imgResource)
        .width(this.textWidth)
      Text(this.count.toString())
    }
    .alignItems(HorizontalAlign.Center)
  }
}

export class LearningResource {
  id: string = "";
  collectionCount: number = 0;
}

interface IUserAccountRepository {
  getUserData(): Promise<UserData>;
}

export interface UserData {
  id: string;
  username: string;
  description: string;
  collectedIds: string[];
}

class dd {
  private userAccountRepository: IUserAccountRepository;

  constructor(repository: IUserAccountRepository) {
    this.userAccountRepository = repository;
  }
  // [Start Case5]
  // Getting user information in a business class
  getUserData(): void {
    this.userAccountRepository.getUserData().then((data: UserData) => {
      //1.Separate storage of user collection information data in AppStorage
      AppStorage.setOrCreate('collectedIds', data.collectedIds);
      AppStorage.setOrCreate('userData', data);
    })
  }
  // [End Case5]
}

// [Start Case5]
// Article card component of the Explore module
@Component
export struct ArticleCardView {
  // 2.Getting collection information stored in AppStorage via @StorageLink decorator
  @StorageLink('collectedIds') collectedIds: string[] = [];
  @Prop articleItem: LearningResource = new LearningResource();
  // 3.Calculate whether the current article is favorite or not according to the favorite information array
  isCollected(): boolean {
    return this.collectedIds.some((id: string) => id === this.articleItem.id);
  }
  // 6.Handling interface like interaction logic: when the state collectedIds received using the @StorageLink decorator are modified, the new values are synchronized to AppStorage
  handleCollected(): void {
    // [StartExclude Case5]
    const resourceId = this.articleItem.id;
    // [EndExclude Case5]
    const index = this.collectedIds.findIndex((id: string) => id === this.articleItem.id);
    if (index === -1) {
      this.collectedIds.push(resourceId);
    } else {
      this.collectedIds.splice(index, 1);
    }
    // ...
  }
  build(){
    ActionButtonView({
      // 4.Determine whether the favorite icon is highlighted according to whether the current article has been favorited by the user or not
      imgResource: this.isCollected() ? $r('app.media.icon') : $r('app.media.icon'),
      count: this.articleItem.collectionCount,
      textWidth: 77
    })
      .onClick(() => {
        // 5.When the user clicks on the favorites icon, the function that handles changes to the status of the favorites is called
        this.handleCollected();
      })
  }
}
// [End Case5]