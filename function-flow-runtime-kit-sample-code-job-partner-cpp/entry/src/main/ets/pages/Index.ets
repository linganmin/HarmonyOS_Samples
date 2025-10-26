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

import { hilog } from '@kit.PerformanceAnalysisKit';
import testNapi from 'libentry.so';
import CommonConstants from '../../common/CommonConstants';

const DOMAIN = 0x0000;

@Entry
@Component
struct Index {
  @State serialExecutionTime: string = '0';
  @State parallelExecutionTime: string = '0';

  build() {
    Stack() {
      Scroll() {
        Column({ space: CommonConstants.COLUMN_SPACE }) {
          Row() {
            Text($r('app.string.title'))
              .fontSize($r('app.float.title_font_size'))
              .fontWeight(CommonConstants.FONT_WEIGHT)
              .height($r('app.float.title_text_height'))
              .align(Alignment.Center)
              .maxLines(CommonConstants.TITLE_MAX_LINES)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .height($r('app.float.title_height'))
          .width(CommonConstants.FILL_PARENT)
          .justifyContent(FlexAlign.Center)
          .margin({ top: '40vp' })

          Row() {
            Text($r('app.string.message'))
              .fontSize($r('app.float.text_font_size'))
              .fontWeight(CommonConstants.FONT_WEIGHT)
              .height($r('app.float.description_text_height'))
              .align(Alignment.Center)
              .maxLines(CommonConstants.TEXT_MAX_LINES)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .padding({ left: $r('app.float.text_padding'), right: $r('app.float.text_padding') })
          .margin({ top: $r('app.float.text_margin'), bottom: $r('app.float.text_margin')})

          Row() {
            Image($r('app.media.job_partner'))
              .height($r('app.float.image_height'))
              .objectFit(ImageFit.Contain)
          }
          .margin({ top: $r('app.float.text_margin'), bottom: $r('app.float.text_margin')})
          .justifyContent(FlexAlign.Center)
          .width(CommonConstants.FILL_PARENT)

          Row() {
            Text($r('app.string.task'))
              .fontSize($r('app.float.text_font_size'))
              .fontWeight(CommonConstants.FONT_WEIGHT)
              .height($r('app.float.description_text_height'))
              .align(Alignment.Center)
              .maxLines(CommonConstants.TEXT_MAX_LINES)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .padding({ left: $r('app.float.text_padding'), right: $r('app.float.text_padding') })
          .margin({ top: $r('app.float.text_margin'), bottom: $r('app.float.text_margin')})

          Row() {
            Column() {
              Text($r('app.string.SerialTaskCost'))
                .fontSize($r('app.float.text_font_size'))
                .fontWeight(CommonConstants.FONT_WEIGHT)
                .textAlign(TextAlign.Center)
                .maxLines(CommonConstants.TEXT_MAX_LINES)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Row() {
                Text(this.serialExecutionTime)
                  .fontSize($r('app.float.output_font_size'))
                  .fontWeight(CommonConstants.FONT_WEIGHT)

                Text($r('app.string.TimeUnit'))
                  .fontSize($r('app.float.text_font_size'))
              }
              .justifyContent(FlexAlign.Center)
              .width(CommonConstants.FILL_PARENT)
              .margin({ top: '5vp' })
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .width(CommonConstants.FILL_PARENT)
            .height(CommonConstants.FILL_PARENT)
          }
          .width(CommonConstants.PARTIAL_PARENT)
          .borderRadius($r('app.float.display_area_border_radius'))
          .height($r('app.float.display_area_height'))
          .margin({ top: $r('app.float.text_margin'), bottom: $r('app.float.text_margin')})
          .backgroundColor(Color.White)

          Row() {
            Button($r('app.string.SerialTaskCostBtn'))
              .fontSize($r('app.float.button_font_size'))
              .fontWeight(CommonConstants.FONT_WEIGHT)
              .height(CommonConstants.FILL_PARENT)
              .width($r('app.float.button_width'))
              .onClick(() => {
                let serialExecTime = testNapi.fetch_exec_time(false);
                this.serialExecutionTime = serialExecTime.toString();
                hilog.info(DOMAIN, 'TestTag', 'Serial execution time is %{public}d', serialExecTime);
              })
          }
          .height($r('app.float.button_height'))
          .width(CommonConstants.FILL_PARENT)
          .justifyContent(FlexAlign.Center)
          .margin({ top: $r('app.float.button_margin'), bottom: $r('app.float.button_margin')})

          Row() {
            Column() {
              Text($r('app.string.JobPartnerTaskCost'))
                .fontSize($r('app.float.text_font_size'))
                .fontWeight(CommonConstants.FONT_WEIGHT)
                .textAlign(TextAlign.Center)
                .maxLines(CommonConstants.TEXT_MAX_LINES)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Row() {
                Text(this.parallelExecutionTime)
                  .fontSize($r('app.float.output_font_size'))
                  .fontWeight(CommonConstants.FONT_WEIGHT)

                Text($r('app.string.TimeUnit'))
                  .fontSize($r('app.float.text_font_size'))
              }
              .justifyContent(FlexAlign.Center)
              .width(CommonConstants.FILL_PARENT)
              .margin({ top: '5vp' })
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .width(CommonConstants.FILL_PARENT)
            .height(CommonConstants.FILL_PARENT)
          }
          .width(CommonConstants.PARTIAL_PARENT)
          .borderRadius($r('app.float.display_area_border_radius'))
          .height($r('app.float.display_area_height'))
          .margin({ top: $r('app.float.text_margin'), bottom: $r('app.float.text_margin')})
          .backgroundColor(Color.White)

          Row() {
            Button($r('app.string.JobPartnerTaskCostBtn'))
              .fontSize($r('app.float.button_font_size'))
              .fontWeight(CommonConstants.FONT_WEIGHT)
              .height(CommonConstants.FILL_PARENT)
              .width($r('app.float.button_width'))
              .onClick(() => {
                let parallelExecTime = testNapi.fetch_exec_time(true);
                this.parallelExecutionTime = parallelExecTime.toString();
                hilog.info(DOMAIN, 'TestTag', 'Parallel execution time is %{public}d', parallelExecTime);
              })
          }
          .height($r('app.float.button_height'))
          .width(CommonConstants.FILL_PARENT)
          .justifyContent(FlexAlign.Center)
          .margin({ top: $r('app.float.button_margin'), bottom: $r('app.float.button_margin')})

          Row()
            .height('30vp')
        }
        .width(CommonConstants.FILL_PARENT)
      }
      .height(CommonConstants.FILL_PARENT)
      .scrollBar(BarState.Auto)
    }
    .width(CommonConstants.FILL_PARENT)
    .height(CommonConstants.FILL_PARENT)
    .backgroundColor($r('app.color.background_color'))
  }
}