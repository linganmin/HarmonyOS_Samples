/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../common/utils/Logger';
import player from 'libplayer.so';
import recorder from 'librecorder.so';
import { CommonConstants as Const } from '../common/CommonConstants';


const TAG: string = "[BgmController]";

export class BgmController {
  private nativePlayerObj: bigint | undefined;
  private nativeRecorderObj: bigint | undefined;

  constructor(nativeRecorderObj: bigint | undefined) {
    this.nativeRecorderObj = nativeRecorderObj;
  }


  play(selectFilePath: string, callback: () => void) {
    let inputFile: fileIo.File;
    try {
      inputFile = fileIo.openSync(selectFilePath, fileIo.OpenMode.READ_ONLY);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `openSync failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      return;
    }
    if (!inputFile) {
      Logger.error(TAG, `player inputFile is null.`);
    }
    let inputFileState: fileIo.Stat;
    try {
      inputFileState = fileIo.statSync(inputFile.fd);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `getfile stat failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      return;
    }
    if (inputFileState.size <= 0) {
      Logger.error(TAG, `player inputFile size is 0.`);
    }
    this.nativePlayerObj = player.createPlayer()
    player.startPlay(this.nativePlayerObj, inputFile.fd, Const.DEFAULT_VALUE, inputFileState.size, () => {
      callback();
      fileIo.close(inputFile).catch((err: BusinessError) => {
        Logger.error(TAG, `fileIo close failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      });
    })
    recorder.setPlayerAsLiveBgm(this.nativeRecorderObj, this.nativePlayerObj);
  }

  stopPlay() {
    if (this.nativePlayerObj) {
      player.stopPlay(this.nativePlayerObj);
      player.releasePlayer(this.nativePlayerObj);
      this.nativePlayerObj = 0n;
    }
  }

  public release() {
    this.stopPlay();
  }
}