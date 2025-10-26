// FAQ:如何在编译过程中添加一些自定义的任务
// [Start custom_task]
import { hapTasks } from '@ohos/hvigor-ohos-plugin';
import { getNode, HvigorNode, HvigorTask } from '@ohos/hvigor';


const node = getNode(__filename);
node.registerTask({
    name: 'customTask',
    run() {
        console.log('this is Task');
    }});
// [End custom_task]

export default {
    system: hapTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
    plugins:[]         /* Custom plugin to extend the functionality of Hvigor. */
}
