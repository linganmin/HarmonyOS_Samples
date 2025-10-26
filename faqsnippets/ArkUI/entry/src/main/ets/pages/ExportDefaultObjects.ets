/**
 * FAQ:如何在Index.ets中导出默认导出的对象
 */
// [Start export_default_obj]
import { DemoService } from "../service/DemoService";
class AppInterfaces {
  demoService?: DemoService;
}
let test = new AppInterfaces()
export default test;
// [End export_default_obj]