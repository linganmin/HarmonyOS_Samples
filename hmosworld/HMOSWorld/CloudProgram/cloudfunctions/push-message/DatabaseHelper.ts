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
import * as jsrsasign from 'jsrsasign';
import request from 'request';
import { resource as Resource } from './model/resource';
import { ResourceResp } from './model/ResourceResp';
import { user_push_token as UserPushToken } from './model/user_push_token';

const ZONE_NAME = 'HMOSWorld';

const SEND_URL = 'https://api.push.hicloud.com/v3/project_id/messages:send';
const PRIVATE_KEY = 'private_key';
const ISS = 'sub_account';
const KID = 'key_id';

export class DatabaseHelper {
  logger;
  colResource: CloudDBCollection<Resource>;
  colUserPushToken: CloudDBCollection<UserPushToken>;

  constructor(logger) {
    this.logger = logger;
    this.colResource = cloud.database({ zoneName: ZONE_NAME }).collection(Resource);
    this.colUserPushToken = cloud.database({ zoneName: ZONE_NAME }).collection(UserPushToken);
  }

  async pushMessage(): Promise<string | undefined> {
    let result = undefined;
    const pushTokens: string[] = [];
    try {
      // Obtain all users' pushToken.
      const cloudDBZoneQuery: CloudDBZoneQuery<UserPushToken> = this.colUserPushToken.query();
      const userPushTokens: UserPushToken[] = await cloudDBZoneQuery.get();
      if (userPushTokens.length > 0) {
        // get a random resource
        const randomResource: ResourceResp = await this.getRandomResource();
        if (!randomResource) {
          return result;
        }

        for (let index = 0; index < userPushTokens.length; index++) {
          const element: UserPushToken = userPushTokens[index];
          pushTokens.push(element.getPush_token());
        }

        // Request token for verification.
        const authorization: string = this.getAuthorization();
        // Send messages push request.
        for (let i = 0; i < pushTokens.length; i += 10) {
          result = await this.sendMessage(pushTokens.slice(i, i + 10), randomResource, authorization);
        }
      }
      return result;
    } catch (error) {
      this.logger.info(`query user error: ${error}`);
    }
  }

  async sendMessage(pushTokens, randomResource: ResourceResp, authorization): Promise<string> {
    let logger2 = this.logger;
    const headers = {
      "push-type": 0,
      "Authorization": authorization
    };

    const postData = {
      "payload": {
        "notification": {
          // Indicates the category of notification messages. MARKETING is an information marketing message
          "category": "MARKETING",
          "title": randomResource.title,
          "body": randomResource.brief,
          "clickAction": {
            "actionType": 0,
            "data": {
              "articleId": randomResource.id,
              "type": randomResource.type,
              "webUrl": randomResource.webUrl
            }
          }
        }
      },
      "target": {
        "token": pushTokens
      },
      "pushOptions": {
        "testMessage": true
      }
    };
    return new Promise((resolve, reject) => {
      // send post request
      request.post({
        url: SEND_URL,
        form: JSON.stringify(postData),
        headers: headers
      }, function (err, httpResponse, body) {
        logger2.info(`sendMessage request: ${httpResponse.statusMessage}`);
        const result = JSON.parse(body);
        if (httpResponse.statusCode == 200 && (result.code === "80000000" || result.code === "80100000")) {
          logger2.info(`sendMessage success: ${JSON.stringify(body)}`);
          resolve(result.msg);
        } else {
          reject(err);
        }
      })
    });
  }

  async getRandomResource(): Promise<ResourceResp | undefined> {
    let randomResource: ResourceResp | undefined;
    try {
      const resourceQuery: CloudDBZoneQuery<Resource> = this.colResource.query()
        .orderByDesc("views_count")
        .notEqualTo('brief', '')
        .limit(5);
      const resourceData: Resource[] = await resourceQuery.get();
      if (resourceData.length > 0) {
        const randomElement: Resource = resourceData[Math.floor(Math.random() * resourceData.length)];
        randomResource = this.getResource(randomElement);
      }
      return randomResource;
    } catch (error) {
      this.logger.info(`getRandomResource error ${error}`);
    }
  }

  getResource(dataQ: Resource): ResourceResp {
    return new ResourceResp(
      dataQ.getId(),
      dataQ.getTitle(),
      dataQ.getBrief(),
      dataQ.getHeader_src(),
      dataQ.getType(),
      dataQ.getWeb_url(),
      dataQ.getPublish_date(),
      null,
      dataQ.getViews_count(),
      dataQ.getCollect_count(),
      dataQ.getLikes_count(),
      dataQ.getTag(),
      dataQ.getBanner_src(),
      dataQ.getMedia_src(),
      null, // isLiked
      null, // isCollected
      null// isViewed
    );
  }

  getAuthorization(): string {
    try {
      const iat: number = Number.parseInt((new Date().getTime() / 1000).toString());
      const exp: number = iat + 3600;
      const header: string = JSON.stringify({
        alg: "RS256",
        typ: "JWT",
        kid: KID
      })
      const payload: string = JSON.stringify({
        aud: "https://oauth-login.cloud.huawei.com/oauth2/v3/token",
        iss: ISS,
        exp: exp,
        iat: iat
      });
      const token: string = jsrsasign.jws.JWS.sign(
        "RS256",
        header,
        payload,
        PRIVATE_KEY
      );
      return token;
    } catch (error) {
      this.logger.error(`getAuthorization error: ${error}`);
    }
  }
}