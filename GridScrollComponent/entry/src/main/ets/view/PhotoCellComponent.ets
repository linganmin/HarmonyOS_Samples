/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import PhotoSizeViewModel from "../viewModel/PhotoSizeViewModel";
import PhotoViewModel from "../viewModel/PhotoViewModel";
import { PhotoCellData } from "./PhotoGridComponent";

@Component
export default struct PhotoCellComponent {
  @State photo: PhotoViewModel = new PhotoViewModel();
  @State photoSize: PhotoSizeViewModel = new PhotoSizeViewModel();

  aboutToReuse(params: Record<string, ESObject>): void {
    let input = params as PhotoCellData;
    this.photo = input.photo;
    this.photoSize = input.photoSize;
  }

  build() {
    Image(this.photo.photoPath)
      .sourceSize({
        width: this.photoSize.width,
        height: this.photoSize.height
      })
      .width('100%')
      .height(this.photoSize.height)
      .objectFit(ImageFit.Cover)
      .draggable(false)
  }
}

@Builder
export function buildPhoto(data: PhotoCellData) {
  PhotoCellComponent({ photo: data.photo, photoSize: data.photoSize })
}