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
* FAQ:如何解析JSON字符串为实例对象
 */

// [Start test_json]
import { Type, plainToClass } from 'class-transformer'
import "reflect-metadata"

// Assuming accepted JSON data
let testJSON: Record<string, ESObject> = {
  'id': 1,
  'firstName': "Johny",
  'lastName': "Cage",
  'age': 27,
  'arr': [
    {
      'name': 'john'
    },
    {
      'name': 'tom'
    }
  ],
  'instanceA': {
    'name': 'john'
  },
}

// If there is a corresponding nested structure, the corresponding type needs to be specified
class A {
  name: string = 'john';

  getName(): string {
    return this.name
  }
}

// When attempting to convert an object with nested objects, it is necessary to know the object type to be converted and use the @ Type decorator to implicitly specify the object type contained in each attribute
class User {
  id: number = 0;
  firstName: string = '';
  lastName: string = '';
  age: number = 0;
  @Type(() => A)
  arr: A[] = [new A()]
  @Type(() => A)
  instanceA: A = new A();

  getName() {
    return this.firstName + " " + this.lastName;
  }

  isAdult() {
    return this.age > 36 && this.age < 60;
  }
}

@Entry
@Component
struct parsingJSONStringsIntoInstanceObjects {
  aboutToAppear(): void {
    const instance = plainToClass(User, testJSON);
    console.info('instance:' + JSON.stringify(instance))
  }

  build() {

  }
}
// [End test_json]