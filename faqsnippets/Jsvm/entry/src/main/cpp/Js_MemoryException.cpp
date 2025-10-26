/*
* FAQ:如何解决应用运行时OH_JSVM_CreateVM多线程创建发生竞争，导致VM内部的成员变量（array_buffer_allocator_）内存异常应用退出问题
*/

// [Start Js_MemoryException2]
std::unique_ptr<BackingStore> BackingStore::Allocate(
    Isolate* isolate, size_t byte_length, SharedFlag shared,
    InitializedFlag initialized) {
  ...
  auto allocator = isolate->array_buffer_allocator();
  ...
  auto allocate_buffer = [allocator, initialized](size_t byte_length) {
      if (initialized == InitializedFlag::kUninitialized) {
        return allocator->AllocateUninitialized(byte_length);
      }
      void* buffer_start = allocator->Allocate(byte_length);
      if (buffer_start) {
        // TODO(wasm): node does not implement the zero-initialization API.
        // Reenable this debug check when node does implement it properly.
        constexpr bool
            kDebugCheckZeroDisabledDueToNodeNotImplementingZeroInitAPI = true;
        if ((!(kDebugCheckZeroDisabledDueToNodeNotImplementingZeroInitAPI)) &&
            !v8_flags.mock_arraybuffer_allocator) {
          DebugCheckZero(buffer_start, byte_length);
        }
      }
      return buffer_start;
  };
  buffer_start = isolate->heap()->AllocateExternalBackingStore(
      allocate_buffer, byte_length);
  ...
}
// [End Js_MemoryException2]

// [Start Js_MemoryException3]
// Create an instance of JSVM.
const JSVM_CreateVMOptions* options = new JSVM_CreateVMOptions();
JSVM_Status res = USVM_OK;
{
  std::Lock_guard<std::mutex> Lock(create_jsym_mutex_);
  res = OH_JSVM_CreateVM(options, &vm_);
}
if (res != JSVM_OK vm_ == nullptr) {
  XLOG(ERROR) << "JSVM create vm failed";
}
// When we start, open vm scope.
// [End Js_MemoryException3]