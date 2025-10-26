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

@Component
export struct DownloadItem {
  @Prop fileName: string | Resource = '';
  @Prop downProgressText: string = '';
  @Prop downResult: string | Resource = '';
  @Prop downProgress: number = 0;
  @Prop downProgressColor: Resource = $r('sys.color.comp_background_emphasize');

  aboutToAppear(): void {

  }

  build() {
    Column() {
      Row() {
        Stack() {
          Image($r('app.media.ic_grid_audio'))
            .width($r('app.float.size_36vp'))
            .height($r('app.float.size_48vp'))
        }
        .width($r('app.float.size_76vp'))
        .height($r('app.float.size_72vp'))
        .margin({
          bottom: $r('app.float.size_22vp')
        })

        Column() {
          Text(this.fileName)
            .fontSize($r('app.float.size_16fp'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
            .height($r('app.float.size_21vp'))
            .textAlign(TextAlign.Start)
            .width('100%')

          Row() {
            Text(this.downProgressText)
              .fontSize($r('app.float.size_14fp'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.font_black_gray'))
              .height($r('app.float.size_20vp'))
              .textAlign(TextAlign.Start)
              .layoutWeight(2)

            Blank()
            Text(this.downResult)
              .fontSize($r('app.float.size_14fp'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.multi_color_08'))
              .height($r('app.float.size_20vp'))
              .textAlign(TextAlign.End)
              .layoutWeight(1)
          }
          .width('100%')
          .padding({
            right: $r('app.float.size_12vp')
          })
          .margin({
            top: $r('app.float.size_5vp'),
          })


          Progress({ value: 0, total: 1, type: ProgressType.Linear })
            .margin({
              right: $r('app.float.size_12vp')
            })
            .color(this.downProgressColor)
            .layoutWeight(1)
            .value(this.downProgress)
            .style({ enableSmoothEffect: false })
        }
        .layoutWeight(1)
        .margin({
          top: $r('app.float.size_12vp'),
          bottom: $r('app.float.size_12vp')
        })
      }
    }
    .borderRadius($r('app.float.size_16vp'))
    .backgroundColor(Color.White)
    .width('100%')
    .height($r('app.float.size_94vp'))
  }
}