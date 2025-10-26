import { window } from '@kit.ArkUI';

@Component
struct ScreenRotationA {
  // [Start orientation]
  @StorageLink('mainWindow') mainWindow?: window.Window = undefined;
  public lastOrientation?: window.Orientation;

  aboutToAppear(): void {
    if (this.mainWindow === undefined) {
      return;
    }
    this.lastOrientation = this.mainWindow!.getPreferredOrientation();
    this.mainWindow!.setPreferredOrientation(window.Orientation.LANDSCAPE);
  }

  aboutToDisappear(): void {
    this.mainWindow!.setPreferredOrientation(this.lastOrientation)
  }
  // [End orientation]

  build() {
    Text('你好')
  }
}
