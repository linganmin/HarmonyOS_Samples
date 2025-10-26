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

import { http } from '@kit.NetworkKit'
import { hilog } from '@kit.PerformanceAnalysisKit';
import { X2jOptions, XMLParser } from '@ifbear/fast-xml-parser'; // use command $ ohpm install @ifbear/fast-xml-parser
import { TAG, DOMAINID } from './CommonConstants';

class HttpHeader {
  public contentType: string;
  constructor(contentType: string) {
    this.contentType = contentType;
  }
}

namespace AssetAccelManifest {
  export interface AssetAccelResource {
    fileId: number;
    fileName: string;
    downloadUrl: string;
    fileLength: number;
    resourceSHA256: string;
  }

  export interface AssetAccelVersionFiles {
    versionFile: Array<AssetAccelResource>;
  }

  export interface AssetAccelPackageVersion {
    packageName: string;
    versionNo: string;
    versionFiles: AssetAccelVersionFiles;
  }

  export interface AssetAccelPackageInfo {
    packageVersion: AssetAccelPackageVersion;
  }

  export interface AssetAccelManifestObject {
    packageInfo: AssetAccelPackageInfo;
  }

  export function requestRemoteManifest(manifestAddress: string): Promise<AssetAccelPackageVersion> {
    hilog.info(DOMAINID, TAG, `requestRemoteManifest start, manifestAddress: ${manifestAddress}`);
    return new Promise((resolve, reject) => {
      let httpRequest = http.createHttp();
      let options: http.HttpRequestOptions = {
        header: new HttpHeader('application/json'),
        expectDataType: http.HttpDataType.STRING
      }
      httpRequest.request(manifestAddress, options, (error: Error, data: http.HttpResponse) => {
        if (error) {
          hilog.error(DOMAINID, TAG, `failed to requestRemoteManifest, errMessage: ${error.message}`);
          reject(error.message);
          return;
        }
        const options :X2jOptions = {
          ignoreAttributes: false,
          attributeNamePrefix: '@_',
          isArray: (tagName: string) => {
            return tagName === 'versionFile';
          }
        };
        const parser = new XMLParser(options);
        let manifestObject : AssetAccelManifestObject = parser.parse(data.result as string) as AssetAccelManifestObject;
        manifestObject.packageInfo.packageVersion.versionNo = manifestObject.packageInfo.packageVersion.versionNo + '';
        hilog.info(DOMAINID, TAG, `remote version: ${manifestObject.packageInfo.packageVersion.versionNo}`);
        resolve(manifestObject.packageInfo.packageVersion);
      })
    })
  }
}

export default AssetAccelManifest;