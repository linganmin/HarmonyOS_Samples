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

import { BulletComment } from '../model/BulletComment';

@Component
export struct BulletCommentView {
  @State forceUpdate: boolean = false;
  @Link bulletComments: BulletComment[];
  @Link showBulletComment: boolean;
  private timerId: number = -1;

  aboutToAppear(): void {
    this.startAnimation();
  }

  aboutToDisappear(): void {
    clearInterval(this.timerId);
  }

  //start bullet comment animation
  // [Start StartBulletCommentAnimation]
  private startAnimation() {
    clearInterval(this.timerId);
    //refresh the postion of bullet comments by timer
    this.timerId = setInterval(() => {
      let needUpdate = false;
      this.bulletComments.forEach(item => {
        const positionX = item.translateX - item.speed;
        if (positionX !== item.translateX) {
          item.translateX = positionX; //set new X position of bullet comment
          needUpdate = true;
        }
      });
      const beforeLength = this.bulletComments.length;
      this.bulletComments =
        this.bulletComments.filter(item => item.translateX > -20); //remove the bullet comment which beyond the screen
      if (needUpdate || this.bulletComments.length !== beforeLength) {
        this.forceUpdate = !this.forceUpdate; //trigger ui refresh
      }
    }, 16);
  }

  // [End StartBulletCommentAnimation]

  build() {
    Stack() {
      ForEach(this.bulletComments, (item: BulletComment) => {
        if (item.isUserBulletComment) {
          Text(item.content)
            .fontSize(14)
            .fontColor(item.color)
            .translate({ x: `${item.translateX}vp`, y: 0 })
            .position({ y: `${item.positionY}%` })
            .backgroundColor('rgba(0,0,0,0.4)')
            .borderRadius(999)
            .borderWidth(1)
            .borderColor('rgba(255,255,255,0.6)')
            .padding({
              top: 4,
              left: 8,
              bottom: 4,
              right: 8
            })
            .opacity(0.5)
            .key(item.id.toString())
        } else {
          Text(item.content)
            .fontSize(14)
            .fontColor(item.color)
            .translate({ x: `${item.translateX}vp`, y: 0 })
            .position({ y: `${item.positionY}%` })
            .backgroundColor('rgba(0,0,0,0.4)')
            .borderRadius(999)
            .padding({
              top: 4,
              left: 8,
              bottom: 4,
              right: 8
            })
            .opacity(0.5)
            .key(item.id.toString())
        }
      })
      Text(this.forceUpdate ? ' ' : '  ')
        .size({ width: 0, height: 0 })
    }
    .width('100%')
    .height('30%')
  }
}