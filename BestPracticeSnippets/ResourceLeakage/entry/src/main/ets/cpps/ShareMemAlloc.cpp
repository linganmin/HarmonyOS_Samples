// [Start share_mem_alloc]
// Take EXT RawData memory as an example
const static string EXT_SHAREMEM_NAME = "EXT RawData";

static uint32_t ShareMemAlloc(DecodeContext &context, uint64_t count)
{
    ...
    auto fd = make_unique<int32_t>();
    *fd = AshmemCreate(EXT_SHAREMEM_NAME.c_str(), count);
    ...
}
// [End share_mem_alloc]