/**
 * 最佳实践：合理使用网络资源
 * 场景一：HTTP数据请求
 */

// [Start http_resources]
import { UIAbility } from '@kit.AbilityKit';
import { http } from '@kit.NetworkKit';

export default class EntryAbility extends UIAbility {
  // ...
  onForeground(): void {
    // Create an HTTP request based on the service requirements at the foreground
    let httpRequest: http.HttpRequest = http.createHttp();
    // ...
  }

  onBackground(): void {
    // [StartExclude http_resources]
    let httpRequest = http.createHttp();
    // [EndExclude http_resources]
    // Go back to the background and release the http request
    httpRequest.destroy();
  }
}
// [End http_resources]