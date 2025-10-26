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

import { Constants } from '../constant/Constant';
import { LaneData } from '../model/RouteDataModel';

@Entry
struct Index {
  // [Start layoutBasedOnVerticalBreakpoint]
  @StorageLink('verticalBreakpoint') verticalBreakpoint: string = Constants.BREAK_POINT_SM;
  @StorageProp('laneData') laneData: LaneData | undefined = undefined;

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Image(this.verticalBreakpoint === Constants.BREAK_POINT_MD ? $r('app.media.ic_lock') : $r('app.media.ic_lock_md'))
        .width('100%')
        .height('100%')

      Row() {
        Stack() {
          Image($r('app.media.ic_light'))
            .width(this.verticalBreakpoint === Constants.BREAK_POINT_MD ? 73.5 : 106)
            .height(this.verticalBreakpoint === Constants.BREAK_POINT_MD ? 36 : 52)
          Text(JSON.stringify(this.laneData?.lightTime ?? 90))
            .fontColor($r('sys.color.white'))
            .fontSize(this.verticalBreakpoint === Constants.BREAK_POINT_MD ? 24 : 30)
            .margin({ right: this.verticalBreakpoint === Constants.BREAK_POINT_MD ? 8 : 16 })
        }
        .alignContent(Alignment.End)
      }
      .width(this.verticalBreakpoint === Constants.BREAK_POINT_MD ? 73.5 : 106)
      .height(this.verticalBreakpoint === Constants.BREAK_POINT_MD ? 36 : 52)
      .position({
        // Layout based on vertical breakpoint.
        right: 20,
        top: this.verticalBreakpoint === Constants.BREAK_POINT_MD ? 32 : 25
      })
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Center)
  }
  // [End layoutBasedOnVerticalBreakpoint]
}