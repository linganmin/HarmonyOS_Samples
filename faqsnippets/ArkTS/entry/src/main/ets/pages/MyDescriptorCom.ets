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
* FAQ:如何在ArkTS中实现自定义装饰器能力
 */

// [Start my_descriptor]
function MyDescriptor(target: Object, key: string, descriptor: PropertyDescriptor) {
  const originalMethod: Function = descriptor.value
  descriptor.value = (...args: Object[]) => {
    // Get the name, input parameters, and return value of the decorated method
    console.log(`Calling ${target.constructor?.name} method ${key} with argument: ${args}`)
    const result: Object = originalMethod(...args)
    console.log(`Method ${key} returned: ${result}`)
    return result
  }
  return descriptor
}

@Entry
@Component
export  struct MyDescriptorCom {
  @State message: string = 'Hello World';

  @MyDescriptor
  demoFunc(str:string) {
    return str
  }

  aboutToAppear(): void {
    this.demoFunc('DemoTest')
  }
  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End my_descriptor]