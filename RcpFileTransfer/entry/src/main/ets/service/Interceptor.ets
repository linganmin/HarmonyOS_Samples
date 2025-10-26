/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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
/**
 * 最佳实践：基于RCP的文件上传与下载
 */
import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { showErrorMessage } from '../utils/CommonUtil';
import { Logger } from '../utils/Logger';

// [Start status]
export class StatusCodeInterceptor implements rcp.Interceptor {
  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    const url = context.request.url;
    return next.handle(context).then((res: rcp.Response) => {
      if ([200, 206].includes(res.statusCode)) {
        return Promise.resolve(res);
      } else {
        const message = `Failed to ${url}: statusCode is ${res.statusCode}, message is ${res.toString()}`;
        Logger.error(message);
        showErrorMessage(message);
        return Promise.reject(new Error(message));
      }
    }).catch((err: BusinessError) => {
      Logger.error(`Failed to ${url}: Code is ${err.code}, message is ${err.data}`);
      // cancel request don't show err message prompt.
      if (err.code !== 1007900992) {
        showErrorMessage(JSON.stringify(err.data));
      }
      return Promise.reject(err);
    });
  }
}
// [End status]