/*
 * The MIT License (MIT)
 * Copyright (C) 2024 Huawei Device Co., Ltd.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 */

import { describe, it, expect, beforeEach } from '@ohos/hypium'
import { DataCache } from '@hadss/datacache';
import { GlobalContext } from '../testability/GlobalContext';

export default function AverageTimeTest() {

  describe('AverageTimeTest', () => {
    const COUNT = 2000;
    const KEY = 'TEST';
    const VAL = '111';
    const TIME = 1;
    let dataCache: DataCache;

    beforeEach(async () => {
      const CONTEXT: Context = GlobalContext.getContext().getObject("context") as Context;
      dataCache = DataCache.getInstance(CONTEXT);
      await dataCache.clear();
    })

    // get method
    it('get', 0, async (done: Function) => {
      dataCache.putSync(KEY, VAL);
      let startTime = new Date().getTime();
      let configTest: (index: number) => void = async (index) => {
        dataCache.get(KEY).then(() => {
          if (index < COUNT) {
            configTest(index + 1);
          } else {
            let endTime = new Date().getTime();
            let averageTime = (endTime - startTime) / COUNT;
            expect(averageTime).assertLess(5);
            done();
          }
        })
      };
      configTest(0);
    })

    // put method
    it('put', 1, async (done: Function) => {
      let startTime = new Date().getTime();
      let configTest: (index: number) => void = async (index) => {
        dataCache.put(KEY, VAL).then(() => {
          if (index < COUNT) {
            configTest(index + 1);
          } else {
            let endTime = new Date().getTime();
            let averageTime = (endTime - startTime) / COUNT;
            expect(averageTime).assertLess(5);
            done();
          }
        })
      };
      configTest(0);
    })

    // put method
    it('put has time', 2, async (done: Function) => {
      let startTime = new Date().getTime();
      let configTest: (index: number) => void = async (index) => {
        dataCache.put(KEY, VAL, TIME).then(() => {
          if (index < COUNT) {
            configTest(index + 1);
          } else {
            let endTime = new Date().getTime();
            let averageTime = (endTime - startTime) / COUNT;
            expect(averageTime).assertLess(5);
            done();
          }
        })
      };
      configTest(0);
    })

    // putSync method
    it('putSync', 3, () => {
      let startTime = new Date().getTime();
      let configTest: (index: number) => void = async (index) => {
        dataCache.putSync(KEY, VAL);
        if (index < COUNT) {
          configTest(index + 1);
        } else {
          let endTime = new Date().getTime();
          let averageTime = (endTime - startTime) / COUNT;
          expect(averageTime).assertLess(5);
        }
      };
      configTest(0);
    })

    // putSync method
    it('putSync has time', 4, () => {
      let startTime = new Date().getTime();
      let configTest: (index: number) => void = async (index) => {
        dataCache.putSync(KEY, VAL, TIME);
        if (index < COUNT) {
          configTest(index + 1);
        } else {
          let endTime = new Date().getTime();
          let averageTime = (endTime - startTime) / COUNT;
          expect(averageTime).assertLess(5);
        }
      };
      configTest(0);
    })

    // getSync method
    it('getSync', 5, () => {
      dataCache.putSync(KEY, VAL);
      let startTime = new Date().getTime();
      let configTest: (index: number) => void = async (index) => {
        dataCache.getSync(KEY);
        if (index < COUNT) {
          configTest(index + 1);
        } else {
          let endTime = new Date().getTime();
          let averageTime = (endTime - startTime) / COUNT;
          expect(averageTime).assertLess(5);
        }
      };
      configTest(0);
    })

    // delete method
    it('delete', 6, () => {
      let sum: number = 0;
      let configTest: (index: number) => void = async (index) => {
        dataCache.putSync(KEY, VAL);
        let startTime = new Date().getTime();
        dataCache.delete(KEY);
        let endTime = new Date().getTime();
        sum += endTime - startTime;
        if (index < COUNT) {
          configTest(index + 1);
        } else {
          let averageTime = sum / COUNT;
          expect(averageTime).assertLess(5);
        }
      };
      configTest(0);
    })

    // clear method
    it('clear', 7, async (done: Function) => {
      let sum: number = 0;
      let configTest = async (index: number): Promise<void> => {
        let startTime = new Date().getTime();
        await dataCache.clear();
        let endTime = new Date().getTime();
        sum += endTime - startTime;
        if (index < COUNT) {
          await configTest(index + 1);
        } else {
          let averageTime = sum / COUNT;
          expect(averageTime).assertLess(5);
          done();
        }
      };
      await configTest(0);
    })
  })
}
