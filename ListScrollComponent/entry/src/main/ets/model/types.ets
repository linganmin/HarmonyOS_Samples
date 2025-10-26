/*
 *   Copyright (c) 2025 Huawei Device Co., Ltd.
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

import { image } from "@kit.ImageKit";

// [Start Prefetch_1]
@Observed
class ObservedArray<T> extends Array<T> {
}

@Observed
export class ImagePixelMap {
  imageUrl: string = '';
  imagePixelMap: image.PixelMap | undefined = undefined;
}

@Observed
export class BlogData {
  // [StartExclude Prefetch_1]
  id: number = -1;
  user: User = { name: '', avatar: '' };
  content: string = '';
  images: string[] = [];
  time: string = '';
  likes: number = 0;
  comments: number = 0;
  reposts: number = 0;
  // [EndExclude Prefetch_1]
  // Multiple graphs define imagePixelMapArray, corresponding to images
  imagePixelMapArray: ObservedArray<ImagePixelMap> = [];
  // A single graph defines an imagePixelMap, which corresponds to an imageUrl
  // imageUrl: string = ''
  // imagePixelMap: image.PixelMap | undefined = undefined;

  callback: Function | undefined = undefined;
  fetchUrl: string | ImageContent = ImageContent.EMPTY;
}

// [End Prefetch_1]
export interface User {
  name: string;
  avatar: string;
}

export interface Params {
  blogData: BlogData;
}

export interface TextParams {
  originalText: string;
}