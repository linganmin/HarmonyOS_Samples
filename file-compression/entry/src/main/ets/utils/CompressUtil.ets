/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


import { BusinessError, zlib } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import {
  ArchiveOutputStream,
  ArchiveStreamFactory,
  Decoder,
  Encoder,
  Exception,
  File,
  gzipFile,
  InputStream,
  IOUtils,
  Long,
  OutputStream,
  TarArchiveEntry,
  TarArchiveInputStream,
  unGzipFile
} from '@ohos/commons-compress';
import { FileConstants } from '../constant/FileConstants';
import { FileUtil } from './FileUtil';
import Logger from './Logger';

export class CompressUtil {
  private uiContext: UIContext = AppStorage.get('UIContext') as UIContext;
  private context: common.UIAbilityContext = this.uiContext.getHostContext() as common.UIAbilityContext;
  private fileUtil: FileUtil = new FileUtil();

  async compressIntoZip(fileName: string): Promise<void> {
    let inFile = this.context.filesDir + '/' + fileName + FileConstants.TXT_FILE_TYPE;
    let outFile = this.context.filesDir + '/' + fileName + FileConstants.COMPRESSED_FILE_SUFFIXES[1];
    let isExist: boolean = await this.fileUtil.isCompressedFileExisted(outFile);
    if (isExist) {
      this.uiContext.getPromptAction().showToast({ message: FileConstants.TOAST_TEXTS[0] });
      return;
    }
    try {
      let options: zlib.Options = {
        level: zlib.CompressLevel.COMPRESS_LEVEL_BEST_COMPRESSION,
        memLevel: zlib.MemLevel.MEM_LEVEL_DEFAULT,
        strategy: zlib.CompressStrategy.COMPRESS_STRATEGY_DEFAULT_STRATEGY
      };
      zlib.compressFile(inFile, outFile, options, (err: BusinessError) => {
        if (err !== null) {
          Logger.error(`Failed to compress file, error message: ${err.message}, error code: ${err.code}`);
          return;
        }
        this.fileUtil.addToFileList(outFile, fileName, FileConstants.COMPRESSED_FILE_SUFFIXES[1]);
      })
    } catch (error) {
      Logger.error(`Failed to compress the file. Error: ${JSON.stringify(error)}.`);
      this.uiContext.getPromptAction().showToast({ message: FileConstants.TOAST_TEXTS[1] });
    }
  }

  async decompressZipFile(fileName: string): Promise<void> {
    let inFile = this.context.filesDir + '/' + fileName + FileConstants.COMPRESSED_FILE_SUFFIXES[1];
    let outDirect = this.context.filesDir + FileConstants.DECOMPRESSED_FILE_DIRECTORY;
    let outFile = outDirect + '/' + fileName + FileConstants.TXT_FILE_TYPE;
    let isExist: boolean = await this.fileUtil.isCompressedFileExisted(outFile);
    if (isExist) {
      this.fileUtil.deleteOriginalFile(outFile);
    }
    let options: zlib.Options = { level: zlib.CompressLevel.COMPRESS_LEVEL_DEFAULT_COMPRESSION };
    try {
      zlib.decompressFile(inFile, outDirect, options, (err: BusinessError) => {
        if (err !== null) {
          Logger.error(`Failed to decompress the file, error code: ${err.code}, error message: ${err.message}`);
          return;
        }
        this.fileUtil.addToFileList(outFile, fileName, FileConstants.TXT_FILE_TYPE);
        // If the package is decompressed for the first time, add it to the file list.
        if (isExist) {
          this.uiContext.getPromptAction().showToast({ message: FileConstants.TOAST_TEXTS[2] });
        }
      })
    } catch (error) {
      Logger.error(`Failed to compress the file. Error: ${JSON.stringify(error)}.`);
    }
  }

  async compressIntoGzip(fileName: string): Promise<void> {
    let inFile = this.context.filesDir + '/' + fileName + FileConstants.TXT_FILE_TYPE;
    let outFile = this.context.filesDir + '/' + fileName + FileConstants.COMPRESSED_FILE_SUFFIXES[0];
    let isExist: boolean = await this.fileUtil.isCompressedFileExisted(outFile);
    if (isExist) {
      this.uiContext.getPromptAction().showToast({ message: FileConstants.TOAST_TEXTS[0] });
      return;
    }
    try {
      gzipFile(inFile, outFile).then((isSuccess: boolean) => {
        if (!isSuccess) {
          Logger.error(`Failed to compress the file.`);
          return;
        }
        this.fileUtil.addToFileList(outFile, fileName, FileConstants.COMPRESSED_FILE_SUFFIXES[0]);
      })
    } catch (error) {
      Logger.error(`Failed to compress the file. Error: ${JSON.stringify(error)}.`);
      this.uiContext.getPromptAction().showToast({ message: FileConstants.TOAST_TEXTS[1] });
    }
  }

  async decompressGzipFile(fileName: string): Promise<void> {
    let inFile = this.context.filesDir + '/' + fileName + FileConstants.COMPRESSED_FILE_SUFFIXES[0];
    let outFile = this.context.filesDir + FileConstants.DECOMPRESSED_FILE_DIRECTORY + '/' + fileName +
      FileConstants.TXT_FILE_TYPE;
    let isExist: boolean = await this.fileUtil.isCompressedFileExisted(outFile);
    if (isExist) {
      this.fileUtil.deleteOriginalFile(outFile);
    }
    try {
      unGzipFile(inFile, outFile).then((isSuccess: boolean) => {
        if (!isSuccess) {
          Logger.error(`Failed to decompress the gzip file.`);
          return;
        }
        if (isExist) {
          this.uiContext.getPromptAction().showToast({ message: FileConstants.TOAST_TEXTS[2] });
        }
        this.fileUtil.addToFileList(outFile, fileName, FileConstants.TXT_FILE_TYPE);
      }).catch((err: BusinessError) => {
        Logger.error(`Failed to decompress the gzip file, error code: ${err.code}, error message: ${err.message}`);
      });
    } catch (error) {
      Logger.error(`Failed to compress the file. Error: ${JSON.stringify(error)}.`);
    }
  }

  async compressIntoTar(fileName: string): Promise<void> {
    let outFilePath: string = this.context.filesDir + '/' + fileName + FileConstants.COMPRESSED_FILE_SUFFIXES[3];
    let isExist: boolean = await this.fileUtil.isCompressedFileExisted(outFilePath);
    if (isExist) {
      this.uiContext.getPromptAction().showToast({ message: FileConstants.TOAST_TEXTS[0] });
      return;
    }
    try {
      let outFile: File = new File(this.context.filesDir, fileName + FileConstants.COMPRESSED_FILE_SUFFIXES[3]);
      let inFile: File = new File(this.context.filesDir, fileName + FileConstants.TXT_FILE_TYPE);
      let inFileStream: InputStream = new InputStream();
      inFileStream.setFilePath(inFile.getPath());
      let outFileStream: OutputStream = new OutputStream();
      outFileStream.setFilePath(outFile.getPath());
      let archiveOutFileStream: ArchiveOutputStream = ArchiveStreamFactory.DEFAULT.createArchiveOutputStream(
        FileConstants.TAR_TYPE, outFileStream);
      let fileEntry: TarArchiveEntry = new TarArchiveEntry();
      fileEntry.tarArchiveEntryPreserveAbsolutePath2(FileConstants.TAR_FILE_DIRECTORY + fileName +
      FileConstants.TXT_FILE_TYPE, false);
      fileEntry.setModTime(Long.fromNumber(0));
      fileEntry.setSize(Long.fromNumber(inFile.length()));
      fileEntry.setUserId(0);
      fileEntry.setGroupId(0);
      fileEntry.setUserName('avalon');
      fileEntry.setGroupName('excalibur');
      fileEntry.setMode(FileConstants.TAR_ARCHIVE_ENTRY_MODE);
      archiveOutFileStream.putArchiveEntry(fileEntry);
      IOUtils.copyStream(inFileStream, archiveOutFileStream);
      archiveOutFileStream.closeArchiveEntry();
      archiveOutFileStream.close();
      this.fileUtil.addToFileList(outFilePath, fileName, FileConstants.COMPRESSED_FILE_SUFFIXES[3]);
    } catch (error) {
      Logger.error(`Failed to compress the tar file. Error: ${JSON.stringify(error)}`);
      this.uiContext.getPromptAction().showToast({ message: FileConstants.TOAST_TEXTS[1] });
    }
  }

  async decompressTarFile(fileName: string): Promise<void> {
    let outFile: string = this.context.filesDir + FileConstants.DECOMPRESSED_FILE_DIRECTORY + '/' + fileName +
      FileConstants.TXT_FILE_TYPE;
    let isExist: boolean = await this.fileUtil.isCompressedFileExisted(outFile);
    if (isExist) {
      this.fileUtil.deleteOriginalFile(outFile);
    }
    let input: File = new File(this.context.filesDir, fileName + FileConstants.COMPRESSED_FILE_SUFFIXES[3]);
    let inputFileStream: InputStream = new InputStream();
    inputFileStream.setFilePath(input.getPath());
    let fileTarInputStream: TarArchiveInputStream = new TarArchiveInputStream(inputFileStream,
      FileConstants.RECORD_SIZES[1], FileConstants.RECORD_SIZES[0], '', false);
    let tarArchiveEntry: TarArchiveEntry;
    while ((tarArchiveEntry = fileTarInputStream.getNextTarEntry()) !== null) {
      let name: string = tarArchiveEntry.getName();
      let tarFile: File = new File(this.context.filesDir, name);
      let fos: OutputStream | null = null;
      try {
        fos = new OutputStream();
        fos!.setFilePath(tarFile.getPath());
        let read: number = -1;
        let buffer: Int8Array = new Int8Array(tarArchiveEntry.getRealSize().toNumber());
        while ((read = fileTarInputStream.readBytes(buffer)) !== -1) {
          fos!.writeBytesOffset(buffer, 0, read);
        }
      } catch (error) {
        Logger.error(`Failed to decompress the tar file. Error: ${JSON.stringify(error)}`);
      } finally {
        fos!.close();
        if (isExist) {
          this.uiContext.getPromptAction().showToast({ message: FileConstants.TOAST_TEXTS[2] });
        }
        this.fileUtil.addToFileList(outFile, fileName, FileConstants.TXT_FILE_TYPE);
      }
    }
  }

  async compressInto7z(fileName: string): Promise<void> {
    let outFile: string = this.context.filesDir + '/' + fileName + FileConstants.COMPRESSED_FILE_SUFFIXES[2];
    let isExist: boolean = await this.fileUtil.isCompressedFileExisted(outFile);
    if (isExist) {
      this.uiContext.getPromptAction().showToast({ message: FileConstants.TOAST_TEXTS[0] });
      return;
    }
    let inFile: string = this.context.filesDir + '/' + fileName + FileConstants.TXT_FILE_TYPE;
    let inputFileStream: InputStream = new InputStream();
    inputFileStream.setFilePath(inFile);
    let outputFileStream: OutputStream = new OutputStream();
    outputFileStream.setFilePath(outFile);
    let encoder: Encoder = new Encoder();
    if (!encoder.SetAlgorithm(FileConstants.ENCODE_PARAMS_7Z[2]) ||
      !encoder.SetDictionarySize(FileConstants.ENCODE_PARAMS_7Z[1] << FileConstants.ENCODE_PARAMS_7Z[4]) ||
      !encoder.SetNumFastBytes(FileConstants.ENCODE_PARAMS_7Z[5]) ||
      !encoder.SetMatchFinder(FileConstants.ENCODE_PARAMS_7Z[1]) ||
      !encoder.SetLcLpPb(FileConstants.ENCODE_PARAMS_7Z[3], FileConstants.ENCODE_PARAMS_7Z[0],
        FileConstants.ENCODE_PARAMS_7Z[2])) {
      this.uiContext.getPromptAction().showToast({ message: FileConstants.TOAST_TEXTS[1] });
      return;
    }
    encoder.SetEndMarkerMode(false);
    encoder.WriteCoderProperties(outputFileStream);
    let fileSize: Long = Long.fromNumber(fileIo.statSync(inFile).size);
    for (let i = 0; i < FileConstants.ENCODE_PARAMS_7Z[6]; i++) {
      outputFileStream.write(fileSize.shiftRightUnsigned(FileConstants.ENCODE_PARAMS_7Z[6] * i).toInt() & 0xFF);
    }
    encoder.Code(inputFileStream, outputFileStream, Long.fromNumber(FileConstants.ENCODE_PARAMS_7Z[7]),
      Long.fromNumber(FileConstants.ENCODE_PARAMS_7Z[7]), null);
    outputFileStream.flush();
    outputFileStream.close();
    inputFileStream.close();
    this.fileUtil.addToFileList(outFile, fileName, FileConstants.COMPRESSED_FILE_SUFFIXES[2]);
  }

  async decompress7zFile(fileName: string): Promise<void> {
    let outFile: string = this.context.filesDir + FileConstants.DECOMPRESSED_FILE_DIRECTORY + '/' + fileName +
      FileConstants.TXT_FILE_TYPE;
    let isExist: boolean = await this.fileUtil.isCompressedFileExisted(outFile);
    if (isExist) {
      this.fileUtil.deleteOriginalFile(outFile);
    }
    let inFile: string = this.context.filesDir + '/' + fileName + FileConstants.COMPRESSED_FILE_SUFFIXES[2];
    let decoder: Decoder = new Decoder();
    let inputStream: InputStream = new InputStream();
    inputStream.setFilePath(inFile);
    let outputStream: OutputStream = new OutputStream();
    outputStream.setFilePath(outFile);
    let propertiesSize = FileConstants.DECODE_PARAMS_7Z[0];
    let properties: Int8Array = new Int8Array(propertiesSize);
    if (inputStream.readBytesOffset(properties, 0, propertiesSize) !== propertiesSize) {
      throw new Exception('Failed to decompress the 7z file, error message: input .7z file is too short');
    }
    if (!decoder.SetDecoderProperties(properties)) {
      throw new Exception('Failed to decompress the 7z file, error message: incorrect stream properties');
    }
    let outSize: Long = Long.fromNumber(0);
    for (let i = 0; i < FileConstants.DECODE_PARAMS_7Z[1]; i++) {
      let v: number = inputStream.read();
      if (v < 0) {
        throw new Exception('Failed to decompress the 7z file, error message: can\'t read stream size');
      }
      outSize = outSize.or(Long.fromNumber(v).shiftLeft(FileConstants.DECODE_PARAMS_7Z[1] * i));
    }
    if (!decoder.Code(inputStream, outputStream, outSize)) {
      throw new Exception('Failed to decompress the 7z file, error message: error in data stream');
    }
    outputStream.flush();
    outputStream.close();
    inputStream.close();
    if (isExist) {
      this.uiContext.getPromptAction().showToast({ message: FileConstants.TOAST_TEXTS[2] });
    }
    this.fileUtil.addToFileList(outFile, fileName, FileConstants.TXT_FILE_TYPE);
  }
}