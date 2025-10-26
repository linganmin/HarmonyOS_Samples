// FAQ:如何在Native侧获取APP版本信息
// [Start bundle_info]
import { bundleManager } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo)=>{
              let versionName = bundleInfo.versionName;//Application version name
              let versionNo = bundleInfo.versionCode;//Application version number
            }).catch((error : BusinessError)=>{
              console.error("get bundleInfo failed,error is "+error)})
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End bundle_info]