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

import BasicDataSource from '../viewmodel/BasicDataSource';
import SampleUnitItem from '../viewmodel/SampleUnitItem';
import SampleUnitView from '../view/SampleUnitView';
import { CONSTANT } from '../constant/Constant';

// List space
const LIST_SPACE = 10;
// List margin top
const LIST_MARGIN_TOP = 30;

@Entry
@Component
struct Index {
  @State rotateAngle: number = 0;

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      List({ space: LIST_SPACE }) {
        LazyForEach(BasicDataSource.getData(), (item: SampleUnitItem) => {
          ListItem() {
            SampleUnitView({
              type: item.type,
              buttonUnit: item.button,
              areaUnit: item.title,
              textContext: item.context,
              imageArray: item.pic,
              controller: item.controller,
              avPlayer: item.avPlayer
            })
              .padding({ left: CONSTANT.COMMON_DISTANCE, right: CONSTANT.COMMON_DISTANCE })
              .backgroundColor(Color.White)
          }
        }, (item: SampleUnitItem, index: number) => index.toString())
      }
      .margin({ top: LIST_MARGIN_TOP })
      .backgroundColor($r('app.color.body_background'))
      .scrollBar(BarState.Off)
    }
    .backgroundColor($r('app.color.body_background'))
  }
}
