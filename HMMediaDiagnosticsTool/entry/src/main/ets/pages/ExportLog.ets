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

import { HMRouter } from '@hadss/hmrouter';

@HMRouter({ pageUrl: 'ExportLog', singleton: true })
@Preview
@Component
export struct ExportLog {
  build() {
    Column() {
      Text($r('app.string.export_log_guide_title'))
        .fontSize(18)
        .fontWeight(FontWeight.Bolder)
        .height(80);
      Text($r('app.string.export_log_guide_1'))
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .margin({
          top: 10,
          bottom: 15
        });
      Text($r('app.string.export_log_guide_1_1'));
      Text($r('app.string.export_log_guide_1_2'))
        .margin({ top: 5 });
      Text($r('app.string.export_log_guide_2'))
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .margin({
          top: 15,
          bottom: 15
        });
      Text($r('app.string.export_log_guide_2_1'));
      Text($r('app.string.export_log_guide_2_2'))
        .margin({
          top: 5,
          bottom: 5
        });
      Text($r('app.string.export_log_guide_2_3'));
    }
    .alignItems(HorizontalAlign.Start)
    .padding({
      left: 20,
      right: 20
    });
  }
}