/*
* FAQ:推包调试报错“Error message:cannot find record '&XXX/src/main/ets/YYY&x.y.z', please check the request path.'ZZZ.abc'.”
 */

// [Start hvigor_config]
import { appTasks } from '@ohos/hvigor-ohos-plugin';
import { updateAbcVersionPlugin, updateHarAbcVersionPlugin } from './plugin.ts';


export default {
    system: appTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
    plugins:[updateAbcVersionPlugin(), updateHarAbcVersionPlugin()]         /* Custom plugin to extend the functionality of Hvigor. */
}
// [End hvigor_config]