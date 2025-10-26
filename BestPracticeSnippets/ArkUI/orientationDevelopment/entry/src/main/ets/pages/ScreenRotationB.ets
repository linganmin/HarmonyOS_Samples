import { common } from '@kit.AbilityKit';

@Component
struct ScreenRotationB {
  // [Start window]
  private windowClass = (this.getUIContext().getHostContext() as common.UIAbilityContext).windowStage.getMainWindowSync()

  aboutToAppear(): void {
    this.windowClass.enableLandscapeMultiWindow();
  }

  aboutToDisappear(): void {
    this.windowClass.disableLandscapeMultiWindow();
  }
  // [End window]

  build() {
    Text('你好')
  }
}
