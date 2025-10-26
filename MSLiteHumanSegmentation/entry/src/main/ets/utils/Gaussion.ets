/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { MODEL_INPUT_HEIGHT } from '../common/constants/ImageDataListConstant';
import Logger from './Logger';

function gaussianRun(mat: Uint8Array) {
  Logger.info('----- gaussian run -----');
  let rMat = new Array<Array<number>>();
  let gMat = new Array<Array<number>>();
  let bMat = new Array<Array<number>>();
  for (let i = 0; i < MODEL_INPUT_HEIGHT; ++i) {
    let rTempArr = new Array<number>();
    let gTempArr = new Array<number>();
    let bTempArr = new Array<number>();
    for (let j = 0; j < MODEL_INPUT_HEIGHT; ++j) {
      let index = (i * MODEL_INPUT_HEIGHT + j) * 4;
      rTempArr.push(mat[index]);
      gTempArr.push(mat[index + 1]);
      bTempArr.push(mat[index + 2]);
    }
    rMat.push(rTempArr);
    gMat.push(gTempArr);
    bMat.push(bTempArr);
  }
  calcGaussian(rMat);
  calcGaussian(gMat);
  calcGaussian(bMat);
  for (let i = 0; i < mat.length; ++i) {
    if ((i + 1) % 4 === 0) {
      let chanelPx: number = Math.floor(i / 4 / MODEL_INPUT_HEIGHT);
      let chanelPy: number = Math.floor((i % (4 * MODEL_INPUT_HEIGHT)) / 4);
      mat[i - 3] = rMat[chanelPx][chanelPy];
      mat[i - 2] = rMat[chanelPx][chanelPy];
      mat[i - 1] = rMat[chanelPx][chanelPy];
    }
  }
}

function calcGaussian(calcMat: Array<Array<number>>) {
  Logger.info('_...-----calcGaussian run----------')
  for (let i = 1; i < calcMat.length - 1; ++i) {
    for (let j = 1; j < calcMat[i].length - 1; ++j) {
      calcMat[i][j] = getOpValue(calcMat, i, j)
    }
  }
}

// Template generated using a Gaussian function with o=0.8
function getOpValue(mat: Array<Array<number>>, i: number, j: number): number {
  return Math.floor(
      (mat[i - 1][j - 1] / 16.0) +
      (mat[i - 1][j] / 8.0) +
      (mat[i - 1][j + 1] / 16.0) +
      (mat[i][j - 1] / 8.0) +
      (mat[i][j] / 4.0) +
      (mat[i][j + 1] / 8.0) +
      (mat[i + 1][j - 1] / 16.0) +
      (mat[i + 1][j] / 8.0) +
      (mat[i + 1][j + 1] / 16.0))
}

export {
  gaussianRun
}