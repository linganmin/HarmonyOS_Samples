/**
 * FAQ:如何在Index.ets中导出默认导出的对象
 */
// [Start import_test_fn]
import {Decimal} from "@kit.ArkTS";

export function test(){
  let data:Decimal=new Decimal(1.2314567890123456);
  Decimal.set({
    precision:5,
    rounding:0,
    toExpNeg:-7,
    toExpPos:7,
    maxE:9e15,
    minE:-9e15,
    modulo:1,
    crypto:false
  });
  let data1:Decimal = data.add(0.5);
  console.info("test Decimal set:"+data1.toString())
}
// [End import_test_fn]