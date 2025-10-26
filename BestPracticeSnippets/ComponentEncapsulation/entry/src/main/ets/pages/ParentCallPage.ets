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
// [Start parent_call]
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Component
export struct ChildComponent {
  call = () => {
  };

  build() {
    Column() {
      Button('Child Component')
        .onClick(() => {
          this.call();
        })
    }
  }
}

@Entry
@Component
struct Index {
  parentAction() {
    try {
      this.getUIContext().getPromptAction().showToast({ message: 'Parent Action' });
    } catch (error) {
      let err = error as BusinessError;
      hilog.warn(0x000, 'testTag', `showToast failed, code=${err.code}, message=${err.message}`);
    }
  }

  build() {
    Column() {
      ChildComponent({ call: this.parentAction })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}

// [End parent_call]