/**
 * 最佳实践：合理使用网络资源
 * 场景三：WebSocket数据请求
 */

// [Start web_socket_resources]
import { UIAbility } from '@kit.AbilityKit';
import { webSocket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';


export default class EntryAbility extends UIAbility {
  // Create a websocket based on service requirements
  ws: webSocket.WebSocket = webSocket.createWebSocket();


  onForeground(): void {
    // Send data through websocket in the foreground
    this.ws.on('open', (err: BusinessError, value: Object) => {
      console.log("onopen,status:" + JSON.stringify(value));
      // When an on ('open') event is received, you can communicate with the server through the send () method
      this.ws.send("Hello,server!", (err: BusinessError, value: boolean) => {
        if (!err) {
          console.log("Messagesentsuccessfully");
        } else {
          console.log("Failedtosendthemessage.Err:" + JSON.stringify(err));
        }
      });
    });
  }


  onBackground(): void {
    // Backstage closes websocket
    this.ws.close((err: BusinessError) => {});
  }
}
// [End web_socket_resources]