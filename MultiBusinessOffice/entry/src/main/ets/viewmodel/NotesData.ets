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

export class NotesData {
  /**
   * Color.
   */
  public color: string;
  /**
   * Title.
   */
  public title: string;
  /**
   * Time.
   */
  public time: ResourceStr;
  /**
   * Descriptions.
   */
  public descriptions: ResourceStr;
  /**
   * IconSrc.
   */
  public iconSrc: Resource | undefined;
  /**
   * ImageSrc.
   */
  public imageSrc: Resource | undefined;

  /**
   * constructor method.
   */
  constructor(color: string, title: string, time: ResourceStr, descriptions: ResourceStr, imageSrc?: Resource,
    iconSrc?: Resource) {
    this.color = color;
    this.title = title;
    this.time = time;
    this.descriptions = descriptions;
    this.imageSrc = imageSrc;
    this.iconSrc = iconSrc;
  }
}