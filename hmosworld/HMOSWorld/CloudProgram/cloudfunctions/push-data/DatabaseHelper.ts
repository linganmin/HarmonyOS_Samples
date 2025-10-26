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

import { cloud, CloudDBCollection, CloudDBZoneQuery } from '@hw-agconnect/cloud-server';
import request from 'request';
import axios from 'axios';
import { form_info as FormInfo } from './model/form_info';
import { resource as Resource } from './model/resource';
import { ResourceResp } from './model/ResourceResp';

const ZONE_NAME = 'HMOSWorld';
const FEED_TYPE = 'feed';
const ARTICLE_TYPE = 'article';

export class DatabaseHelper {
  logger;
  colFormInfo: CloudDBCollection<FormInfo>;
  colResource: CloudDBCollection<Resource>;

  constructor(logger) {
    this.logger = logger;
    this.colFormInfo = cloud.database({ zoneName: ZONE_NAME }).collection(FormInfo);
    this.colResource = cloud.database({ zoneName: ZONE_NAME }).collection(Resource);
  }

  async getToken(): Promise<string> {
    const data = {
      'grant_type': 'client_credentials',
      'client_id': 'Client ID',
      'client_secret': 'Client Secret'
    };
    const headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    let logger2 = this.logger;
    const url = 'https://oauth-login.cloud.huawei.com/oauth2/v3/token';
    return new Promise((resolve, reject) => {
      request.post({
        url: url,
        form: data,
        headers: headers
      }, function (err, httpResponse, body) {
        logger2.info(`[push-data] sendMessage request push-data token======${JSON.stringify(httpResponse)}`);
        if (httpResponse.statusCode == 200) {
          const result = JSON.parse(body);
          logger2.info(`[push-data] getToken success:${JSON.stringify(body)}`);
          const tokenData = result.token_type + " " + result.access_token;
          resolve(tokenData);
        } else {
          reject(err);
        }
      })
    });
  }

  async queryResData(): Promise<ResourceResp[]> {
    const resList: ResourceResp[] = [];
    try {
      const feedResourceData = await this.queryResourceByType(FEED_TYPE);
      const articleResourceData = await this.queryResourceByType(ARTICLE_TYPE);
      const resourceData: Resource[] = feedResourceData.concat(articleResourceData);
      if (resourceData.length > 0) {
        for (let i = 0; i < resourceData.length; i++) {
          const dataQ: Resource = resourceData[i];
          resList.push(new ResourceResp(
            dataQ.getId(),
            dataQ.getTitle(),
            dataQ.getBrief(),
            dataQ.getType(),
            dataQ.getHeader_src(),
            dataQ.getWeb_url()
          ));
        }
      }
      return resList;
    } catch (error) {
      this.logger.error(`[push-data] queryResData error: ${error}`);
    }
  }

  async queryResourceByType(type: string): Promise<Resource[]> {
    const resourceQuery: CloudDBZoneQuery<Resource> = this.colResource.query().equalTo('tag', 2).equalTo('type', type);
    if (type === FEED_TYPE) {
      resourceQuery.limit(3);
    } else {
      resourceQuery.limit(2);
    }
    const resourceData: Resource[] = await resourceQuery.get();
    return resourceData;
  }

  async convertUrl(resData: ResourceResp[], credential, authorization: string) {
    const config = {
      "headers": {
        'Content-Type': 'application/json',
        'Authorization': authorization,
        'push-type': 1
      }
    };
    for (let index = 0; index < resData.length; index++) {
      const api: string = 'https://push-api.cloud.huawei.com/v2/' + credential.project_id + '/images:verify';
      const params = {
        "imageUrl": resData[index].headerImageUrl
      };

      await axios.post(api, params, config)
        .then(response => {
          resData[index].headerImageUrl = response.data.downloadUrl;
        })
        .catch(error => {
          this.logger.error(`[push-data] convertUrl error: ${error.message}`);
        })
    }
  }

  async pushData(resData: ResourceResp[], formInfo: FormInfo, credential, authorization: string) {
    try {
      const config = {
        "headers": {
          'Content-Type': 'application/json',
          'Authorization': authorization,
          'push-type': 1
        }
      };
      const api: string = 'https://push-api.cloud.huawei.com/v3/' + credential.project_id + '/messages:send';
      const arr = [0, 1, 2, 3, 4];
      arr.sort(function () {
        return Math.random() - 0.5
      });
      const data = [
        {
          card0: resData[arr[0]],
        }, {
        card1: resData[arr[1]],
      }, {
        card2: resData[arr[2]],
      }, {
        card3: resData[arr[3]],
      }, {
        card4: resData[arr[4]],
      }];
      const image_data = [
        {
          "keyName": "image0",
          "url": resData[arr[0]].headerImageUrl,
          "require": 0
        }, {
        "keyName": "image1",
        "url": resData[arr[1]].headerImageUrl,
        "require": 0
      }, {
        "keyName": "image2",
        "url": resData[arr[2]].headerImageUrl,
        "require": 0
      }, {
        "keyName": "image3",
        "url": resData[arr[3]].headerImageUrl,
        "require": 0
      }, {
        "keyName": "image4",
        "url": resData[arr[4]].headerImageUrl,
        "require": 0
      }];
      for (let index = 0; index < resData.length; index++) {
        const params = {
          "payload": {
            "formData": data[arr[index]],
            "images": [
              image_data[arr[index]]
            ],
            "version": 0,
            "formId": Number(formInfo.getForm_id()),
            "moduleName": "phone",
            "formName": "widget",
            "abilityName": "EntryFormAbility",
            'push-type': 1
          },
          "pushOptions": {
            "testMessage": true
          },
          "target": {
            "token": [formInfo.getToken()]
          }
        };

        await axios.post(api, params, config)
          .then(response => {
            this.logger.info(`push-data success: ${JSON.stringify(response.data)}`);
          })
          .catch(error => {
            this.logger.error(`[push-data] sendMessage error: ${error.message}`);
          });
      }
      this.logger.info(`[push-data] end post`);
    } catch (error) {
      this.logger.error(`[push-data] pushData error: ${error}`);
    }
  }

  async queryFormInfo(): Promise<FormInfo[]> {
    try {
      const formInfoQuery: CloudDBZoneQuery<FormInfo> = this.colFormInfo.query();
      const formInfoData: FormInfo[] = await formInfoQuery.get();
      return formInfoData;
    } catch (error) {
      this.logger.error(`[push-data] queryFormInfo error: ${error}`);
      return undefined;
    }
  }
}