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

// [Start response_header_remove_interceptor]
import { rcp } from '@kit.RemoteCommunicationKit';
import Logger from '../common/Logger';

export class ResponseCache {
  public readonly cache: Record<string, rcp.Response> = {};

  getResponse(url: string): rcp.Response {
    return this.cache[url];
  }

  setResponse(url: string, response: rcp.Response): void {
    this.cache[url] = response;
  }
}

// Define the ResponseCachingInterceptor interceptor
export class ResponseCachingInterceptor implements rcp.Interceptor {
  public readonly cache: ResponseCache;

  constructor(cache: ResponseCache) {
    this.cache = cache;
  }

  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    const url = context.request.url.href;
    const responseFromCache = this.cache.getResponse(url);
    if (responseFromCache) {
      return Promise.resolve(responseFromCache);
    }
    AppStorage.setOrCreate('ReplacedInfo',
      `[ResponseCachingInterceptor]: Request URL is "${context.request.url.href}"`);
    const promise = next.handle(context);
    promise.then((resp) => {
      resp.statusCode;
      this.cache.setResponse(url, resp);
    });
    return promise;
  }
}

// Define the ResponseHeaderRemoveInterceptor interceptor
export class ResponseHeaderRemoveInterceptor implements rcp.Interceptor {
  // Custom Response processing Logic
  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    const response = await next.handle(context);
    const toReturn: rcp.Response = {
      request: response.request,
      statusCode: response.statusCode,
      httpVersion: response.httpVersion,
      headers: {
        'content-range': response.headers['content-range']
      },
      effectiveUrl: response.effectiveUrl,
      timeInfo: response.timeInfo,
      toJSON: () => null
    };
    Logger.info('[ResponseHeaderRemoveInterceptor]: Response was modified');
    return toReturn;
  }
}
// [End response_header_remove_interceptor]