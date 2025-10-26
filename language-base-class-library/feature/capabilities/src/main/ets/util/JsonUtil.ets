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

import { JSON } from '@kit.ArkTS';
import { logger } from '@ohos/common';

const jsonText = '{"name":"John","age":30,"city":"Chongqing"}';

const TAG: string = 'JsonUtil';

export function deleteAttribute() {
  let Tom = JSON.parse(jsonText) as Record<string, number | string | boolean>;
  JSON.remove(Tom, 'city');
  return JSON.stringify(Tom);
}

export function searchAttribute() {
  let Tom = JSON.parse(jsonText) as Record<string, number | string | boolean>;
  let result = JSON.has(Tom, 'name');
  return `the 'name' is inside, ${result}`;
}

export function addAndUpdateAttribute() {
  let Tom = JSON.parse(jsonText) as Record<string, number | string | boolean>;
  // Additions and modifications.
  Tom['height'] = 180;
  Tom['age'] = 18;
  return JSON.stringify(Tom);
}

export function funJsonToString() {
  // Converting a Common Object to a String.
  interface Person {
    name: string;
    age: number;
    city: string;
  }

  let normalObject: Person = {
    name: 'John',
    age: 18,
    city: 'Chongqing'
  }

  let jsonString: string = JSON.stringify(normalObject);
  logger.info(TAG, jsonString); // Output: {"name":"John","age":18,"city":"Chongqing"}

  // Use stringify() to manipulate a specific object.
  let specialObject: Person = {
    name: 'John',
    age: 18,
    city: 'Chongqing'
  }
  type Transformer = (this: Object, key: string, value: Object) => Object | undefined | null;
  // Define the replacer function to process specific object attributes during serialization.
  let replacer: Transformer = (key, value) => {
    if (key === 'city') {
      return (value as string).toLowerCase();
    }
    return value;
  }
  // JSON serialization using the replacer function.
  let jsonStringSpecial: string = JSON.stringify(specialObject, replacer);
  logger.info(TAG, jsonStringSpecial); // Output {"name":"John","age":18,"city":"chongqing"}
  return jsonStringSpecial;
}

export function funJsonToMap() {
  // JSON conversion Map.
  let parsedData = JSON.parse(jsonText)!
  return `${new Map(Object.entries(parsedData))}`;
}

export function funMapToJson() {
  const map = new Map([
    ['name', 'John'],
    ['age', '18'],
    ['city', 'Chongqing']
  ]);
  let jsonObject: Record<string, Object> = {};
  map.forEach((value, key) => {
    if (key !== undefined && value !== undefined) {
      jsonObject[key] = value;
    }
  })
  let info: string = JSON.stringify(jsonObject);
  logger.info(TAG, info);
  return info;
}

let options: JSON.ParseOptions = {
  bigIntMode: JSON.BigIntMode.PARSE_AS_BIGINT,
}

export function deserializationLargeNum() {
  let numberText = '{"largeNumber":112233445566778899}';
  let numberObj = JSON.parse(numberText, (key: string, value: Object | undefined | null): Object | undefined | null => {
    if (key === 'largeNumber') {
      return value;
    }
    return value;
  }, options) as Object;

  return `${(numberObj as object)?.["largeNumber"]}`;
}