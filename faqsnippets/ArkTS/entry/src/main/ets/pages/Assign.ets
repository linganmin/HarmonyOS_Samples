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
* FAQ:如何合并两个对象
 */

// [Start assign]
function assign(target: Record<string, Object>, ...source: Object[]): Record<string, Object> {
  for (const items of source) {
    for (const key of Object.keys(items)) {
      target[key] = Reflect.get(items, key)
    }
  }
  return target;
}
// [End assign]

// [Start i_merge_sub]
interface IMergeSub {
  testString: string,
  testObject?: IMergeSub,
  testArray?: Array<number>
}


interface IMerge {
  a: IMergeSub,
  b: IMergeSub[],
  c: string[],
  d: number
}


export function testAssign() {
  let objectOne: IMerge =
    {
      a: {
        testString: 'objectOne-a-testString',
        testObject: {
          testString: 'objectOne-a-testObject-testString'
        },
        testArray: [1]
      },
      b: [{
        testString: 'objectOne-b-testString',
        testObject: {
          testString: 'objectOne-b-testObject-testString'
        },
        testArray: [2]
      }],
      c: ['objectOne-c'],
      d: 3
    }


  let objectTwo: Record<string, Object> = {
    'a': 'objectTwo-a',
    'c': ['objectTwo-c'],
    'e': 1
  }


  let objectThree: Record<string, Object> = {
    'f': ['objectThree-f']
  }


  // Merge multiple objects, and the properties of both Object One and Object Two will be attached to Object Three. When the property names are the same, the properties of the object with the lower index will overwrite the properties of the previous object
  const multiObjectMerged = assign(objectThree, objectTwo, objectOne);
  console.log('multiObjectMerged is:' + JSON.stringify(multiObjectMerged));
  console.log('objectThree is:' + JSON.stringify(objectThree));


  // Merge the properties of Object One into Object Two, and the value of Object Two will change. When the property names are the same, Object One will overwrite the properties of Object Two
  const objectMerged = assign(objectTwo, objectOne);
  console.log('objectTwo is:' + JSON.stringify(objectTwo));
  console.log('objectMerged is:' + JSON.stringify(objectMerged));
}
// [End i_merge_sub]