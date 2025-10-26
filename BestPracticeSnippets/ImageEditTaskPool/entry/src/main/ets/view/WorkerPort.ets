import { MessageEvents } from '@kit.ArkTS';
import { CommonConstants } from '../common/constant/CommonConstants';
import { AngelRange, HSVIndex, RGBIndex } from '../viewModel/OptionViewModel';

let WorkerPort: ESObject;
let WorkerBuffer: ESObject;
// [Start WorkerPort]
// The child thread receives the task and calculates it.
WorkerPort.onmessage = (event: MessageEvents) => {
  let bufferArray: ArrayBuffer = event.data.buf;
  let last: number = event.data.last;
  let cur: number = event.data.cur;
  let index: number = event.data.index;
  let buffer = adjustImageValue(bufferArray, last, cur); // Pixel calculation execution
  let output: ESObject = new WorkerBuffer(buffer, index);
  WorkerPort.postMessage(output); // Send the calculation result to the main thread.
}


function adjustImageValue(bufferArray: ArrayBuffer, last: number, cur: number, hsvIndex?: number): ArrayBuffer {
  return execColorInfo(bufferArray, last, cur, HSVIndex.VALUE);
}

// Picture pixel calculation
function execColorInfo(bufferArray: ArrayBuffer, last: number, cur: number, hsvIndex: number) {
  // ...
  const newBufferArr = bufferArray;
  let colorInfo = new Uint8Array(newBufferArr);
  for (let i = 0; i < colorInfo?.length; i += CommonConstants.PIXEL_STEP) {
    const hsv = rgb2hsv(colorInfo[i + RGBIndex.RED], colorInfo[i + RGBIndex.GREEN], colorInfo[i + RGBIndex.BLUE]);
    let rate = cur / last;
    hsv[hsvIndex] *= rate;
    const rgb: ESObject = hsv2rgb(hsv[HSVIndex.HUE], hsv[HSVIndex.SATURATION], hsv[HSVIndex.VALUE]);
    colorInfo[i + RGBIndex.RED] = rgb[RGBIndex.RED];
    colorInfo[i + RGBIndex.GREEN] = rgb[RGBIndex.GREEN];
    colorInfo[i + RGBIndex.BLUE] = rgb[RGBIndex.BLUE];
  }
  return newBufferArr;
}

// [End WorkerPort]
function colorTransform(rgbValue: number): number {
  return Number((rgbValue / 255).toFixed(2));
}

function rgb2hsv(red: number, green: number, blue: number): number[] {
  let hsvH: number = 0, hsvS: number = 0, hsvV: number = 0;
  const rgbR: number = colorTransform(red);
  const rgbG: number = colorTransform(green);
  const rgbB: number = colorTransform(blue);
  const maxValue = Math.max(rgbR, Math.max(rgbG, rgbB));
  const minValue = Math.min(rgbR, Math.min(rgbG, rgbB));
  hsvV = maxValue * 100;
  if (maxValue === 0) {
    hsvS = 0;
  } else {
    hsvS = Number((1 - minValue / maxValue).toFixed(2)) * 100;
  }
  if (maxValue === minValue) {
    hsvH = 0;
  }
  if (maxValue === rgbR && rgbG >= rgbB) {
    hsvH = Math.floor(60 * ((rgbG - rgbB) / (maxValue - minValue)));
  }
  if (maxValue === rgbR && rgbG < rgbB) {
    hsvH = Math.floor(60 * ((rgbG - rgbB) / (maxValue - minValue)) + 360);
  }
  if (maxValue === rgbG) {
    hsvH = Math.floor(60 * ((rgbB - rgbR) / (maxValue - minValue)) + 120);
  }
  if (maxValue === rgbB) {
    hsvH = Math.floor(60 * ((rgbR - rgbG) / (maxValue - minValue)) + 240);
  }
  return [hsvH, hsvS, hsvV];
}

function hsv2rgb(hue: number, saturation: number, value: number): ESObject {
  let rgbR: number = 0, rgbG: number = 0, rgbB: number = 0;
  if (saturation === 0) {
    rgbR = rgbG = rgbB = Math.round((value * 255) / 100);
    return { rgbR, rgbG, rgbB };
  }
  const cxmC = (value * saturation) / (100 * 100);
  const cxmX = cxmC * (1 - Math.abs((hue / 60) % 2 - 1));
  const cxmM = (value - cxmC * 100) / 100;
  const hsvHRange = Math.floor(hue / 60);
  switch (hsvHRange) {
    case AngelRange.ANGEL_0_60:
      rgbR = (cxmC + cxmM) * 255;
      rgbG = (cxmX + cxmM) * 255;
      rgbB = (0 + cxmM) * 255;
      break;
    case AngelRange.ANGEL_60_120:
      rgbR = (cxmX + cxmM) * 255;
      rgbG = (cxmC + cxmM) * 255;
      rgbB = (0 + cxmM) * 255;
      break;
    case AngelRange.ANGEL_120_180:
      rgbR = (0 + cxmM) * 255;
      rgbG = (cxmC + cxmM) * 255;
      rgbB = (cxmX + cxmM) * 255;
      break;
    case AngelRange.ANGEL_180_240:
      rgbR = (0 + cxmM) * 255;
      rgbG = (cxmX + cxmM) * 255;
      rgbB = (cxmC + cxmM) * 255;
      break;
    case AngelRange.ANGEL_240_300:
      rgbR = (cxmX + cxmM) * 255;
      rgbG = (0 + cxmM) * 255;
      rgbB = (cxmC + cxmM) * 255;
      break;
    case AngelRange.ANGEL_300_360:
      rgbR = (cxmC + cxmM) * 255;
      rgbG = (0 + cxmM) * 255;
      rgbB = (cxmX + cxmM) * 255;
      break;
    default:
      break;
  }
  return [
    Math.round(rgbR),
    Math.round(rgbG),
    Math.round(rgbB)
  ];
}
