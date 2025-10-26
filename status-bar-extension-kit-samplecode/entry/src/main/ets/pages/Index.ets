/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { statusBarManager } from '@kit.StatusBarExtensionKit'
import { image } from '@kit.ImageKit';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct Index {
  @State message: string = 'Status Bar Extension Kit Sample';
  @State res: string = '';
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  public async getPixelMap(name: string): Promise<image.PixelMap> {
    const resourceMgr = this.context.resourceManager;
    const fileData = resourceMgr.getRawFileContentSync(name);

    const buffer = fileData.buffer;

    const imageSource = image.createImageSource(buffer);
    let pixMap = await imageSource.createPixelMap();
    return pixMap;
  }

  public async createStatusBarItem(): Promise<statusBarManager.StatusBarItem> {
    // Method of obtaining the pixelMap. You can use other methods to obtain the pixelMap.
    let testWhite = await this.getPixelMap("testWhite.svg");
    let testBlack = await this.getPixelMap("testBlack.svg");
    let icon: statusBarManager.StatusBarIcon = {
      white: testWhite,
      black: testBlack
    }

    // Build information about menu items displayed after users right-click an app icon in the status bar.
    let subMenus: Array<statusBarManager.StatusBarSubMenuItem> = [];
    let subMenuItemAction: statusBarManager.StatusBarMenuAction = {
      abilityName: "EntryAbility"
    }
    let subMenu: statusBarManager.StatusBarSubMenuItem = {
      subTitle: "Submenu item",
      // menuAction and subMenu cannot be left empty at the same time for a level-1 menu.
      menuAction: subMenuItemAction
    }
    subMenus.push(subMenu);

    let statusBarMenuItems: Array<statusBarManager.StatusBarMenuItem> = [];
    let menuItem: statusBarManager.StatusBarMenuItem = {
      title: "Level-1 menu item",
      // menuAction and subMenu cannot be left empty at the same time for a level-1 menu.
      subMenu: subMenus
    };
    statusBarMenuItems.push(menuItem);

    let statusBarGroupMenus: Array<statusBarManager.StatusBarGroupMenu> = [];
    statusBarGroupMenus.push(statusBarMenuItems);

    // Build information about the pop-up window displayed when users click an app icon in the status bar.
    let operation: statusBarManager.QuickOperation = {
      abilityName: "MyStatusBarViewAbility",
      title: "Test Demo",
      height: 300,
      // Can be left empty.
      moduleName: 'entry'
    };

    // Build information about the icon added to the status bar.
    let statusBarItem: statusBarManager.StatusBarItem = {
      icons: icon,
      quickOperation: operation,
      statusBarGroupMenu: statusBarGroupMenus
    };
    return statusBarItem;
  }

  build() {
    Row() {
      Column({ space: 30 }) {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
        Text(this.res)
          .fontSize(20)
          .fontColor(Color.Red)
        Button("Add to status bar")
          .onClick(async () => {
            try {
              let item = await this.createStatusBarItem();
              statusBarManager.addToStatusBar(this.context, item);
              this.res = 'Added to the status bar successfully';
            } catch (error) {
              console.error(`addToStatusBar failed, Cause: ${error.message}, error code: ${error.code}`);
              this.res = 'Failed to add to the status bar';
            }
          })

        Button("Remove from status bar")
          .onClick(() => {
            try {
              statusBarManager.removeFromStatusBar(this.context);
              this.res = 'Removed from the status bar successfully';
            } catch (error) {
              console.error(`removeFromStatusBar failed, Cause: ${error.message}, error code: ${error.code}`);
              this.res = 'Failed to remove from the status bar';
            }
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}