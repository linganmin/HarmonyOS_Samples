// FAQ:如何写har包的编译脚本
// [Start har_hvigor_plugin]

import { harTasks } from '@ohos/hvigor-ohos-plugin';


function harTask(): HvigorPlugin {
    return {
        pluginId: 'harTask',
        apply(node: HvigorNode) {
            console.log('hello harTasks!');
        }
    }
}


export default {
    system: harTasks,
    plugins: [harTask()]
}
// [End har_hvigor_plugin]
