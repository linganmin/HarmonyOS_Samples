/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { convertxml, List } from '@kit.ArkTS';

export class XmlUtils {
  /**
   * Converts a string to an object.
   * @param xml a string
   * @param lCamel Camel Casing
   * @returns Returns an object on successful conversion, otherwise returns null.
   * */
  static xmlToObj(xml: string, lCamel?: boolean): object | null {
    try {
      let conv = new convertxml.ConvertXML();
      let result: object = conv.fastConvertToJSObject(xml);
      let model = XmlUtils.getElementValue(result['_elements'][0], null, true, lCamel || true);
      return model;
    } catch (err) {
      return null;
    }
  }

  private static lowerCamel(name: string) {
    let tempName = name;
    if (tempName.length > 0) {
      let first = tempName.substring(0, 1);
      tempName = first.toLowerCase() + tempName.substring(1);
    }
    return tempName;
  }


  private static getElementValue(element: object, pObj: object | null, root: boolean, lCamel: boolean): object | null {
    try {
      let name: string = element['_name'];
      if (name) {
        name = lCamel ? XmlUtils.lowerCamel(name) : name;
      }
      let type: string = element['_type'];
      if (type == 'text') {
        return element['_text'];
      }

      if (!Object.keys(element).includes('_elements')) {
        return null;
      }

      let elements: List<object> = element['_elements'];
      let obj = pObj;
      if (!obj) {
        obj = new Object();
      }

      if (type == 'element') {
        for (const _element of elements) {
          let _name: string = _element['_name'];
          if (!_name) {
            let value = XmlUtils.getElementValue(_element, obj, false, lCamel);
            if (typeof value == 'string' && value === 'null') {
              value = null;
            }
            if (!root) {
              return value;
            }
            obj[name] = value;
            return obj;
          } else {
            _name = lCamel ? XmlUtils.lowerCamel(_name) : _name;
            let value = XmlUtils.getElementValue(_element, null, false, lCamel);
            if (value) {
              if (obj[_name]) {
                if (Array.isArray(obj[_name]) || obj[_name] instanceof List) {
                  let array: List<object> = obj[_name];
                  array.add(value);
                  obj[_name] = array;
                } else {
                  let array = new List<object>();
                  array.add(obj[_name]);
                  array.add(value);
                  obj[_name] = array;
                }
              } else {
                obj[_name] = value;
              }
            } else {
              obj[_name] = null;
            }
          }
        }
      }

      if (root) {
        let rObj: object = new Object();
        rObj[name] = obj;
        return rObj;
      }
      return obj;
    } catch (error) {
      return null;
    }
  }
}
