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

import { CONSTANT } from '../constant/Constant';

// Current columns
const COLUMNS_0 = 0;
const COLUMNS_1 = 1;
const COLUMNS_2 = 2;
const COLUMNS_3 = 3;
// Image num
const IMAGE_SET_SIZE_1 = 1;
const IMAGE_SET_SIZE_9 = 9;
// Image aspect
const IMAGE_ASPECT_RATIO_0 = 0;
// One image width
const IMAGE_ONE_WIDTH = '60%'

@Component
export struct MultiGrid {
  @Prop modifier: AttributeModifier<ImageAttribute> | null = null;
  public  imageSource: (string | Resource)[] = [];
  private col: number = 0;
  private row: number = 0;
  private imageSpacing: number = 3;
  private imageWidth: string = '';
  private imageAspectRatio: number = 1;
  private imageFit: ImageFit = ImageFit.Fill;
  private arraySize: number = 0;

  aboutToAppear() {
    this.arraySize = this.imageSource.length;
    if (this.col <= COLUMNS_0) {
      this.arraySize = Math.min(this.imageSource.length, IMAGE_SET_SIZE_9);
      this.row = Math.ceil(this.arraySize / COLUMNS_3);
      if (this.arraySize === IMAGE_SET_SIZE_1) {
        this.col = COLUMNS_1;
        this.imageAspectRatio = IMAGE_ASPECT_RATIO_0;
        this.imageFit = ImageFit.Contain;
        this.imageWidth = IMAGE_ONE_WIDTH;
      } else {
        this.col = COLUMNS_3;
        this.imageWidth = `calc((100% - ${this.imageSpacing * COLUMNS_2}vp ) / 3)`;
      }
    } else {
      this.row = Math.ceil(this.arraySize / this.col);
      this.imageWidth = `calc((100% - ${this.imageSpacing * (this.col - 1)}vp ) / ${this.col})`;
    }
  }

  build() {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
      ForEach(this.imageSource.slice(0, this.arraySize), (item: string | Resource, idx: number) => {
        Image(item)
          .attributeModifier(this.modifier)
          .autoResize(true)
          .objectFit(this.imageFit)
          .aspectRatio(this.imageAspectRatio)
          .width(this.imageWidth)
          .margin(
            {
              bottom: (idx + 1) > ((this.row - 1) * this.col) ? 0 : this.imageSpacing,
              right: (idx + 1) % this.col === 0 ? 0 : this.imageSpacing
            }
          )
      }, (item: string | Resource, index: number) => index.toString())
    }
    .width(CONSTANT.FULL_SIZE)
  }
}