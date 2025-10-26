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


import { hilog } from '@kit.PerformanceAnalysisKit';
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';

class LLMHttpUtils {
  // [Start initLLMOption]
  httpRequest: http.HttpRequest | null = null;
  url: string = "https://api.modelarts-maas.com/v1/chat/completions";
  isFinished: boolean = false;

  //initialize the llm option
  initOption(question: string) {
    let option: http.HttpRequestOptions = {
      // request
      method: http.RequestMethod.POST,
      header: {
        "Content-Type": "application/json",
        // API-KEY from Model
        "Authorization": "Bearer xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      },
      extraData: {
        "stream": true,
        "temperature": 0.1,
        "max_tokens": 10000,
        "frequency_penalty": 1,
        "model": "qwen3-235b-a22b",
        "top_p": 0.1,
        "presence_penalty": -1,
        "messages": JSON.parse(question)
      }
    };
    return option;
  }
  // [End initLLMOption]

  // [Start requestInStream]
  async requestInStream(question: string) {
    if (this.httpRequest === null) {
      this.httpRequest = http.createHttp();
    }
    this.httpRequest.requestInStream(this.url, this.initOption(question)).catch((err: BusinessError) => {
      hilog.error(0x0000, 'LLMHttpUtils', `requestInStream failed, error code=${err.code}, message=${err.message}`);
    });
    this.isFinished = false;
  }
  // [End requestInStream]

  // [Start requestLLMOn]
  on(callback: Callback<ArrayBuffer>, endCallback: Callback<void>) {
    if (this.httpRequest === null) {
      this.httpRequest = http.createHttp();
    }
    this.httpRequest.on("dataReceive", callback);
    this.httpRequest.on('dataEnd', endCallback);
  }
  // [End requestLLMOn]

  end() {
    this.httpRequest?.off("dataReceive");
    this.httpRequest?.off("dataEnd");
    this.httpRequest?.destroy();
    this.httpRequest = null;
  }

  cancel() {
    this.httpRequest?.off("dataReceive");
    this.httpRequest?.off("dataEnd");
    this.httpRequest?.destroy();
    this.httpRequest = null;
  }
}

export default new LLMHttpUtils;