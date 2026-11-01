# MoonPDB 项目申报书
## 基本信息
- 项目名称：MoonPDB
- 参赛者：LC6543
- 邮箱：2735527267@qq.com
- GitHub：https://github.com/LC6543
- 仓库：https://github.com/LC6543/moonpdb
- Mooncakes：LC6543/moonpdb
- 项目方向：语言和开发工具 / 调试信息与二进制基础设施
- 许可证：Apache-2.0
## 最终目标
MoonPDB 的目标是纯 MoonBit、只读、资源有界的完整 Microsoft PDB 7.0 核心读取器。
合法 PDB 的 MSF、PDB Info、TPI/IPI、DBI、模块流、public/global 符号、CodeView
符号和行号流均可定位和有界读取；支持的记录给出类型化语义，未知记录保留原始字节。
项目面向 CI、崩溃分析、构建审计和调试工具，是新工程，不重复已有 DWARF/ELF 项目。
## 已完成的现有基础
- 当前有效源码约 10,200 行、测试约 2,700 行；`moon check --deny-warn` 和
  `moon test --deny-warn` 通过，现有 63 个测试。
- 已配置 GitHub Actions、Apache-2.0、README、安全策略、贡献指南和版本记录。
## 本轮已完成的验收范围
- TPI/IPI：类型头、索引、simple/common records，以及 FIELDLIST 成员和 `LF_INDEX` 连续链。
- DBI：模块、section contributions/map、文件信息、EC、类型服务器和可选调试流索引。
- 符号：模块流及 `S_PUB32`、`S_GDATA32`、`S_LDATA32`、`S_GPROC32`、`S_LPROC32`、
  thunk/block/label、constant/UDT/procref/frameproc 等记录；Publics、GSI 和 Globals 查询。
- C13：子段、模块 StringTable、全局 `/names`、文件校验和、行/列记录和源码定位。
- 符号化：PE32/PE32+ image base、section table、segment+offset 到 RVA/VA，并合并 public 与源码行。
- CLI：PDB summary/modules/types/symbols/publics/find，以及匹配 PE+PDB 的 address 命令。
- 互操作：固定 LLVM 真实 PDB/PE、带 SHA-256/许可证的自生成匹配 PE/PDB、集成测试和 CI。
## 边界
不做 PDB 写入、反汇编、反编译、调试器 UI、符号服务器认证或完整 ELF/DWARF/Mach-O/PE 解析器；
不宣称寄存器、局部变量、栈回溯、内联帧展开。格式资料来自 Microsoft `microsoft-pdb` 和 LLVM。
