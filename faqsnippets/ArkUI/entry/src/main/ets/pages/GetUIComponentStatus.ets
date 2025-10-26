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
* FAQ:如何获取UI组件的显示或隐藏状态
*/

// [Start get_ui_component_status]
@Component
struct ComponentA {
  aboutToAppear(): void {
    // Perception components are visible and hidden
    console.log('Component A display');
  }

  aboutToDisappear(): void {
    // Perception components are visible and hidden
    console.log('Component A hidden');
  }

  build() {
    Column() {
      Text('Component A').fontSize(16).fontColor(Color.Black);
    }
    .width(100)
    .height(50)
  }
}

@Entry
@Component
struct ComponentB {
  @State @Watch('onCompAShowStatusChange') isShowA: boolean = false;
  onCompAShowStatusChange() {
    // Perception components are visible and hidden
    console.log('Monitor component A：' + `${this.isShowA ? 'display' : 'hide'}`);
  }

  build() {
    Column() {
      Button('Switch between visible and hidden').type(ButtonType.Normal).width(100).height(50).onClick(() => {
        this.isShowA = !this.isShowA;
      })
      if (this.isShowA) {
        ComponentA();
      }
    }
  }
}
// [End get_ui_component_status]