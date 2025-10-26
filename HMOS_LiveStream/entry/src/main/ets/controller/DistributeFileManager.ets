import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileUri, fileIo as fs, ListFileOptions } from '@kit.CoreFileKit';
import { distributedDeviceManager } from '@kit.DistributedServiceKit';
import Logger from '../common/utils/Logger';


const TAG = '[DistributeFileManager]';

interface VideoFileFound {
  mTimeNew: number;
  filePath: string;
}

export class DistributeFileManager {
  /**
   * Get the video file in sandbox
   */
  public async getVideoFile(uiContext: common.UIAbilityContext): Promise<string> {
    const pathDirSandbox = uiContext.filesDir;
    const pathDirDistribute = uiContext.distributedFilesDir;

    let mTimeNew = 0;
    let filePath = '';

    try {
      // Processing video files in distributed devices
      const deviceFileResult = await this.processDistributedDevices(pathDirSandbox, pathDirDistribute);
      mTimeNew = deviceFileResult.mTimeNew;
      filePath = deviceFileResult.filePath;

      // Finally processing the video files in the sandbox
      const filenamesSandbox = await this.listVideoFiles(pathDirSandbox);
      return await this.finalizeVideoSelection(pathDirSandbox, filenamesSandbox, mTimeNew, filePath);
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Get video file, errCode = ${err.code}, errMessage = ${err.message}.`);
      return '';
    }
  }

  /**
   * Copy the file to the distribute
   */
  public async copyFileToDistribute(uiContext: common.UIAbilityContext, fileName: string | undefined) {
    let pathDirSandbox: string = uiContext.filesDir;
    let pathDirDistribute: string = uiContext.distributedFilesDir;
    let filePathSandbox: string = pathDirSandbox + fileName;
    let filePathDistribute: string = pathDirDistribute + fileName;
    let srcUri = fileUri.getUriFromPath(filePathSandbox);
    let destUri: string = fileUri.getUriFromPath(filePathDistribute);
    try {
      await fs.copy(srcUri, destUri);
      Logger.info(TAG, `Succeeded in copying. src: ${srcUri}, dest: ${destUri}.`);
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(TAG, `copy file failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
  }

  /**
   * List the video files in the specified directory
   */
  private async listVideoFiles(directory: string): Promise<string[]> {
    const listFileOption: ListFileOptions = {
      recursion: false,
      listNum: 0,
      filter: { suffix: ['.mp4'] }
    };

    try {
      return await fs.listFile(directory, listFileOption);
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(TAG, `List video files, errCode = ${err.code}, errMessage = ${err.message}.`);
      return [];
    }
  }

  /**
   * Processing video files in distributed devices
   */
  private async processDistributedDevices(
    pathDirSandbox: string,
    pathDirDistribute: string
  ): Promise<VideoFileFound> {
    let mTimeNew = 0;
    let filePath = '';

    const deviceList = this.getAvailableDevices();
    if (!deviceList || deviceList.length === 0) {
      return { mTimeNew, filePath };
    }

    for (const deviceInfo of deviceList) {
      const result = await this.processSingleDevice(
        deviceInfo,
        pathDirSandbox,
        pathDirDistribute,
        mTimeNew,
        filePath
      );
      mTimeNew = result.mTimeNew;
      filePath = result.filePath;
    }

    return { mTimeNew, filePath };
  }

  /**
   * Get the list of available devices
   */
  private getAvailableDevices(): Array<distributedDeviceManager.DeviceBasicInfo> {
    try {
      const dmInstance = distributedDeviceManager.createDeviceManager('com.samples.HMOSLiveStream');
      return dmInstance.getAvailableDeviceListSync();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Get available devices, errCode = ${err.code}, errMessage = ${err.message}.`);
      return [];
    }
  }

  /**
   * Process files within a single device
   */
  private async processSingleDevice(
    deviceInfo: distributedDeviceManager.DeviceBasicInfo,
    pathDirSandbox: string,
    pathDirDistribute: string,
    currentMTime: number,
    currentFilePath: string
  ): Promise<VideoFileFound> {
    let mTimeNew = currentMTime;
    let filePath = currentFilePath;

    try {
      await this.connectToDevice(deviceInfo.networkId);

      const filenamesDistribute = await this.listVideoFiles(pathDirDistribute);
      const filenamesSandbox = await this.listVideoFiles(pathDirSandbox);

      const result = await this.processDeviceFiles(
        filenamesDistribute,
        filenamesSandbox,
        pathDirSandbox,
        pathDirDistribute,
        mTimeNew,
        filePath
      );

      mTimeNew = result.mTimeNew;
      filePath = result.filePath;

      await this.disconnectFromDevice(deviceInfo.networkId);
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Process single device, errCode = ${err.code}, errMessage = ${err.message}.`);
    }

    return { mTimeNew, filePath };
  }

  /**
   * Connect to device
   */
  private async connectToDevice(networkId: string | undefined): Promise<void> {
    const listeners: fs.DfsListeners = {
      onStatus: (_: string, status: number): void => {
        Logger.error(TAG, `Access public directory failed, status: ${status}.`);
      }
    };

    try {
      await fs.connectDfs(networkId, listeners);
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Connect to device, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
  }

  /**
   * Disconnect from the device
   */
  private async disconnectFromDevice(networkId: string | undefined): Promise<void> {
    try {
      await fs.disconnectDfs(networkId);
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Disconnect from device, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
  }

  /**
   * Handle files in the device
   */
  private async processDeviceFiles(
    distributeFiles: string[],
    sandboxFiles: string[],
    pathDirSandbox: string,
    pathDirDistribute: string,
    currentMTime: number,
    currentFilePath: string
  ): Promise<VideoFileFound> {
    let mTimeNew = currentMTime;
    let filePath = currentFilePath;

    for (const filename of distributeFiles) {
      if (sandboxFiles.includes(filename)) {
        continue; // The file already exists, skipping.
      }

      const fileResult = await this.processSingleFile(
        filename,
        pathDirSandbox,
        pathDirDistribute,
        mTimeNew,
        filePath
      );

      mTimeNew = fileResult.mTimeNew;
      filePath = fileResult.filePath;
    }

    return { mTimeNew, filePath };
  }

  /**
   * Process a single file
   */
  private async processSingleFile(
    filename: string,
    pathDirSandbox: string,
    pathDirDistribute: string,
    currentMTime: number,
    currentFilePath: string
  ): Promise<VideoFileFound> {
    try {
      const fileStat = fs.statSync(`${pathDirDistribute}/${filename}`);
      const mTime = fileStat.mtime;

      await this.copyFileToSandbox(filename, pathDirSandbox, pathDirDistribute);

      if (mTime > currentMTime) {
        return {
          mTimeNew: mTime,
          filePath: `${pathDirSandbox}/${filename}`
        };
      }
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Process single file, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
    return { mTimeNew: currentMTime, filePath: currentFilePath };
  }

  /**
   * Copy the file to the sandbox
   */
  private async copyFileToSandbox(
    filename: string,
    pathDirSandbox: string,
    pathDirDistribute: string
  ): Promise<void> {
    const srcUri = fileUri.getUriFromPath(`${pathDirDistribute}/${filename}`);
    const destUri = fileUri.getUriFromPath(`${pathDirSandbox}/${filename}`);

    try {
      await fs.copy(srcUri, destUri);
      // 复制完成后清理分布式目录中的临时文件
      fs.unlinkSync(`${pathDirDistribute}/${filename}`);
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Copy file to sandbox, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
  }

  /**
   * The final selected video file
   */
  private async finalizeVideoSelection(
    pathDirSandbox: string,
    filenamesSandbox: string[],
    mTimeNew: number,
    currentFilePath: string
  ): Promise<string> {
    if (filenamesSandbox.length === 0) {
      return '';
    }

    if (mTimeNew === 0) {
      return this.findLatestFileInSandbox(pathDirSandbox, filenamesSandbox);
    }

    return currentFilePath;
  }

  /**
   * Find the latest files in the sandbox
   */
  private findLatestFileInSandbox(pathDirSandbox: string, filenames: string[]): string {
    let mTimeNew = 0;
    let filePath = '';

    for (const filename of filenames) {
      try {
        const fileStat = fs.statSync(`${pathDirSandbox}/${filename}`);
        const mTime = fileStat.mtime;

        if (mTime > mTimeNew) {
          mTimeNew = mTime;
          filePath = `${pathDirSandbox}/${filename}`;
        }
      } catch (error) {
        let err: BusinessError = error as BusinessError;
        Logger.error(TAG, `Find latest file in sandbox, errCode = ${err.code}, errMessage = ${err.message}.`);
      }
    }

    return filePath;
  }
}