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

import { BasicDataSource } from './BasicDataSource';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
// Video data structure.
export interface VideoData {
  video: Resource | string;
  name: string;
  description: string;
  time: string;
  controller: VideoController;
  auto: boolean;
  head: Resource;
  likeCount: string;
  commentCount: string;
  favoriteCount: string;
  shareCount: string;
  hotspot: string;
  play: boolean;
  index: number;
}

// A subclass inheriting from BasicDataSource has overridden the methods.
export class TopTabContent extends BasicDataSource {
  private tabContent: string[] = [this.ResourceToString($r('app.string.focus')), this.ResourceToString($r('app.string.featured')),
    this.ResourceToString($r('app.string.recommend')), this.ResourceToString($r('app.string.movie_room'))];

  // Get the length of the array.
  public totalCount(): number {
    return this.tabContent.length;
  }

  // Retrieve data at the specified index.
  public getData(index: number): string {
    return this.tabContent[index];
  }

  // Change a single piece of data.
  public addData(index: number, data: string): void {
    this.tabContent.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  // Add data.
  public pushData(data: string): void {
    this.tabContent.push(data);
    this.notifyDataAdd(this.tabContent.length - 1);
  }

  ResourceToString(resource:Resource):string{
    return uiContext!.getHostContext()!.resourceManager.getStringSync(resource)
  }
}