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

import WorkViewModel from '../viewModel/WorkViewModel';
import { WorkCellData } from './WorkComponent';

@Component
export default struct VideoWorkComponent {
  @State work: WorkViewModel = new WorkViewModel();

  aboutToReuse(params: Record<string, ESObject>) {
    let input = params as WorkCellData;
    this.work = input.work;
  }

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(this.work.coverImage)
        .draggable(false)

      Row({ space: 2 }) {
        SymbolGlyph($r("sys.symbol.heart"))
          .fontColor([Color.White])
        Text(`${this.work.likeCount}`)
          .fontColor(Color.White)
      }
      .margin({
        left: 8,
        bottom: 8
      })
    }
    .width('100%')
    .height(170)
  }
}

@Builder
export function buildVideoWork(data: WorkCellData) {
  VideoWorkComponent({ work: data.work })
}