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

import { convertxml, util, xml } from '@kit.ArkTS';
import { logger } from '@ohos/common';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'ConvertXmlUtil';

export function serializerNode(): string {
  let arrayBuffer = new ArrayBuffer(2048);
  let serializer = new xml.XmlSerializer(arrayBuffer);
  serializer.setDeclaration();
  serializer.setNamespace('h', 'https://gitee.com/harmonyos');
  serializer.startElement('note');
  serializer.setAttributes('importance', 'high');
  serializer.addEmptyElement('b');
  serializer.startElement('title');
  serializer.setAttributes('lang', 'en');
  serializer.setText('Everyday');
  serializer.endElement();
  serializer.setComment('contact information');
  serializer.setText('ZhangSan 18712345678');
  serializer.setCDATA('CData');
  serializer.setDocType('DocType');
  serializer.endElement();
  let view: Uint8Array = new Uint8Array(arrayBuffer); // Use Uint8Array to read data in the array buffer.
  let textDecoder: util.TextDecoder = util.TextDecoder.create(); // Invoke the TextDecoder class of the util module.
  let res: string = textDecoder.decodeToString(view); // Decode the view.
  return res;
}

export function parserNode(strXml: string): string {
  let textEncoder: util.TextEncoder = new util.TextEncoder();
  let arrBuffer: Uint8Array = textEncoder.encodeInto(strXml);
  let parser: xml.XmlPullParser = new xml.XmlPullParser(arrBuffer.buffer as object as ArrayBuffer, 'UTF-8');
  let str: string = '';
  const tagFunc = (name: string, value: string): boolean => {
    let tagStr = name + ' ' + value;
    str += 'tag-' + tagStr + `\n`;
    return true;
  };

  const attFunc = (name: string, value: string): boolean => {
    let attStr = name + ' ' + value;
    str += 'attri-' + attStr + `\n`;
    return true;
  };

  const tokenFunc = (key: xml.EventType, info: xml.ParseInfo) => {
    let tokenStr = `${key} ${info.getDepth()} ${info.getColumnNumber()} ` +
      `${info.getLineNumber()} ${info.getAttributeCount()} ${info.getName()} ` +
      `${info.getText()} ${info.isEmptyElementTag()} ${info.isWhitespace()}`;
    str += 'token-' + tokenStr + `\n`;
    return true;
  };

  let options: xml.ParseOptions = {
    supportDoctype: true,
    ignoreNameSpace: true,
    tagValueCallbackFunction: tagFunc,
    attributeValueCallbackFunction: attFunc,
    tokenValueCallbackFunction: tokenFunc
  };
  parser.parseXml(options);
  return str;
}

export function convertNode(input: string): string {
  logger.info(TAG, 'convertNode start');
  let options: convertxml.ConvertOptions = {
    trim: false,
    declarationKey: '_declaration',
    instructionKey: '_instruction',
    attributesKey: '_attributes',
    textKey: '_text',
    cdataKey: '_cdata',
    doctypeKey: '_doctype',
    commentKey: '_comment',
    parentKey: '_parent',
    typeKey: '_type',
    nameKey: '_name',
    elementsKey: '_elements'
  };
  let conv = new convertxml.ConvertXML();
  logger.info(TAG, 'convertNode new ConvertXML');
  let result = '';
  try {
    result = JSON.stringify(conv.fastConvertToJSObject(input, options));
  } catch (error) {
    let err = error as BusinessError;
    hilog.error(0x0000, 'convertNode', `fastConvertToJSObject failed, error code=${err.code}, message=${err.message}`);
  }
  logger.info(TAG, `convertNode conv.convert result = ${result}`);
  return result;
}