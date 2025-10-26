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
* FAQ:http请求如何以表单形式进行传输
*/

// [Start SetForm]
import { http } from '@kit.NetworkKit';

let options: http.HttpRequestOptions = {
  method: http.RequestMethod.GET,
  extraData: 'send message',
  header: { 'Content-Type': 'application/x-www-form-urlencoded' },
  readTimeout: 50000,
  connectTimeout: 50000
}
// [End SetForm]

// [Start SetForm2]
let httpRequest = http.createHttp();
let data = "user=Query&password=Admin123";
httpRequest.request(
  'https:xxx',
  {
    method: http.RequestMethod.POST,
    // Optional, default is http.RequestMethod.GET//Developers can add header fields according to their own business needs
    header: { 'Content-Type': 'application/x-www-form-urlencoded' }, // This field is used to pass content when using POST requests
    extraData: data,
    connectTimeout: 60000, // Optional, default is 60000ms
    readTimeout: 60000, // Optional, default is 60000ms
  }, (err, data) => {
  if (!err) {
    // Data.read is the HTTP response content, which can be parsed according to business needs
    console.info('Result:' + JSON.stringify(data.result));
    console.info('code:' +
    JSON.stringify(data.responseCode)); // Data.reader is an HTTP response header that can be parsed according to business needs
    console.info('header:' + JSON.stringify(data.header));
    console.info('cookies:' +
    JSON.stringify(data.cookies)); // Starting from API8
  } else {
    console.info('error:' + JSON.stringify(err)); // Unsubscribe from HTTP response header events
    httpRequest.off('headersReceive'); // When the request is exhausted, call the destroy method to actively destroy it.
    httpRequest.destroy();
  }
})
// [End SetForm2]
