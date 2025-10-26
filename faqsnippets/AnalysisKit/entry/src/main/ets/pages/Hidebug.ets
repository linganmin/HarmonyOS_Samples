/**
 * FAQ:如何查询应用当前CPU占用
 * FAQ:如何查询应用堆内存的已分配内存大小和堆内存的空闲内存大小
 */
import { hidebug } from '@kit.PerformanceAnalysisKit';

// [Start cup_sage]
let cpuUsage: number = hidebug.getCpuUsage();
// [End cup_sage]

// [Start get_heap_size]
let nativeHeapAllocatedSize: bigint = hidebug.getNativeHeapAllocatedSize(); // Get the allocated memory size of the heap memory in this application
let nativeHeapFreeSize: bigint = hidebug.getNativeHeapFreeSize(); // Get the free memory size of the heap memory in this application
// [End get_heap_size]