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

import {
  BarChart,
  BarChartModel,
  BarData,
  BarDataSet,
  BarEntry,
  ChartColor,
  ChartGesture,
  ChartPixelMap,
  Description,
  EntryOhos,
  Highlight,
  IBarDataSet,
  JArrayList,
  Legend,
  OnChartGestureListener,
  OnChartValueSelectedListener,
  XAxis,
  YAxis
} from '@ohos/mpchart';
import Logger from '../utils/Logger';

@Component
export struct BarChartView {
  private model: BarChartModel | undefined = undefined;
  private leftAxis: YAxis | null = null;
  private rightAxis: YAxis | null = null;
  private xAxis: XAxis | null = null;
  private data: BarData | null = null;
  private pixelMap: ChartPixelMap = new ChartPixelMap();
  private valueSelectedListener: OnChartValueSelectedListener = {
    onValueSelected: (e: EntryOhos, h: Highlight) => {
      Logger.info(`ValueSelectedListener onValueSelected EntryOhos:${e}, Highlight:${h}`);
    },
    onNothingSelected: () => {
      Logger.info('ValueSelectedListener onNothingSelected');
    }
  }
  private chartGestureListener: OnChartGestureListener = {
    onChartGestureStart: (isTouchEvent: boolean, me: TouchEvent | GestureEvent,
      lastPerformedGestureMode: ChartGesture) => {
      Logger.info(`ChartGestureListener onChartGestureStart isTouchEvent:${isTouchEvent}, me:${me}, lastPerformedGestureMode:${lastPerformedGestureMode}`);
    },
    onChartGestureEnd: (isTouchEvent: boolean, me: TouchEvent | GestureEvent,
      lastPerformedGestureMode: ChartGesture) => {
      Logger.info(`ChartGestureListener onChartGestureEnd isTouchEvent:${isTouchEvent}, me:${me}, lastPerformedGestureMode:${lastPerformedGestureMode}`);
    },
    onChartLongPressed: (isTouchEvent: boolean, me: TouchEvent | GestureEvent) => {
      Logger.info(`ChartGestureListener onChartLongPressed isTouchEvent:${isTouchEvent}, me:${me}`);
    },
    onChartDoubleTapped: (isTouchEvent: boolean, me: TouchEvent | GestureEvent) => {
      Logger.info(`ChartGestureListener onChartDoubleTapped isTouchEvent:${isTouchEvent}, me:${me}`);
    },
    onChartSingleTapped: (isTouchEvent: boolean, me: TouchEvent | GestureEvent) => {
      Logger.info(`ChartGestureListener onChartSingleTapped isTouchEvent:${isTouchEvent}, me:${me}`);
    },
    onChartFling: (isTouchEvent: boolean, me1: TouchEvent | GestureEvent, me2: TouchEvent, velocityX: number,
      velocityY: number) => {
      Logger.info(`ChartGestureListener onChartSingleTapped isTouchEvent:${isTouchEvent}, me1:${me1}, me2:${me2}, velocityX:${velocityX}, velocityY:${velocityY}`);
    },
    onChartScale: (isTouchEvent: boolean, me: TouchEvent | GestureEvent, scaleX: number, scaleY: number) => {
      Logger.info(`ChartGestureListener onChartSingleTapped isTouchEvent:${isTouchEvent}, me:${me}, scaleX:${scaleX}, scaleY:${scaleY}`);
    },
    onChartTranslate: (isTouchEvent: boolean, me: TouchEvent | GestureEvent, dX: number, dY: number) => {
      Logger.info(`ChartGestureListener onChartSingleTapped isTouchEvent:${isTouchEvent}, me:${me}, dX:${dX}, dY:${dY}`);
    },
    onChartMove: (isTouchEvent: boolean, me: TouchEvent | GestureEvent) => {
      Logger.info(`ChartGestureListener onChartSingleTapped isTouchEvent:${isTouchEvent}, me:${me}`);
    }
  }

  async aboutToAppear() {
    this.model = new BarChartModel();
    this.model.setOnChartValueSelectedListener(this.valueSelectedListener);
    this.model.setOnChartGestureListener(this.chartGestureListener);
    this.model.setDragEnabled(true); // Disable sliding.
    this.model.setScaleEnabled(false); // Disable zooming.
    let description: Description | null = this.model.getDescription()
    if (description) {
      description.setEnabled(true);
      description.setText('');
    }
    let legend: Legend | null = this.model.getLegend();
    if (legend) {
      legend.setEnabled(false);
    }
    // if more than 40 entries are displayed in the this.model, no values will be drawn
    this.model.setMaxVisibleValueCount(110);
    // scaling can now only be done on x- and y-axis separately
    this.model.setPinchZoom(false);
    this.model.setDrawGridBackground(false);
    this.model.setGridBackgroundColor('#500000ff')
    this.model.setDrawBarShadow(false);
    this.model.setDrawValueAboveBar(false);
    this.model.setHighlightFullBarEnabled(false);
    // change the position of the y-labels
    this.leftAxis = this.model.getAxisLeft();
    if (this.leftAxis) {
      this.leftAxis.setAxisMinimum(0);
      this.leftAxis.setDrawLimitLinesBehindData(false);
    }
    this.rightAxis = this.model.getAxisRight();
    if (this.rightAxis) {
      this.rightAxis.setEnabled(false);
      this.rightAxis.setAxisMinimum(0);
    }
    if (this.leftAxis) {
      this.leftAxis.setEnabled(false);
    }
    this.xAxis = this.model.getXAxis();
    if (this.xAxis) {
      this.xAxis.setEnabled(false);
    }

    this.data = await this.getNormalData();
    this.model.setData(this.data);
    this.model.setVisibleXRangeMaximum(110);
  }

  private async getNormalData(): Promise<BarData> {
    let values: JArrayList<BarEntry> = new JArrayList<BarEntry>();
    for (let index = 0; index < 110; index++) {
      values.add(new BarEntry(index, Math.floor(Math.random() * 100) + 1, this.pixelMap));
    }
    let dataSet: BarDataSet = new BarDataSet(values, '');
    dataSet.setDrawIcons(false);
    dataSet.setColorsByVariable([ChartColor.rgb(29, 183, 117), ChartColor.rgb(29, 183, 117),
      ChartColor.rgb(250, 67, 55), ChartColor.rgb(250, 67, 55)]);
    let dataSetList: JArrayList<IBarDataSet> = new JArrayList<IBarDataSet>();
    dataSetList.add(dataSet);
    let barData: BarData = new BarData(dataSetList);
    barData.setBarWidth(0.85);
    return barData;
  }

  build() {
    Column() {
      Column() {
        BarChart({ model: this.model })
      }
    }
  }
}