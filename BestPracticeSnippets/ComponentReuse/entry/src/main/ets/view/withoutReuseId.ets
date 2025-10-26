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


// [Start without_reuse_id]
import { FriendMoment } from "../model/BasicDataSource";

@Entry
@Component
struct withoutReuseId {

  getFriendMomentFromRawfile(): void {

  }

  aboutToAppear(): void {
    this.getFriendMomentFromRawfile();
  }

  build() {
    Column() {
      List() {
      }
    }
  }
}


@Reusable
@Component
export struct OneMoment {
  @Prop moment: FriendMoment


  build() {
    Column() {
      Text(this.moment.text)

      if (this.moment.image !== '') {
        Flex({ wrap: FlexWrap.Wrap }) {
          Image($r(this.moment.image))
          Image($r(this.moment.image))
          Image($r(this.moment.image))
          Image($r(this.moment.image))
        }
      }
    }
  }
}

// [End without_reuse_id]