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

export class SearchTicketBarItem {
  /**
   * The image of the bar.
   */
  private image: Resource;

  /**
   * The title of the bar.
   */
  private title: string | Resource;

  /**
   * The selected image of the bar.
   */
  private imageSelected : Resource;

  /**
   * constructor method.
   */
  constructor(image: Resource, title: string | Resource,imageSelected : Resource){
    this.image = image;
    this.title = title;
    this.imageSelected = imageSelected;
  }

  /**
   * The getter of image.
   */
  getImage() {
    return this.image;
  }

  /**
   * The getter of title.
   */
  getTitle() {
    return this.title;
  }

  /**
   * The getter of imageSelected.
   */
  getImageSelected(){
    return this.imageSelected;
  }
}