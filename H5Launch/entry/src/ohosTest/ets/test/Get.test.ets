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

export default function GetTest() {
  const KEY = 'GET';

  describe('GetTest', () => {
    beforeEach(async () => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      await dataCache.clear();
    })

    it('get', 0, async (done: Function) => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      const data = '111';
      dataCache.putSync(KEY, data);
      dataCache.get(KEY).then((val) => {
        expect(val).assertEqual(data);
        done();
      })
    })

    it('get when key is empty', 1, async (done: Function) => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      try {
        await dataCache.get('');
      } catch (error) {
        expect(error.code).assertEqual(401);
        done();
      }
    })

    it('get when key is not exit', 2, async (done: Function) => {
      const context: Context = GlobalContext.getContext().getObject("context") as Context;
      const dataCache = DataCache.getInstance(context);
      dataCache.get(KEY).then((val) => {
        expect(val).assertUndefined();
        done();
      })
    })
  })
}
