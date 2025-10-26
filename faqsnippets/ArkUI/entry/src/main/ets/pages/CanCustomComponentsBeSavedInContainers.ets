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
* FAQ:自定义组件是否能通过容器保存
*/

// [Start can_custom_components_be_saved_in_containers]
@Component
struct ComA {
  build() {
    Text('ComA').fontSize(50).fontWeight(FontWeight.Bold)
  }
}

@Component
struct ComB {
  build() {
    Text('ComB').fontSize(50).fontWeight(FontWeight.Bold)
  }
}

@Component
struct ComC {
  build() {
    Text('ComC').fontSize(50).fontWeight(FontWeight.Bold)
  }
}

//if else logical branch writing
@Builder
function buildCom(param: string) {
  if (param == 'ComA') {
    ComA()
  } else if (param == 'ComB') {
    ComB()
  } else if (param == 'ComC') {
    ComC()
  }
}

@Builder
function buildComA() {
  ComA()
}

@Builder
function buildComB() {
  ComB()
}

@Builder
function buildComC() {
  ComC()
}

//Encapsulate in container through map
let map: Map<string, WrappedBuilder<[]>> = new Map();
map.set('ComA', wrapBuilder(buildComA));
map.set('ComB', wrapBuilder(buildComB));
map.set('ComC', wrapBuilder(buildComC));

@Component
struct Page12 {
  @State message: string = 'Hello World';
  @State arr: string[] = ['ComA', 'ComB', 'ComC'];

  build() {
    Column() {
      ForEach(this.arr, (item: string) => {
        //Retrieve based on the key during use
        map.get(item)?.builder()
      })
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
  }
}

// [End can_custom_components_be_saved_in_containers]