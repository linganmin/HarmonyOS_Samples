/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
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

/*
* FAQ:Badge有数量与无数量切换时Image会发生闪动，怎么让它不闪动
*/

// [Start badge_does_not_flash]
@Entry
@Component
struct BadgeDemo {
  @State message: string = 'Hello World';
  @State sizes: string = '0';
  @State showCountBadge: boolean = false;

  build() {
    Row() {
      Text(this.message)
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .onClick(() => {
          this.showCountBadge = !this.showCountBadge; // change show status
        })
      Stack() {
        Badge({
          value: '',
          position: {
            x: 40,
            y: 0
          },
          style: {
            badgeSize: 15,
            badgeColor: Color.Red
          }
        }) {
          Image($r('app.media.startIcon'))
            .width(50)
            .height(50)
        }
        .visibility(this.showCountBadge ? Visibility.Visible : Visibility.None)


        Badge({
          count: 98,
          maxCount: 99,
          position: { x: 30, y: 0 },
          style: {
            fontSize: 15,
            badgeSize: 15,
            badgeColor: Color.Red
          }
        }) {
          Image($r('app.media.startIcon'))
            .width(50)
            .height(50)
        }
        .visibility(this.showCountBadge ? Visibility.None : Visibility.Visible)
      }
    }
    .height('100%')
  }
}

// [End badge_does_not_flash]