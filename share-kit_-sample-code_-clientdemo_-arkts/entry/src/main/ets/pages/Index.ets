import { common } from '@kit.AbilityKit';
import { SymbolGlyphModifier } from '@kit.ArkUI';
import { fileIo as fs } from '@kit.CoreFileKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import AccessModel from '../components/AccessModel';
import BasicUse from '../components/BasicUse';
import GesturesShare from '../components/GesturesShare';
import KnockShare from '../components/KnockShare';
import FunctionExample from '../components/subpages/FunctionExample';
import KnockShareApi from '../components/subpages/KnockShareApi';
import KnockShareAttr from '../components/subpages/KnockShareAttr';
import KnockShareCard from '../components/subpages/KnockShareCard';
import KnockShareSandbox from '../components/subpages/KnockShareSandbox';
import KnockShareTips from '../components/subpages/KnockShareTips';
import TypicalScenarios from '../components/TypicalScenarios';
import Constants from '../utils/Constants';
import Logger from '../utils/Logger';

let logger = Logger.getLogger('[EntryIndex]');

@Entry
@Component
struct Index {
  localStorage = this.getUIContext().getSharedLocalStorage();
  @State navigationIndex: string = Constants.NAVIGATION_MODEL;
  // 创建一个页面栈对象并传入Navigation
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();
  private windowId: number | undefined = this.localStorage?.get<number>('windowId');

  async aboutToAppear(): Promise<void> {
    const uiContext: UIContext = this.getUIContext();
    const context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
    const filesDir = context.filesDir;
    try {
      [
        [context.resourceManager.getMediaContentSync($r('app.media.exampleImage').id), '/exampleImage.jpg'],
        [context.resourceManager.getMediaContentSync($r('app.media.exampleGif').id), '/exampleGif.gif'],
        [context.resourceManager.getMediaContentSync($r('app.media.exampleVideo').id), '/exampleVideo.mp4'],
        [context.resourceManager.getMediaContentSync($r('app.media.startIcon').id), '/icon.jpg'],
        [context.resourceManager.getMediaContentSync($r('app.media.exampleKnock1').id), '/exampleKnock1.jpg'],
        [context.resourceManager.getMediaContentSync($r('app.media.exampleKnock2').id), '/exampleKnock2.png'],
        [context.resourceManager.getMediaContentSync($r('app.media.exampleKnock3').id), '/exampleKnock3.jpg'],
        [context.resourceManager.getMediaContentSync($r('app.media.exampleDocx').id), '/exampleDocx.docx'],
        [context.resourceManager.getMediaContentSync($r('app.media.exampleZip').id), '/exampleZip.zip'],
      ].forEach(item => {
        let file = fs.openSync(filesDir + item[1], fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
        let writeLen = fs.writeSync(file.fd, (item[0] as Uint8Array).buffer);
        logger.info("write data to file succeed and size is:" + writeLen);
        fs.closeSync(file);
      });
    } catch (error) {
      logger.error(`getMediaContentSync error. Code: ${error?.code}, message: ${error?.message}`);
    }
  }

  onPageShow(): void {
    logger.info('onPageHide invoked.');
    const uiContext: UIContext = this.getUIContext();
    const context: Context = uiContext.getHostContext() as Context;
    context.eventHub.emit('onFocus');
    console.log(deviceInfo.deviceType.toLowerCase())
  }

  onPageHide(): void {
    logger.info('onPageHide invoked.');
    const uiContext: UIContext = this.getUIContext();
    const context: Context = uiContext.getHostContext() as Context;
    context.eventHub.emit('onBackGround');
  }

  @Builder
  Title() {
    Text($r('app.string.huawei_share_title'))
      .fontSize(24)
      .textAlign(TextAlign.Center)
      .margin({ top: 20, left: 20 })
  }

  @Builder
  PageMapBuilder(name: string) {
    if (name === 'FunctionExample') {
      FunctionExample();
    } else if (name === 'KnockShareApi') {
      KnockShareApi();
    } else if (name === 'KnockShareAttr') {
      KnockShareAttr({ windowId: this.windowId });
    } else if (name === 'KnockShareCard') {
      KnockShareCard();
    } else if (name === 'KnockShareSandbox') {
      KnockShareSandbox({ windowId: this.windowId });
    } else if (name === 'KnockShareTips') {
      KnockShareTips();
    }
  }

  build() {
    Navigation(this.pageStack) {
      if (this.navigationIndex === Constants.NAVIGATION_MODEL) {
        AccessModel();
      }
      if (this.navigationIndex === Constants.NAVIGATION_BASE) {
        BasicUse();
      }
      if (this.navigationIndex === Constants.NAVIGATION_UTD) {
        TypicalScenarios();
      }
      if (this.navigationIndex === Constants.NAVIGATION_KNOCK) {
        KnockShare();
      }
      if (this.navigationIndex === Constants.NAVIGATION_GESTURE) {
        GesturesShare({ windowId: this.windowId });
      }
    }
    .title({
      builder: this.Title(),
      height: TitleHeight.MainOnly
    })
    .mode(NavigationMode.Stack)
    .navDestination(this.PageMapBuilder)
    .toolbarConfiguration([
      {
        value: $r("app.string.navigation_toolbar_model"),
        status: this.navigationIndex === Constants.NAVIGATION_MODEL ? ToolbarItemStatus.ACTIVE :
        ToolbarItemStatus.NORMAL,
        symbolIcon: new SymbolGlyphModifier($r("sys.symbol.house")),
        activeSymbolIcon: new SymbolGlyphModifier($r("sys.symbol.house_fill")),
        action: () => {
          this.navigationIndex = Constants.NAVIGATION_MODEL
        },
      },
      {
        value: $r("app.string.navigation_toolbar_base"),
        status: this.navigationIndex === Constants.NAVIGATION_BASE ? ToolbarItemStatus.ACTIVE :
        ToolbarItemStatus.NORMAL,
        symbolIcon: new SymbolGlyphModifier($r("sys.symbol.square_grid_2x2")),
        activeSymbolIcon: new SymbolGlyphModifier($r("sys.symbol.square_fill_grid_2x2")),
        action: () => {
          this.navigationIndex = Constants.NAVIGATION_BASE
        },
      },
      {
        value: $r("app.string.navigation_toolbar_utd"),
        status: this.navigationIndex === Constants.NAVIGATION_UTD ? ToolbarItemStatus.ACTIVE : ToolbarItemStatus.NORMAL,
        symbolIcon: new SymbolGlyphModifier($r("sys.symbol.rectangle_on_rectangle")),
        activeSymbolIcon: new SymbolGlyphModifier($r("sys.symbol.rectangle_on_rectangle_fill")),
        action: () => {
          this.navigationIndex = Constants.NAVIGATION_UTD
        },
      },
      {
        value: $r("app.string.navigation_toolbar_knock"),
        status: this.navigationIndex === Constants.NAVIGATION_KNOCK ? ToolbarItemStatus.ACTIVE :
        ToolbarItemStatus.NORMAL,
        symbolIcon: new SymbolGlyphModifier($r("sys.symbol.person_2")),
        activeSymbolIcon: new SymbolGlyphModifier($r("sys.symbol.person_2_fill")),
        action: () => {
          this.navigationIndex = Constants.NAVIGATION_KNOCK
        },
      },
      {
        value: $r("app.string.navigation_toolbar_gesture"),
        status: this.navigationIndex === Constants.NAVIGATION_GESTURE ? ToolbarItemStatus.ACTIVE :
        ToolbarItemStatus.NORMAL,
        symbolIcon: new SymbolGlyphModifier($r("sys.symbol.hand_raised_hexagon")),
        activeSymbolIcon: new SymbolGlyphModifier($r("sys.symbol.hand_raised_hexagon_fill")),
        action: () => {
          this.navigationIndex = Constants.NAVIGATION_GESTURE
        },
      },
    ])
  }
}