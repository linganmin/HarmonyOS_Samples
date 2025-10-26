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
* FAQ:http网络连接中的通用知识
*/
import { http } from '@kit.NetworkKit';


let httpRequest = http.createHttp();
httpRequest.request(
  "EXAMPLE_URL",
  {
    header: {
      'Accept': 'application/json',
      // [Start ContentType]
      'Content-Type': "application/json; charset=UTF-8"
      // [End ContentType]
    }
  },
  () => {
  });
