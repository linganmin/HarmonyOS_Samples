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

export class BulletComment {
  public id: number;
  public content: Resource | string;
  public color: string;
  public positionY: number; //the Y position of bullet comment
  public translateX: number; //the start X position of bullet comment
  public speed: number; //move speed(from right to left)
  public isUserBulletComment: boolean; //whether the comment is send by user

  constructor(content: Resource | string, isUserBulletComment: boolean = false) {
    this.id = new Date().getTime();
    this.content = content;
    this.color = '#FFFFFF';
    let randomIndex = Math.floor(Math.random() * 5);
    this.positionY = (randomIndex + 1) % 4 * 33; //set random Y position
    this.translateX = 1000;
    this.speed = 2;
    this.isUserBulletComment = isUserBulletComment;
  }
}