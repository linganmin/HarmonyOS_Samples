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
* FAQ：如何针对UI组件属性做API版本兼容性判断
*/

// [Start component_attribute_compatibility_judgment]
import { deviceInfo } from '@kit.BasicServicesKit';

@Entry
@Component
struct ComponentAttributeCompatibilityJudgment {
  modifier: MyListModifier = new MyListModifier();

  build() {
    List() {
      // List content
    }
    .height('100%')
    .width('100%')
    .attributeModifier(this.modifier)
  }
}

class MyListModifier implements AttributeModifier<ListAttribute> {
  applyNormalAttribute(instance: ListAttribute): void {
    // Determine based on the API version information of deviceInfo
    if (deviceInfo.sdkApiVersion > 14) {
      // The property to be adapted is the backToTop attribute of the List component
      // The instance is an attribute object of the List, and its properties can be modified through the instance
      instance.backToTop(true);
    }
  }
}

// [End component_attribute_compatibility_judgment]
