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
* FAQ:目前Toggle组件响应点击之后会立刻渲染且立刻回调，如何延迟改变Toggle状态且延时回调？
*/

// [Start toggle_demo]
@Entry
@Component
struct ToggleDemo {
  @State isDarkMode: boolean = false;
  private timeoutID?: number;

  aboutToDisappear(): void {
    clearTimeout(this.timeoutID);
  }

  build() {
    Column() {
      Column() {
        Toggle({ type: ToggleType.Switch, isOn: $$this.isDarkMode })
          .onChange((isOn: boolean) => {
            console.info('Toggle.onChange:isOn' + isOn);
            this.isDarkMode = isOn;
            this.getUIContext().getHostContext()!.getApplicationContext().setColorMode(this.isDarkMode ? 0 : 1);
          })
      }
      // Set hitTestBehavior property to HitTestMode.Block to block Toggle component's event response.
      .hitTestBehavior(HitTestMode.Block)
      .onClick(() => {
        this.timeoutID = setTimeout(() => {
          this.isDarkMode = !this.isDarkMode;
        }, 1500);
      })
    }
    .width('100%')
    .height('100%')
    .padding(32)
  }
}

// [End toggle_demo]