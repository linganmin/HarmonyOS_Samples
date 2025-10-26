/**
 * 最佳实践：JSCrash问题案例分析
 */

import wifiManager from '@ohos.wifiManager';
import { Log as log } from './utils'
class BaseComponent {
  onStart(): void {

  }
}

class Index extends BaseComponent{
  isConnected: boolean = false;
  handleUpdateState() {}
  isWifiActive: boolean = false;

  // [Start JSCrashCaseAnalyse4]
  onStart(): void {
    super.onStart();
    log.showInfo('onStart');

    wifiManager.on('wifiConnectionChange', (data) => {
      this.isConnected = data === 1 ? true : false;
      this.handleUpdateState();
    });
    wifiManager.on('wifiStateChange', (data) => {
      this.isWifiActive = data === 1 ? true : false;
      this.handleUpdateState();
    });

  }
  // [End JSCrashCaseAnalyse4]
}
