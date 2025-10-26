/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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

export interface Route {
  title: ResourceStr
  children?: Route[]
  to?: string
};

export const ROUTES: Route[] = [
  {
    title: $r('app.string.album_image_transfer'),
    to: 'AlbumImageTransfer'
  },
  {
    title: $r('app.string.chunked_file_transfer'),
    to: 'ChunkedFileTransfer'
  },
  {
    title: $r('app.string.resumable_file_transfer'),
    to: 'ResumableFileTransfer'
  },
  {
    title: $r('app.string.background_file_transfer'),
    to: 'BackgroundFileTransfer'
  }
];

export const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff', 'webp', 'svg'];

export const videoExtensions = ['mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv', 'webm', 'mpeg', 'mpg'];