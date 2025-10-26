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

import rag from '@hms.data.rag'
import { hilog } from '@kit.PerformanceAnalysisKit';
import { util, JSON } from '@kit.ArkTS';

import LLMHttpUtils from '../common/utils/LLMHttpUtils'

// [Start MyChatLlm]
export default class MyChatLlm extends rag.ChatLLM {
  temp: string = '';

  cancel(): void {
    LLMHttpUtils.cancel();
  }

  async streamChat(query: string, callback: Callback<rag.LLMStreamAnswer>): Promise<rag.LLMRequestInfo> {
    let ret = rag.LLMRequestStatus.LLM_SUCCESS;
    try {
      LLMHttpUtils.on(
        // data received callback function
        (data) => {
          try {
            if (LLMHttpUtils.isFinished) {
              return;
            }
            let decoder = util.TextDecoder.create(`"utf-8"`);
            let str = decoder.decodeToString(new Uint8Array(data));
            let resultStr: string = str.split('\n')[0];
            if(resultStr.startsWith('{"error_code"')){
              hilog.error(0, 'MyChatLlm', 'str =' + resultStr);
              let answer: rag.LLMStreamAnswer = {
                isFinished: true,
                chunk: `LLM catch other exception. msg:${resultStr}`,
                err:{
                  code: 1021011000,
                  name: `LLM catch other exception`,
                  message: `LLM catch other exception. msg:${resultStr}`
                }
              }
              try{
                let obj = JSON.parse(resultStr) as object;
                if(obj && obj['error_msg'] && obj['error_code'] && obj['error_msg'] === 'Invalid authorization header.'){
                  answer.chunk = `LLM catch other exception. msg:${obj['error_msg']}`;
                  answer.err!.message = 'Invalid ChatLLM authorization API key';
                }
              }
              catch(err){
                hilog.error(0, 'MyChatLlm', 'Parse json failed. String: ' + resultStr);
              }
              hilog.error(0, 'MyChatLlm', 'LLM catch other exception');
              LLMHttpUtils.isFinished = true;
              callback(answer);
              return;
            }
            let obj = JSON.parse(resultStr.slice(5))
            let chunk = ''
            if ((obj as object)?.["choices"].length === 0) {
              return;
            }
            if ((obj as object)?.["choices"][0]["delta"]["reasoning_content"]) {
              chunk = (obj as object)?.["choices"][0]["delta"]["reasoning_content"];
            } else {
              chunk = (obj as object)?.["choices"][0]["delta"]["content"];
            }
            this.temp += chunk;
            let isFinished: boolean = (str.length < 20);
            let answer: rag.LLMStreamAnswer = {
              isFinished: isFinished,
              chunk: chunk
            }
            LLMHttpUtils.isFinished = isFinished;
            callback(answer);
          } catch (err) {
            hilog.error(0, 'MyChatLlm', `BusinessError, error code: ${err.code}, error message: ${err.message}`);
          }
        },
        // data end callback function
        () => {
          if (LLMHttpUtils.isFinished) {
            return;
          }
          let answer: rag.LLMStreamAnswer = {
            isFinished: true,
            chunk: ''
          }
          LLMHttpUtils.isFinished = true;
          callback(answer);
          LLMHttpUtils.end();
          hilog.warn(0, 'MyChatLlm', 'Recv dataEnd callback.');
        }
      );
      LLMHttpUtils.requestInStream(query);
    } catch (err) {
      hilog.error(0, 'MyChatLlm', `Request HuaweiYun failed, error code: ${err.code}, error message: ${err.message}`);
      if (err.code ===2300028) {
        ret = rag.LLMRequestStatus.LLM_TIMEOUT;
      } else if (err.code === 2300007) {
        ret = rag.LLMRequestStatus.LLM_LOAD_FAILED;
      } else if (err.code === 9999999) {
        ret = rag.LLMRequestStatus.LLM_BUSY;
      } else {
        ret = rag.LLMRequestStatus.LLM_REQUEST_ERROR;
      }
    }
    return {
      chatId: 0,
      status: ret,
    };
  }
}
// [End MyChatLlm]