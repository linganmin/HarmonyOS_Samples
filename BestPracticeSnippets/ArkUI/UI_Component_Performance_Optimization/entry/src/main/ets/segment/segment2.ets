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

const screenHeight: number = 800;

// [Start Case1]
@Component
export struct VideoCard {
  @State isVideoInit: boolean = false;
  // [StartExclude Case1]
  @Prop item: VideoItem = { id: '' };

  private createComplexVideoPlayer(): void {
  }

  // [EndExclude Case1]
  build() {
    Column() {
      // Video Playback Component
    }
    .onAreaChange((old, newValue) => {
      if (!this.isVideoInit) {
        let positionY: number = newValue.position.y as number
        if (positionY < screenHeight / 3) {
          this.createComplexVideoPlayer();
          this.isVideoInit = true;
        }
      }
    })
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
// [End Case1]