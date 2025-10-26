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

interface VideoItem {
  id: string;
}

function getVideoList(): VideoItem[] {
  return [];
}

// [Start Counter_example1]
@Component
export struct VideoCard {
  // [StartExclude Counter_example1]
  @Prop item: VideoItem = { id: '' };

  private createComplexVideoPlayer(): void {
  }

  build() {
    Column() {
    }
  }

  // [EndExclude Counter_example1]
  aboutToAppear(): void {
    // Create a complex object task, if the task takes 1s to execute, the component will be rendered again after 1s
    this.createComplexVideoPlayer();
  }
  // ...
}

@Component
export struct CardList {
  @State videoList: VideoItem[] = getVideoList();

  build() {
    List() {
      ForEach(this.videoList, (item: VideoItem) => {
        ListItem() {
          VideoCard({ item })
        }
      }, (item: VideoItem) => item.id)
    }
  }
}
// [End Counter_example1]