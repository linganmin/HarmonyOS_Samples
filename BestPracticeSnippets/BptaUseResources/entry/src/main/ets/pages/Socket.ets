/**
 * 最佳实践：合理使用网络资源
 * 场景二：socket数据请求
 */

// [Start socket_resources]
import { UIAbility } from '@kit.AbilityKit';
import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';

export default class EntryAbility extends UIAbility {
  // ...
  tcp: socket.TCPSocket = socket.constructTCPSocketInstance();

  onForeground(): void {
    /**
     * In the foreground, create a socket connection and send service data as required, for example:
     * this.tcp.bind(ipAddress, (err: BusinessError) => {})
     * this.tcp.connect(tcpConnect, (err: BusinessError) => {})
     * this.tcp.send(tcpSendOptions, (err: BusinessError) => {})
     */
  }

  onBackground(): void {
    // Go back to the background and close the socket connection
    this.tcp.close((err: BusinessError) => {})
  }
}
// [End socket_resources]