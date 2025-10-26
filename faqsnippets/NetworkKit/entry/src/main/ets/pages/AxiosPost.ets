/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/


/*
* FAQ:三方件@ohos/axios中发起post请求，如何以queryParams形式传递参数
*/
import { url } from '@kit.ArkTS'
import axios,{ AxiosError,AxiosResponse } from '@ohos/axios'
// [Start AxiosPost]
let params: url.URLParams = new url.URLParams()
params.append('fod' ,'1')
params.append('bard','2')
axios.post('https://developer.mozilla.org/?' + params.toString()).then((res: AxiosResponse) => {
  let message = "request result: " + JSON.stringify(res.data);
}).catch((err:AxiosError) => {
  let message = "request error: " + err.message;
})
// [End AxiosPost]


// [Start AxiosPost2]
axios({ url: 'https://developer.mozilla.org/?', method: 'post', params: { fod: '1', bard: '2', } }).then((res: AxiosResponse) => {
  let message = "request result: " + JSON.stringify(res.data);
}).catch((err:AxiosError) => {
  let message = "request error: " + err.message;
})
// [End AxiosPost2]
