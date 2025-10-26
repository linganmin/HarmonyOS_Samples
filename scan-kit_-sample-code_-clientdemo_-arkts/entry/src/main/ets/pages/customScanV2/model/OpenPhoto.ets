import { AsyncCallback, BusinessError } from '@kit.BasicServicesKit';
import { detectBarcode, scanBarcode, scanCore } from '@kit.ScanKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { ScanServiceV2, ScanStatus } from './ScanService';

enum StatusCode {
  INTERNAL_SERVER_ERROR = 500,
  NOT_FOUND = 404,
  SUCCEED = 0
}

const NOT_FOUND_PHOTO = 'No photo selected';
const NOT_FOUND_BARCODE = 'No barcode was recognized.';
const SELECT_CALL_FAILED = 'The select interface of PhotoViewPicker call failed.';
const DECODE_CALL_FAILED = 'The decode interface of detectBarcode call failed.';
const DECODE_SUCCESS = 'Photo decoding successful.';
const scanService: ScanServiceV2 = ScanServiceV2.getInstance();
const defaultScanOptions: scanBarcode.ScanOptions = {
  scanTypes: [scanCore.ScanType.ALL],
  enableMultiMode: false,
  enableAlbum: true
};

class GalleryDecodeError implements BusinessError {
  code: number;
  name: string;
  message: string;

  constructor(code: number, message: string) {
    this.name = 'galleryDecodeResult';
    this.code = code;
    this.message = message;
  }
}

async function decodeAlbum(uri: string, callback: AsyncCallback<Array<scanBarcode.ScanResult>>): Promise<void> {
  // Image recognition parameter. By default, a single barcode is recognized.
  const inputImage: detectBarcode.InputImage = { uri };
  try {
    scanService.isAlbumLoading = true;
    const scanResults: Array<scanBarcode.ScanResult> = await detectBarcode.decode(inputImage, defaultScanOptions);
    scanService.isAlbumLoading = false;
    if (scanResults && scanResults.length > 0) {
      callback((new GalleryDecodeError(StatusCode.SUCCEED, DECODE_SUCCESS)), [scanResults[0]]);
    } else {
      callback((new GalleryDecodeError(StatusCode.NOT_FOUND, NOT_FOUND_BARCODE)), []);
    }
  } catch (error) {
    scanService.isAlbumLoading = false;
    callback((new GalleryDecodeError(error.code || StatusCode.INTERNAL_SERVER_ERROR,
      error.message || DECODE_CALL_FAILED)), []);
  }
}

export async function openAlbum(callback: AsyncCallback<Array<scanBarcode.ScanResult>>): Promise<void> {
  const photoSelectOptions: photoAccessHelper.PhotoSelectOptions = {
    MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
    maxSelectNumber: 1,
    isPhotoTakingSupported: false,
    isEditSupported: false
  };
  const photoPicker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker();
  try {
    const photoSelectResult: photoAccessHelper.PhotoSelectResult = await photoPicker.select(photoSelectOptions);
    if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
      decodeAlbum(photoSelectResult.photoUris[0], callback);
    } else {
      scanService.updateScanStatus(ScanStatus.NO_PHOTO_SELECT);
      callback(new GalleryDecodeError(StatusCode.NOT_FOUND, NOT_FOUND_PHOTO), []);
    }
  } catch (error) {
    scanService.updateScanStatus(ScanStatus.NO_PHOTO_SELECT);
    callback(new GalleryDecodeError(error.code || StatusCode.INTERNAL_SERVER_ERROR, SELECT_CALL_FAILED), []);
  }
}