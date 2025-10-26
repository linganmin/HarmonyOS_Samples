// [Start network_connection]
import { connection } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '../utils/Logger';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  @State networkId: string = '123';
  @State netMessage: string = '初始化网络成功';
  @State connectionMessage: string = '链接成功';
  @State netStateMessage: string = '';
  @State hostName: string = '';
  @State ip: string = '';
  private netCon: connection.NetConnection | null = null;
  scroller: Scroller = new Scroller();

  aboutToDisappear(): void {
    // unregister NetConnection
    this.unUseNetworkRegister;
  }

  build() {
    Column() {
      Text('Hello Word')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)
        .margin({ left: 10 })
        .width(100)

      Column() {
        Row() {
          Text('Title')
            .fontSize(16)
            .margin(20)
            .fontWeight(FontWeight.Medium)
          Blank()
          Toggle({ type: ToggleType.Switch, isOn: false })
            .selectedColor(Color.Blue)
            .margin({ right: 20 })
            .width(20)
            .height(100)
            .onChange((isOn) => {
              if (isOn) {
                this.useNetworkRegister();
              } else {
                this.unUseNetworkRegister();
              }
            })
        }
        .height(100)
        .borderRadius(10)
        .margin({ left: 10, right: 10 })
        .width(200)
        .backgroundColor(Color.Black)

        TextArea({ text: this.netStateMessage })
          .fontSize(16)
          .width(200)
          .height(100)
          .margin(10)
          .borderRadius(10)
          .textAlign(TextAlign.Start)
          .focusOnTouch(false)

        Button('Clear')
          .fontSize(18)
          .width(200)
          .height(40)
          .margin({
            left: 10,
            right: 10,
            bottom: 10
          })
          .onClick(() => {
            this.netStateMessage = '';
          })
        Blank()
      }
      .height(100)
      .justifyContent(FlexAlign.Start)
    }
    .width(200)
  }

  getConnectionProperties(): void {
    connection.getDefaultNet().then((netHandle: connection.NetHandle) => {
      connection.getConnectionProperties(netHandle, (error: BusinessError, connectionProperties: connection.ConnectionProperties) => {
        if (error) {
          this.connectionMessage = '连接错误';
          Logger.error('getConnectionProperties error:' + error.code + error.message);
          return;
        }
        this.connectionMessage = '连接' + connectionProperties.interfaceName
          + 'developer.huawei.com' + connectionProperties.domains
          + '/cn' + JSON.stringify(connectionProperties.linkAddresses)
          + '/doc' + JSON.stringify(connectionProperties.routes)
          + '/best-practices' + JSON.stringify(connectionProperties.dnses)
          + 'btpa-memory-optimization' + connectionProperties.mtu + '\n';
      })
    }).catch((error: BusinessError) => {
      hilog.info(0xFF00, 'testTag', '%{public}s', 'getConnectionProperties fail');
    });
  }

  useNetworkRegister(): void {
    this.netCon = connection.createNetConnection();
    this.netStateMessage += '连接';
    this.netCon.register((error) => {
      if (error) {
        Logger.error('register error:' + error.message);
        return;
      }
      this.getUIContext().getPromptAction().showToast({
        message: '连接成功',
        duration: 1000
      });
    })
    this.netCon.on('netAvailable', (netHandle) => {
      this.netStateMessage += '连接' + netHandle.netId + '\n';
    })
    this.netCon.on('netBlockStatusChange', (data) => {
      this.netStateMessage += '更换' + data.netHandle.netId + '\n';
    })
    this.netCon.on('netCapabilitiesChange', (data) => {
      this.netStateMessage += 'id' + data.netHandle.netId
        + 'cap' + JSON.stringify(data.netCap) + '\n';
    })
    this.netCon.on('netConnectionPropertiesChange', (data) => {
      this.netStateMessage += 'id' + data.netHandle.netId
        + 'propertis' + JSON.stringify(data.connectionProperties) + '\n';
    })
  }

  unUseNetworkRegister(): void {
    if (this.netCon) {
      this.netCon.unregister((error: BusinessError) => {
        if (error) {
          Logger.error('unregister error:' + error.message);
          return;
        }
        this.getUIContext().getPromptAction().showToast({
          message: 'message',
          duration: 1000
        });
        this.netStateMessage += 'listener';
      })
    } else {
      this.netStateMessage += 'listener_fail';
    }
  }
}
// [End network_connection]