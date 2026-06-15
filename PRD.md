# ModFactory 详细需求文档 V1.0

> Status: This is an early product requirements document. The current source of truth is the platform-neutral `core/` playbook plus thin runtime adapters under `adapters/`.

## 1. 项目概述

### 1.1 项目定位
- **全称**: ModFactory
- **类型**: 平台无关的 Minecraft game-experience factory，Claude Code/Cursor/通用 Agent 通过 adapters 接入
- **核心定位**: 模块化、契约驱动、渐进式 MC 模组与整合包生产工具链
- **区别于 CreativeMode**: 输出完整可编辑源码，非黑盒一键出包

### 1.2 核心架构
```
core/ 平台无关 playbook + adapters/ 运行时适配器 + skills/ 专家实现 + templates/scripts 工具链
```

### 1.3 核心差异化
- 输出完整可编译源码（Java/JSON/PNG/工程结构）
- 模块化工具解耦：纹理、物品、玩法、实体可单独使用
- 总Skill全局调度，一句话自动拆解复杂需求
- 核心流程不绑定单一 Agent 平台，可通过薄适配器本地加载、复用、开源分发

## 2. 架构设计

### 2.1 架构模式
平台无关核心（core）+ 平台适配层（adapters）+ 主控调度层（mc-mod-master 等入口）+ 专家模块/资产服务/工程实现/QA Gates

### 2.2 目录结构
```
modfactory/
├── core/               (平台无关定位、架构、契约、工作流、专家注册表)
├── adapters/           (Cursor / Claude Code / Generic Agent 薄适配器)
├── skills/
│   ├── mc-mod-master/SKILL.md
│   ├── texture-generator/SKILL.md
│   ├── item-generator/SKILL.md
│   ├── block-generator/SKILL.md
│   ├── entity-generator/SKILL.md
│   └── gameplay-generator/SKILL.md
├── templates/fabric/   (Fabric 1.21+ 代码模板)
├── scripts/            (辅助脚本)
└── README.md
```

## 3. Skills 详细定义

### 3.1 mc-mod-master (总控)
触发: `/mc-mod-master` 或自动识别Mod开发需求
输入: 自然语言需求描述
输出: 完整可编译Mod工程
能力: 需求解析 → 任务拆解 → 子Skill调度 → 文件合并 → 校验

### 3.2 texture-generator (纹理生成)
输入: 类型/风格/色调/光效/尺寸
输出: PNG纹理 + 模型JSON引用路径
依赖: GearFactory引擎 (palettes.json + forge.ps1)

### 3.3 item-generator (物品生成)
支持: 剑/斧/镐/弓/食物/特殊道具
输出: Java源码 + 配方JSON + 模型JSON + 注册代码

### 3.4 block-generator (方块生成)
支持: 自定义硬度/光照/掉落物/碰撞箱
输出: 方块类 + 状态JSON + 模型JSON + 注册代码

### 3.5 entity-generator (实体生成)
支持: 怪物/Boss/宠物/坐骑
输出: 实体类 + 渲染配置 + 战利品表 + 生成规则

### 3.6 gameplay-generator (玩法系统)
支持: 技能系统/职业属性/任务成就/经济商店/buff系统
输出: 事件监听 + 数据存储 + UI + 逻辑代码

## 4. 用户角色

| 角色 | 需求 | 对标 |
|------|------|------|
| 轻度用户 | 一句话生成简单模组 | CreativeMode体验 |
| 中度用户 | 快速模板、学习标准注册 | 新手友好 |
| 专业用户 | 批量样板代码、玩法系统原型 | 开发效率 |

## 5. 竞品对比

| 能力 | CreativeMode | 普通LLM | 本插件 |
|------|-------------|---------|--------|
| 输出完整源码 | ❌ | ❌ | ✅ |
| 玩法系统生成 | ❌ | ❌ | ✅ |
| 模块化工具 | ❌ | ❌ | ✅ |
| 总控流程调度 | ❌ | ❌ | ✅ |
| 专业开发可用 | ❌ | ⚠️ | ✅ |

## 6. 迭代计划

| 阶段 | 内容 |
|------|------|
| Phase 1 | 插件骨架 + 总控Skill + 核心小工具(item/block/texture) |
| Phase 2 | 高阶工具(entity/gameplay) + 总控联动 |
| Phase 3 | MCP协议对接 + 智能体全自动化 + 报错自愈 |
