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

import { http } from '@kit.NetworkKit';
import { systemDateTime } from '@kit.BasicServicesKit';
import { FunctionEntryData } from '../viewmodel/longlist/FunctionEntryData';
import { WaterFlowData } from '../viewmodel/longlist/WaterFlowData';
import { WaterFlowHeadData } from '../viewmodel/longlist/WaterFlowHeadData';
import { WaterFlowDescriptionData } from '../viewmodel/longlist/WaterFlowDescriptionData';
import { CommonConstants } from '../constants/CommonConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';

const URL: string = 'https://devecostudio-drcn.op.hicloud.com/solution/v1/getSceneMockData' +
  '?scene={scene}&fileName={fileName}&pageNum={pageNum}&pageSize={pageSize}';

export class NetworkUtil {
  private waterFlowIndex: number = CommonConstants.NUMBER_DEFAULT_VALUE;
  private functionIndex: number = CommonConstants.NUMBER_DEFAULT_VALUE;

  static async getResponse(url: string, params: string[]): Promise<Record<string, object> | null> {
    try {
      const beginTime = systemDateTime.getTime();
      url = url.replace('{scene}', params[0])
        .replace('{fileName}', params[1])
        .replace('{pageNum}', params[2])
        .replace('{pageSize}', params[3]);
      let data: http.HttpResponse = await http.createHttp().request(
        url,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json'
          },
          expectDataType: http.HttpDataType.STRING,
          usingCache: true,
        });
      const endTime = systemDateTime.getTime() - beginTime;
      hilog.info(0x000, 'progress', 'getResponse success, url:' + url + ', cost: ' + endTime);
      if (data && data.responseCode === http.ResponseCode.OK && typeof data.result === 'string') {
        let arr: Record<string, object> = JSON.parse(data.result);
        return arr;
      } else {
        return null;
      }
    } catch (err) {
      hilog.error(0x000, 'progress', 'getResponse err:', JSON.stringify(err));
      return null;
    }
  }

  async getFunctionEntryData(scene: string, fileName: string, pageNum: number,
    pageSize: number): Promise<FunctionEntryData[]> {
    let result: FunctionEntryData[] = [];
    let params: string[] = [scene, fileName, pageNum + '', pageSize + ''];
    try {
      let arr = await NetworkUtil.getResponse(URL, params);
      if (arr) {
        let tempData = arr.data as object[];
        let result: FunctionEntryData[] = [];
        for (let i = 0; i < tempData.length; i++) {
          let tmp = tempData[i] as Record<string, string>;
          let temp = new FunctionEntryData(tmp.icon, tmp.name, tmp.name_en, tmp.url, this.functionIndex);
          this.functionIndex++;
          result.push(temp);
        }
        return result;
      }
    } catch (err) {
      hilog.error(0x000, 'progress', 'getFunctionEntryData err:', JSON.stringify(err));
    }
    return result;
  }

  async getWaterFlowData(scene: string, fileName: string, pageNum: number,
    pageSize: number): Promise<WaterFlowData[]> {
    let result: WaterFlowData[] = [];
    let params: string[] = [scene, fileName, pageNum + '', pageSize + ''];
    try {
      let arr = await NetworkUtil.getResponse(URL, params);
      if (arr) {
        let tempData = arr['data'] as object[];
        let result: WaterFlowData[] = [];
        for (let i = 0; i < tempData.length; i++) {
          let tmp = tempData[i] as Record<string, string>;
          let temWaterFlowHead =
            new WaterFlowHeadData(tmp.thumbnails, tmp.source, parseInt(tmp.width), parseInt(tmp.height), tmp.type);
          let temWaterFlowDescription =
            new WaterFlowDescriptionData(tmp.title, tmp.title_en, tmp.user_image, tmp.vip_sign,
              tmp.nick_name, parseInt(tmp.collections_count), tmp.url, this.waterFlowIndex);
          let temWaterFlow = new WaterFlowData(temWaterFlowHead, temWaterFlowDescription);
          this.waterFlowIndex++;
          result.push(temWaterFlow);
        }
        return result;
      }
    } catch (err) {
      hilog.error(0x000, 'progress', 'getWaterFlowData err: ', JSON.stringify(err));
    }
    return result;
  }
}