import {userAuth} from '@kit.UserAuthenticationKit';
import {promptAction} from '@kit.ArkUI';
import IfaaModel from '../model/IfaaModel'


const ifaaAuthType = "fp";

function show(message: string)
{
  promptAction.openToast({
    message: message,
    duration: 2000
  });
}

@Entry
@Component
struct Index {
  build() {
    Row() {
      Column() {
        Button("开启")
          .margin(20)
          .width(200)
          .onClick(async ()=>{
            try{
              await IfaaModel.initReqData();
              await IfaaModel.register(ifaaAuthType);
              show("IIFAA register success");
            } catch (err) {
              show(err.message);
            }
          })

        Button("认证")
          .margin(20)
          .width(200)
          .onClick(async ()=> {
            let ifaaChallenge:Uint8Array = IfaaModel.getChallenge();
            // 拉起生物特征认证（此步骤为IIFAA流程所需步骤，非IFAA能力）
            let authParam : userAuth.AuthParam = {
              challenge: ifaaChallenge,
              authType: [userAuth.UserAuthType.FINGERPRINT],
              authTrustLevel: userAuth.AuthTrustLevel.ATL4
            };
            let userAuthInstance = userAuth.getUserAuthInstance(authParam,  {title: '请认证'});
            userAuthInstance.on('result', {
              async onResult (result) {
                let authToken = result.token;
                try {
                  await IfaaModel.initReqData();
                  // 生物特征认证成功后，调用IFAA认证
                  await IfaaModel.auth(ifaaAuthType, authToken);
                  show("IIFAA auth success");
                } catch (err) {
                  show("IIFAA auth failed");
                }
              }
            });
            userAuthInstance.start();
          })

        Button("关闭")
          .margin(20)
          .width(200)
          .onClick(async ()=>{
            try{
              await IfaaModel.initReqData();
              await IfaaModel.deregister(ifaaAuthType);
              show("deregister success");
            } catch (err) {
              show("IIFAA deregister failed");
            }
          })
      }.width('100%')
    }.height('100%')
  }
}
