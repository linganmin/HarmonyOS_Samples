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
* FAQ:如何在调用处实现接口中的方法？
*/

// [Start CallInterface]
// The custom interface is as follows:
export interface OnTrustListener {
  OnSuccess: (data: string) => void;
  OnError: (error: string) => void;
}

@Component
export struct InterfaceUse {
  private listener: OnTrustListener = {
    OnSuccess: (data: string) => {
      console.info('data is:' + data);
    },
    OnError: (error: string) => {
      console.info('error is:' + error);
    }
  };

  build() {
    Column() {
      Button('click me')
        .onClick((event: ClickEvent) => {
          this.listener.OnSuccess('success');
        })
    }
    .width('100%')
    .height('100%')
  }
}
// [End CallInterface]

