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

import { HashMap } from '@kit.ArkTS';
import {
  EntryOhos,
  ILineDataSet,
  JArrayList,
  LineChartModel,
  LineData,
  LineDataSet,
  XAxis,
  XAxisPosition,
  YAxis,
  YAxisLabelPosition,
  ChartColorStop,
  Legend,
  Description
} from '@ohos/mpchart';
import { ChartAxisFormatter } from './ChartAxisFormatter';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

class LinesChartModel {
  xAxis: XAxis | null = null;
  topAxis: XAxis | null = null;
  mWidth: number = 312;
  mHeight: number = 200;
  minOffset: number = 30;
  leftAxis: YAxis | null = null;
  rightAxis: YAxis | null = null;
  lineData: LineData | null = null;
  lineChartModel: LineChartModel = new LineChartModel();
  maxValue: number = 0;
  minValue: number = 0;

  public constructor() {
    this.lineData = this.initCurveData(45);
  }

  /**
   * Init data.
   *
   * @param count  Init data count.
   */
  private initCurveData(count: number): LineData {
    let values = this.initRandomValue(count);
    let gradientFillColor = new JArrayList<ChartColorStop>();
    gradientFillColor.add(['#ECEEFB', 1.0]);
    let dataSet = new JArrayList<ILineDataSet>();

    let set1 = new LineDataSet(values, '');
    set1.setDrawFilled(true);
    set1.setDrawValues(false);
    set1.setGradientFillColor(gradientFillColor);
    set1.setColorByColor(0x0A59F7);
    set1.setLineWidth(1)
    set1.setDrawCircles(false);
    set1.setDrawHorizontalHighlightIndicator(false)
    set1.setDrawVerticalHighlightIndicator(false)
    dataSet.add(set1);

    let other = this.initRandomValue(count);
    let set2 = new LineDataSet(other, '');
    set2.setDrawFilled(false);
    set2.setDrawValues(false);
    set2.setColorByColor(0xFE8F00);
    set2.setLineWidth(1)
    set2.setDrawCircles(false);
    dataSet.add(set2);

    return new LineData(dataSet)
  }

  /**
   * Randomly generate data.
   *
   * @param count Init data count.
   * @returns JArrayList<EntryOhos>.
   */
  initRandomValue(count: number): JArrayList<EntryOhos> {
    let values = new JArrayList<EntryOhos>();
    values.add(new EntryOhos(0, 0));
    let temp = 0;
    for (let i = 1; i < count; i++) {
      let val: number = Math.random() * 0.5;
      let calculated: number = Math.random() * 100;
      if (calculated > 50) {
        temp += val;
        values.add(new EntryOhos(i, temp));
      } else {
        temp -= val;
        values.add(new EntryOhos(i, temp));
      }
      if (this.maxValue < temp) {
        this.maxValue = temp;
      }
      if (this.minValue > temp) {
        this.minValue = temp;
      }
    }
    return values;
  }

  /**
   * Get LineChartModel.
   */
  getLineChartModel(): LineChartModel {
    this.lineChartModel = new LineChartModel();
    this.xAxis = this.lineChartModel.getXAxis();
    if (this.xAxis) {
      this.xAxis.setLabelCount(3, true);
      this.xAxis.setPosition(XAxisPosition.BOTTOM);
      this.xAxis.setAxisMinimum(0);
      this.xAxis.setAxisMaximum(44);
      this.xAxis.setAvoidFirstLastClipping(true);
      this.xAxis.setDrawGridLines(false)
      let xMap: HashMap<number, string> = new HashMap();
      try {
        xMap.set(0, '09:30');
        xMap.set(22, '11:30 / 13:00');
        xMap.set(44, '15:00');
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, 'LinesChartModel', `xAxis yMap set failed, error code=${err.code}, message=${err.message}`);
      }
      this.xAxis.setValueFormatter(new ChartAxisFormatter(xMap));
      this.xAxis.setAxisLineColor(Color.White);
    }

    this.leftAxis = this.lineChartModel.getAxisLeft();
    if (this.leftAxis) {
      let maxy = Math.ceil(this.maxValue);
      let miny = Math.floor(this.minValue)
      this.leftAxis.setLabelCount(3, false);
      this.leftAxis.setPosition(YAxisLabelPosition.INSIDE_CHART);
      this.leftAxis.setSpaceTop(0);
      this.leftAxis.setAxisMaximum(maxy + 0.1);
      this.leftAxis.setAxisMinimum(miny - 0.1);
      this.leftAxis.setDrawGridLines(false);
      this.leftAxis.setDrawAxisLine(true);
      let yMap: HashMap<number, string> = new HashMap();
      try {
        yMap.set(miny, '18.01');
        yMap.set(0, '20.01');
        yMap.set(maxy, '22.01');
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, 'LinesChartModel',
          `leftAxis yMap set failed, error code=${err.code}, message=${err.message}`);
      }
      this.leftAxis.setValueFormatter(new ChartAxisFormatter(yMap));
      this.leftAxis.setAxisLineColor(Color.White);
    }

    this.rightAxis = this.lineChartModel.getAxisRight();
    if (this.rightAxis) {
      let maxy = Math.ceil(this.maxValue);
      let miny = Math.floor(this.minValue)
      this.rightAxis.setPosition(YAxisLabelPosition.INSIDE_CHART);
      this.rightAxis.setDrawGridLines(false);
      this.rightAxis.setDrawAxisLine(false);
      this.rightAxis.setDrawLabels(false);
      this.rightAxis.setAxisMaximum(maxy + 0.1);
      this.rightAxis.setAxisMinimum(miny - 0.1);
      this.rightAxis.setAxisLineColor(Color.White);
    }

    let legend: Legend | null = this.lineChartModel.getLegend();
    if (legend) {
      legend.setEnabled(false);
    }
    let description: Description | null = this.lineChartModel.getDescription();
    if (description) {
      description.setEnabled(false);
    }

    this.lineChartModel.setMinOffset(2);
    this.lineChartModel.setHighlightPerLongPressEnabled(false);
    this.lineChartModel.setData(this.lineData);
    this.lineChartModel.setDragEnabled(true); // Disable sliding.
    this.lineChartModel.setScaleEnabled(false); // Disable zooming.
    return this.lineChartModel;
  }
}

export default new LinesChartModel();