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
export function Segment07Builder() {
  NavDestination(){
    ArticleCardView()
  }
}
interface IUserAccountRepository {
  getUserData(): Promise<UserData>;
}

export class LearningResource {
  id: string = "";
  collectionCount: number = 0;
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

// [Start Case4]
export interface UserData {
  id: string;
  username: string;
  description: string;

  // 1. Add a list of resources in the user's collection on the user information UserData id Information Type Definition
  collectedIds: string[];
  // ...
}
// [StartExclude Case4]
class cc {
  private userAccountRepository: IUserAccountRepository;

  constructor(repository: IUserAccountRepository) {
    this.userAccountRepository = repository;
  }
  // [EndExclude Case4]
  // Getting server-side user information in a business class
  getUserData(): void {
    this.userAccountRepository.getUserData().then((data: UserData) => {
      // 2.Storing user information data into AppStorage
      AppStorage.setOrCreate('userData', data);
    })
  }
  // [StartExclude Case4]
}
// [EndExclude Case4]

// Article card component of the Explore module
@Component
export struct ArticleCardView {
  // 3.Get the user information object userData on the ExploreArticleList card with the @StorageLink decorator
  @StorageLink('userData') userData: UserData | null = null;
  @Prop articleItem: LearningResource = new LearningResource();

  // 4.Calculate whether the current article is favorite or not according to the favorite information array
  isCollected(): boolean {
    return !!this.userData && this.userData.collectedIds.some((id: string) => id === this.articleItem.id);
  }

  // 7.Handling interface like interaction logic: when the userData state sub-property collectedIds received using the @StorageLink decorator is modified, the new value is synchronized to AppStorage
  handleCollected(): void {
    // [StartExclude Case4]
    const resourceId = this.articleItem.id;
    // [EndExclude Case4]
    const index = this.userData?.collectedIds.findIndex((id: string) => id === this.articleItem.id) as number;
    if (index === -1) {
      this.userData?.collectedIds.push(resourceId);
    } else {
      this.userData?.collectedIds.splice(index, 1);
    }
    // ...
  }

  build() {
    ActionButtonView({
      // 5.Determine whether the favorite icon is highlighted according to whether the current article has been favorited by the user or not
      imgResource: this.isCollected() ? $r('app.media.icon') : $r('app.media.icon'),
      count: this.articleItem.collectionCount,
      textWidth: 77
    })
      .onClick(() => {
        // 6.When the user clicks on the favorites icon, the function that handles changes to the status of the favorites is called
        this.handleCollected();
      })
  }
}
// [End Case4]