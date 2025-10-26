import {
  DocType,
  DocumentScanner,
  DocumentScannerConfig,
  SaveOption,
  FilterId,
  ShootingMode
} from "@kit.VisionKit"
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG: string = 'DocDemoPage'

/**
 * Document scan identification page, used to load uiExtensionAbility
 *
 * @since 2024-02-27
 */
@Entry
@Component
struct DocDemoPage {
  @State docImageUris: string[] = []
  private docScanConfig = new DocumentScannerConfig()

  aboutToAppear() {
    this.docScanConfig.supportType = [DocType.DOC, DocType.SHEET]
    this.docScanConfig.isGallerySupported = true
    this.docScanConfig.editTabs = []
    this.docScanConfig.maxShotCount = 3
    this.docScanConfig.defaultFilterId = FilterId.ORIGINAL
    this.docScanConfig.defaultShootingMode = ShootingMode.MANUAL
    this.docScanConfig.isShareable = true
    this.docScanConfig.originalUris = []
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DocumentScanner({
        scannerConfig: this.docScanConfig,
        onResult: (code: number, saveType: SaveOption, uris: string[]) => {
          hilog.info(0x0001, TAG, `result code: ${code}, save: ${saveType}`)
          uris.forEach(uriString => {
            hilog.info(0x0001, TAG, `uri: ${uriString}`)
          })
          this.docImageUris = uris
        }
      })
        .size({ width: '100%', height: '100%' })
    }
    .width('100%')
    .height('100%')
  }
}