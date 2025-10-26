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
// [Start factory_map]
// Import the component factory. The path must be based on the actual location.
import { factoryMap } from '../view/FactoryMap';
// [StartExclude factory_map]
import { getResourceString } from '../model/GetResourceString';
// [EndExclude factory_map]
// Get the corresponding WrappedBuilder object from the key value of the component factory Map.
let myRadio: WrappedBuilder<[]> = factoryMap.get('Radio') as WrappedBuilder<[]>;
let myCheckbox: WrappedBuilder<[]> = factoryMap.get('Checkbox') as WrappedBuilder<[]>;
// [End factory_map]
@Builder
export function ComponentFactoryBuilder() {
  ComponentFactory()
}

@Entry
// [Start component_factory]
@Component
struct ComponentFactory {
  build() {
    NavDestination() {
      Column({ space: 12 }) {
        // myRadio and myCheckbox are WrappedBuilder objects obtained from the component factory.
        myRadio.builder();
        myCheckbox.builder();
      }
      .width('100%')
      .padding($r('app.float.padding'))
    }
    .title(getResourceString($r('app.string.factory'), this))
  }
}
// [End component_factory]