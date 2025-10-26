/*
* Copyright (c) 2025 Huawei Device Co., Ltd.
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

@Entry
@Component
struct Index {
  @Provide pageInfos: NavPathStack = new NavPathStack();
  @Provide hasShield: boolean = false;
  @Provide faceBind: boolean = false;
  @Provide fingerprintBind: boolean = false;

  aboutToAppear(): void {
    this.pageInfos.pushPath({name: "MainPage"})
    AppStorage.setOrCreate('context', this.getUIContext().getHostContext())
  }

  build() {
    Navigation(this.pageInfos){
    }
    .height('100%')
    .hideToolBar(true)
    .hideNavBar(true)
  }
}