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
* FAQ:如何通过判断函数入参类型实现不同代码逻辑
 */

// [Start params_type]
class Game {
}


function solve(message: number | string | boolean | Map<string, number> | Record<string, number> | Game) {
  // Game：Type judgment
  if (message instanceof Game) {
    console.info('Game');
    return;
  }


  // Retrieve the constructor corresponding to the parameter and convert it to a string, then extract the string
  let typeStr: string = message.constructor.toString().substring(9, 12);
  // Determine the type corresponding to typeStr
  switch (typeStr) {
    case 'Num':
      console.info('number type');
      break;
    case 'Str':
      console.info('string type');
      break;
    case 'Boo':
      console.info('boolean type');
      break;
    case 'Map':
      console.info('Map type');
      break;
    case 'Obj':
      console.info('Record type');
      break;
  }
}


let gameVal: Game = '';
let mapVal = new Map<string, number>();
mapVal.set('width', 100);
mapVal.set('height', 100);
let recordVal: Record<string, number> = { 'wight': 100, 'score': 100 };


@Entry
@Component
struct ParamsType {
  build() {
    Row() {
      Column() {
        Button('get params type')
          .onClick(() => {
            solve(100);
            solve('100');
            solve(true);
            solve(mapVal);
            solve(recordVal);
            solve(gameVal);
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End params_type]