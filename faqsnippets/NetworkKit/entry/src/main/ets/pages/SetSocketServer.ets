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
* FAQ:使用SocketServer时，如何解决较高概率接收不到 client.on("message", (value: SocketInfo) 中的回调问题
*/

// [Start SetSocketServer]
import { socket } from '@kit.NetworkKit';

let tcpServer: socket.TCPSocketServer = socket.constructTCPSocketServerInstance();
// 定义存放客户端连接的数组
let tcpConnectArray: socket.TCPSocketConnection[] = [];

class SocketInfo {
  message: ArrayBuffer = new ArrayBuffer(1);
  remoteInfo: socket.SocketRemoteInfo = {} as socket.SocketRemoteInfo;
}

@Entry
@Component
struct CreateSocket {
  build() {
    Column() {
      Button('创建socket').onClick(async () => {
        tcpServer.on('connect', (client: socket.TCPSocketConnection) => {
          // 保存客户端的socket
          tcpConnectArray.push(client);
          // Subscribe to events of the TCPSocketConnection object.
          client.on('close', () => {
            console.log("on close success");
          });
          client.on('message', (value: SocketInfo) => {
            // 此处高概率收不到message
            let buffer = value.message;
            let dataView = new DataView(buffer);
            let str = '';
            for (let i = 0; i < dataView.byteLength; ++i) {
              str += String.fromCharCode(dataView.getUint8(i));
            }
            console.log('received message--:' + str);
          });
        })
        console.log('create socket Succeeded ');
      })

    }
    .height('100%')
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}
// [End SetSocketServer]

