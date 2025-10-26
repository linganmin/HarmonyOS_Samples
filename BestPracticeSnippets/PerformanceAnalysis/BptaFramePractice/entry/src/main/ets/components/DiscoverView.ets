/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
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

// [Start discover_view]
@Component
struct DiscoverView {
  // [StartExclude discover_view]
  private dataSource: LearningResource[] = [
    new LearningResource(1, "Title 1"),
    new LearningResource(2, "Title 2")
  ];
  // [EndExclude discover_view]

  build() {
    List() {
      ForEach(this.dataSource, (item: LearningResource) => {
        ListItem() {
          ArticleCardView()
            .reuseId('article')
        }
      }, (item: LearningResource) => item.id.toString())
    }
  }
}

// [StartExclude discover_view]
class LearningResource {
  id: number
  title: string

  constructor(id: number, title: string /* , ... */) {
    this.id = id
    this.title = title
  }
}
// [EndExclude discover_view]
// Add @Reusable Decorator Use Component Reuse
@Reusable
@Component
export struct ArticleCardView {
  // ...
  aboutToReuse(params: Record<string, Object>): void {
    // ...
  }
  Row() {
    ActionButtonBuilder()
    ActionButtonBuilder()
    ActionButtonBuilder()
  }
  build() {
    // ...
  }
}


// Build subcomponents using @Builder
@Builder
function ActionButtonBuilder() {
  // ...
}
// [End discover_view]