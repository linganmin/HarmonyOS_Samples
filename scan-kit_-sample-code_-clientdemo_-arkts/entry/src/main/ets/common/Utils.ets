import { scanCore, type scanBarcode, generateBarcode } from '@kit.ScanKit';
import { type BusinessError } from '@kit.BasicServicesKit';
import Logger from './Logger';
import { UIContextSelf } from '../pages/customScan/model/UIContextSelf';

const TAG = 'Utils';

const COLOR_MAP: Record<string, number> = {
  'Black': 0x000000,
  'Blue': 0x0000ff,
  'Brown': 0xa52a2a,
  'Gray': 0x808080,
  'Green': 0x008000,
  'Orange': 0xffa500,
  'Red': 0xff0000,
  'White': 0xffffff,
  'Yellow': 0xffff00,
  'Default': 0x1e1e1e
};

/**
 *
 FORMAT_UNKNOWN = 0,
 AZTEC_CODE = 1,
 CODABAR_CODE = 2,
 CODE39_CODE = 3,
 CODE93_CODE = 4,
 CODE128_CODE = 5,
 DATAMATRIX_CODE = 6,
 EAN8_CODE = 7,
 EAN13_CODE = 8,
 ITF14_CODE = 9,
 PDF417_CODE = 10,
 QR_CODE = 11,
 UPC_A_CODE = 12,
 UPC_E_CODE = 13,
 MULTIFUNCTIONAL_CODE = 14,
 ONE_D_CODE = 100,
 TWO_D_CODE = 101,
 */
const SCAN_TYPE: Record<number, string> = {
  0: 'FORMAT_UNKNOWN',
  1: 'AZTEC_CODE',
  2: 'CODABAR_CODE',
  3: 'CODE39_CODE',
  4: 'CODE93_CODE',
  5: 'CODE128_CODE',
  6: 'DATAMATRIX_CODE',
  7: 'EAN8_CODE',
  8: 'EAN13_CODE',
  9: 'ITF14_CODE',
  10: 'PDF417_CODE',
  11: 'QR_CODE',
  12: 'UPC_A_CODE',
  13: 'UPC_E_CODE',
  14: 'MULTIFUNCTIONAL_CODE',
  100: 'ONE_D_CODE',
  101: 'TWO_D_CODE'
};


export function checkResults(result: scanBarcode.ScanResult[]): boolean {
  if (!result) {
    return false;
  }
  return true;
}

export function getColorType(type: string | undefined): number {
  return type ? COLOR_MAP[type] : COLOR_MAP['Default'];
}

export function showError(businessError: BusinessError): void {
  try {
    UIContextSelf.uiContext.getPromptAction().showToast({
      message: `Error Code: ${businessError.code} ${businessError.message}`,
      duration: 2000
    });
  } catch (error) {
    Logger.error(TAG, `Catch: showError showToast. Code: ${error?.code}.`);
  }
}

export function showMessage(message: Resource): void {
  try {
    UIContextSelf.uiContext.getPromptAction().showToast({
      message: message,
      duration: 2000
    });
  } catch (error) {
    Logger.error(TAG, `Catch: showMessage showToast. Code: ${error?.code}.`);
  }
}

export function getErrorCorrectionLevel(type: string | undefined): generateBarcode.ErrorCorrectionLevel {
  if (type) {
    return generateBarcode.ErrorCorrectionLevel[type] || generateBarcode.ErrorCorrectionLevel.LEVEL_H;
  } else {
    return generateBarcode.ErrorCorrectionLevel.LEVEL_H;
  }
}

export function getScanTypeVal(type: string | undefined): scanCore.ScanType {
  if (type) {
    return scanCore.ScanType[type] || scanCore.ScanType.QR_CODE;
  } else {
    return scanCore.ScanType.QR_CODE;
  }
}

export function getScanTypeKey(type: number): string {
  return SCAN_TYPE[type] || ''
}

export function funcDelayer(func: Function, time: number): void {
  let timerId = setTimeout(() => {
    try {
      func();
    } catch (error) {
      Logger.error(TAG, `Failed to execute func in timer. Code: ${error?.code}`);
    }
    clearTimeout(timerId);
  }, time);
}