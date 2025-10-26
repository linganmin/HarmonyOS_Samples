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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import { convertxml, util } from '@kit.ArkTS';
import { preferences } from '@kit.ArkData';

interface XmlAttributes {
  name?: string;
  value?: string;
}

interface XmlElement {
  _elements?: XmlElement[];
  _name?: string;
  _type?: string;
  _text?: string;
  _attributes?: XmlAttributes;
}

/**
 * XML file migration and conversion management.
 */
export default class SpTransferManager {
  /**
   * XML file migration and conversion.
   *
   * @param context context.
   */
  async transfer(context: common.Context): Promise<void> {
    // Step 1: migrate the HarmonyOS 4.0 XML file to the specified directory of HarmonyOS NEXT.
    let result = this.moveSpFile(context);
    if (!result) {
      hilog.error(0x0000, 'BackupRestore SpTransferManager', 'moveSpFile failed');
      return;
    }

    // Step 2: Obtain the text content of the HarmonyOS 4.0 XML file.
    let xmlContent = this.getSourceXmlStr(context);

    // Step 3: convert the XML text content into an XMLElement object.
    let xmlElement = this.transferSourceXmlToXmlElement(xmlContent);

    // Step 4: parse the XMLElement to obtain the data in the XML file.
    let dataMap = this.parseXmlElement(xmlElement);

    // Step 5: insert the parsed dual sp data into the HarmonyOS NEXT database.
    result = await this.insertDataToTargetSp(context, dataMap);
    if (!result) {
      hilog.error(0x0000, 'BackupRestore SpTransferManager', 'insertDataToTargetSp failed');
      return;
    }

    // Step 6, retrieve data from the database.
    let resultMap = await this.getDataFromTargetSp(context);
    resultMap.forEach((value: preferences.ValueType, key: string) => {
      hilog.info(0x0000, 'BackupRestore SpTransferManager', `resultMap k = ${key}, v = ${value}`);
    })
  }

  /**
   * Move HarmonyOS 4.0 XML file to HarmonyOS NEXT.
   *
   * @param context context.
   * @return success return true, failed return false.
   */
  private moveSpFile(context: common.Context): boolean {
    try {
      let sourceSpPath = '/data/storage/el2/backup/restore/com.example.backuprestore/ce/shared_prefs';
      if (!fileIo.accessSync(sourceSpPath)) {
        hilog.error(0x0000, 'BackupRestore SpTransferManager', `moveSpFile, ${sourceSpPath} can't access`);
        return false;
      }
      let listFileNames: string[] = fileIo.listFileSync(sourceSpPath);
      if (!listFileNames || listFileNames.length === 0) {
        hilog.error(0x0000, 'BackupRestore SpTransferManager', `moveSpFile, ${sourceSpPath} is not file`);
        return false;
      }

      let targetPath: string = context.preferencesDir;
      listFileNames.forEach((fileName: string) => {
        let srcPath = `${sourceSpPath}/${fileName}`;
        let destPath = `${targetPath}/${fileName}`;
        if (fileIo.statSync(srcPath).isFile()) {
          fileIo.moveFileSync(srcPath, destPath);
        } else {
          fileIo.moveDirSync(srcPath, targetPath);
        }
      });
      return true;
    } catch (error) {
      hilog.error(0x0000, 'BackupRestore SpTransferManager', `moveSpFile, error: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * Read the text content of the XML file.
   *
   * @param context context.
   * @return Text content of XML file.
   */
  private getSourceXmlStr(context: common.Context): string {
    let xmlContent: string = '';
    try {
      let sourceSpFilePath: string = `${context.preferencesDir}/source_sp.xml`;
      let fileStream = fileIo.createStreamSync(sourceSpFilePath, 'r');
      if (!fileStream) {
        hilog.error(0x0000, 'BackupRestore SpTransferManager', 'getSourceXmlStr failed');
        return xmlContent;
      }

      let bufArray: ArrayBuffer[] = [];
      let totalLength = 0;
      const READ_DATA_SIZE = 1024 * 1024;
      let buffer = new ArrayBuffer(READ_DATA_SIZE);
      let len = fileStream.readSync(buffer);
      while (len !== 0) {
        totalLength += len;
        if (len < READ_DATA_SIZE) {
          buffer = buffer.slice(0, len);
          bufArray.push(buffer);
          break;
        }
        bufArray.push(buffer);
        buffer = new ArrayBuffer(READ_DATA_SIZE);
        len = fileIo.readSync(Number(fileStream), buffer);
      }
      let contentBuffer = new Uint8Array(totalLength);
      let offset = 0;
      bufArray.forEach(bufferArr => {
        let uInt8Arr = new Uint8Array(bufferArr);
        contentBuffer.set(uInt8Arr, offset);
        offset += uInt8Arr.byteLength;
      });
      let textDecoder = util.TextDecoder.create('utf-8', {
        ignoreBOM: false
      });
      xmlContent = textDecoder.decodeToString(new Uint8Array(contentBuffer), {
        stream: false
      });
      hilog.info(0x0000, 'BackupRestore SpTransferManager', `getSourceXmlStr, xmlContent = ${xmlContent}`);
    } catch (error) {
      hilog.error(0x0000, 'BackupRestore SpTransferManager', `getSourceXmlStr, error: ${JSON.stringify(error)}`);
    }
    return xmlContent;
  }

  /**
   * The text content of XML is an XMLElement object.
   *
   * @param xmlContent XML text content.
   * @return XmlElement Object corresponding to XML.
   */
  private transferSourceXmlToXmlElement(xmlContent: string): XmlElement {
    let result: XmlElement = {};
    if (!xmlContent) {
      hilog.error(0x0000, 'BackupRestore SpTransferManager', 'transferSourceXmlToXmlElement, xmlContent is empty');
      return result;
    }
    try {
      let conv = new convertxml.ConvertXML();
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
      let xmlJsonStr = JSON.stringify(conv.fastConvertToJSObject(xmlContent, options));
      hilog.info(0x0000, 'BackupRestore SpTransferManager',
        `transferSourceXmlToXmlElement, xmlJsonStr = ${xmlJsonStr}`);
      result = JSON.parse(xmlJsonStr) as XmlElement;
    } catch (error) {
      hilog.error(0x0000, 'BackupRestore SpTransferManager',
        `transferSourceXmlToXmlElement, error: ${JSON.stringify(error)}`);
    }
    return result;
  }

  /**
   * Parse the XMLElement object corresponding to the XML file.
   *
   * @param xmlElement xmlElement.
   * @return map store data in XML.
   */
  private parseXmlElement(xmlElement: XmlElement): Map<string, preferences.ValueType> {
    let dataMap = new Map<string, preferences.ValueType>();
    if (!xmlElement._elements || xmlElement._elements.length == 0) {
      return dataMap;
    }
    let rootNode = xmlElement._elements[0];
    if (!rootNode || !rootNode._elements) {
      return dataMap;
    }

    for (let i = 0; i < rootNode._elements.length; i++) {
      let item = rootNode._elements[i];
      let key = item._attributes?.name;
      if (!key) {
        continue;
      }
      let valueType = item._name;
      switch (valueType) {
        case 'string': {
          if (item._elements && item._elements.length > 0) {
            dataMap.set(key, item._elements[0]._text as string || '');
          }
          break;
        }
        case 'set': {
          if (item._elements) {
            let strArr: string[] = [];
            item._elements.forEach((setValue) => {
              if (setValue._elements && setValue._elements.length > 0) {
                let item = setValue._elements[0]._text as string || '';
                strArr.push(item);
              }
            })
            dataMap.set(key, strArr);
          }
          break;
        }
        case 'int':
        case 'float':
        case 'long':
        case 'boolean': {
          if (item._attributes) {
            dataMap.set(key, item._attributes.value as preferences.ValueType);
            break;
          }
        }
        default: {
          break;
        }
      }
    }
    return dataMap;
  }

  /**
   * Insert data into the database.
   *
   * @param context context.
   * @param dataMap Data to be inserted.
   * @return boolean success return true, failed return false.
   */
  private async insertDataToTargetSp(context: Context, dataMap: Map<string, preferences.ValueType>): Promise<boolean> {
    try {
      let targetSp = await preferences.getPreferences(context, 'target_sp.xml');
      dataMap.forEach((value, key) => {
        targetSp.put(key, value);
      })

      targetSp.flush(() => {
        hilog.info(0x0000, 'BackupRestore SpTransferManager', 'insertDataToTargetSp, flush success');
      });
      return true;
    } catch (error) {
      hilog.error(0x0000, 'BackupRestore SpTransferManager', `insertDataToTargetSp, error: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * Read data from the database.
   *
   * @param context context.
   * @return map Contains data from the database.
   */
  public async getDataFromTargetSp(context: Context): Promise<Map<string, preferences.ValueType>> {
    let dataMap = new Map<string, preferences.ValueType>();
    try {
      preferences.removePreferencesFromCacheSync(context, 'target_sp.xml');
      let targetSp = await preferences.getPreferences(context, 'target_sp.xml');

      dataMap.set('intData', targetSp.getSync('intData', 0));
      dataMap.set('floatData', targetSp.getSync('floatData', 0.0));
      dataMap.set('setData', targetSp.getSync('setData', []));
      dataMap.set('boolData', targetSp.getSync('boolData', true));
      dataMap.set('stringData', targetSp.getSync('stringData', ''));
      dataMap.set('longData', targetSp.getSync('longData', 0));
    } catch (error) {
      hilog.error(0x0000, 'BackupRestore SpTransferManager', `getDataFromTargetSp, error: ${JSON.stringify(error)}`);
    }
    return dataMap;
  }
}