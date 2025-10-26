/*
 *  Copyright (c) 2025 Huawei Device Co., Ltd.
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
@Builder
export function Segment01Builder() {
  NavDestination(){
    MyComponent()
  }
}

// [Start Counter_example1_start]
@Observed
class Translate {
  translateX: number = 20;
}

@Component
struct MyComponent {
  @State translateObj: Translate = new Translate(); // The variable translateObj is not associated with any UI component and should not be defined as a state variable
  @State buttonMsg: string = 'I am button'; // The variable buttonMsg is not associated with any UI component and should not be defined as a state variable
  build() {
  }
}
// [End Counter_example1_start]