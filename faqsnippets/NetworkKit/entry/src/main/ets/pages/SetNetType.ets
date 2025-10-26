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
* FAQ:如何判断使用的是移动蜂窝网络
*/

// [Start SetNetType]
import { connection } from '@kit.NetworkKit';

// Check if the network is connected
connection.hasDefaultNet((error, data) => {
  console.log('data: ' + data);
})
// Obtain network capability information
connection.getDefaultNet().then((netHandle) => {
  connection.getNetCapabilities(netHandle, (error, data) => {
    console.log(JSON.stringify(error));
    console.log(JSON.stringify(data));
  })
})
// [End SetNetType]

