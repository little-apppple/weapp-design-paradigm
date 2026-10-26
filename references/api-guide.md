# 适配相关 API 字段速查

## wx.getWindowInfo()（基础库 2.20.1+，替代 getSystemInfoSync 的窗口部分）

| 字段 | 说明 | 用途 |
|------|------|------|
| pixelRatio | 设备像素比 | canvas 高清绘制 |
| screenWidth / screenHeight | 屏幕宽高 px | 安全区计算 |
| windowWidth / windowHeight | 可使用窗口宽高 px | 布局计算、rpx2px |
| statusBarHeight | 状态栏高度 px | 自定义导航栏 |
| safeArea | {top,bottom,left,right,width,height} 安全区 | 顶部预留/底部避让；**部分机型不返回，需判空** |
| screenTop | 窗口上边缘的 y 值 | 特殊窗口模式定位 |

关键关系：
- `底部安全距离 = screenHeight - safeArea.bottom`
- `safeArea` 可能不存在 → 必须先判空再取，否则报错
- **`safeAreaInsets` 不是 `getWindowInfo` 字段**，仅旧 `getSystemInfoSync` 返回，新 API 不要再读它

## wx.getMenuButtonBoundingClientRect()（基础库 2.1.0+）

返回胶囊按钮布局位置，坐标以屏幕左上角为原点：

```
{ width: 87, height: 32, left: 281, right: 368, top: 48, bottom: 80 }
```

| 字段 | 含义 |
|------|------|
| top | 上边界距屏幕顶部（已含状态栏高度） |
| bottom | 下边界距屏幕顶部 |
| left / right | 距屏幕左侧 |
| width / height | 胶囊尺寸 |

**已知坑：**
1. iOS 偶发返回全 0 → 必须写降级分支
2. 开发者工具与真机有差异 → 以真机为准
3. iPad 横屏/分屏下返回估算值 → onResize 中重新获取
4. 坐标系是屏幕原点，不是窗口原点 → 不要与窗口内坐标混算

## 核心推导公式

```
gap             = menu.top - win.statusBarHeight      // 胶囊上下间距（对称）
navBarHeight    = menu.bottom + gap                   // 状态栏+标题栏总高
contentRightPad = win.screenWidth - menu.left         // 标题避让宽度
menuRight       = win.screenWidth - menu.right        // 胶囊距右
safeBottom      = win.safeArea ? win.screenHeight - win.safeArea.bottom : 0
```

> `safeArea` 缺失时（部分安卓/PC 窗口）按 0 处理，并可用 CSS `env(safe-area-inset-bottom)` 兜底。

## wx.getDeviceInfo()（2.20.1+）

| 字段 | 用途 |
|------|------|
| system | 如 "iOS 16.5" / "Android 13"，判断平台 |
| platform | ios / android / windows / mac / devtools |
| model | 机型判断（兜底匹配 iPhone X 系列） |

## wx.getAppBaseInfo()（2.20.1+）

| 字段 | 用途 |
|------|------|
| SDKVersion | 基础库版本，API 能力判断 |
| theme | light / dark，暗黑模式适配 |

## 降级策略（老基础库 < 2.20.1）

```js
function getWindowInfoSafe() {
  if (wx.getWindowInfo) return wx.getWindowInfo()
  // 老基础库兜底
  const si = wx.getSystemInfoSync()
  return {
    screenWidth: si.screenWidth, screenHeight: si.screenHeight,
    windowWidth: si.windowWidth, windowHeight: si.windowHeight,
    statusBarHeight: si.statusBarHeight,
    safeArea: si.safeArea, safeAreaInsets: si.safeAreaInsets,
    pixelRatio: si.pixelRatio
  }
}
```

## 关键配置项

| 配置 | 位置 | 作用 |
|------|------|------|
| `"navigationStyle": "custom"` | 页面/全局 json | 隐藏原生导航栏（胶囊不会消失） |
| `"resizable": true` | app.json | iPad 支持屏幕旋转；PC 可任意拖拽/最大化窗口；大屏模式（2.21.3+）。默认关闭 |
| `"pageOrientation": "auto"` | 页面/全局 json | 跟随旋转（2.4.0+） |
| `"pageOrientation": "landscape"` | 页面/全局 json | 固定横屏（2.5.0+） |
| `"convertRpxToVw": true` | app.json | rpx 转 vw，修复精度问题（3.3.0+） |
| `"renderer": "skyline"` | 页面 json | Skyline 渲染（安全区处理另有差异，需真机验证） |
| `wx.onWindowResize` / 页面 `onResize` | js | 窗口尺寸变化重算（官方更推荐 `onResize`） |

## Skyline 渲染差异提示

页面启用 Skyline 后：默认无导航栏概念、rpx 行为一致但部分 CSS 不支持、env() 安全区变量支持有限，需改用 `wx.getWindowInfo().safeArea` 动态计算。开发前确认目标基础库（Skyline 需 2.29.2+ 且在后台开通）。
