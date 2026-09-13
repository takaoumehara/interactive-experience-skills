# Babylon.js / Blender / Unreal Engine 知識監査

調査日: 2026-09-12

## 結論

不足していた。既存の `software.md` は TouchDesigner / Unreal / Three.js を候補として挙げていたが、次の判断を再現できなかった。

1. Babylon.js を Three.js とどう使い分けるか
2. Blender をランタイムではなく DCC / 資産の正本としてどう接続するか
3. Unreal の Live Link / Niagara / nDisplay / DMX / Remote Control / Pixel Streaming をどう役割分離するか
4. 3D 資産の圧縮、validation、fresh import をどこまで完成条件にするか
5. browser XR と大型会場で、それぞれどう劣化・同期・復旧を設計するか

このため、耐久性のある判断を `references/realtime-3d-pipeline.md` に昇格し、`SKILL.md` から条件付きで読むようにした。API カタログは Skill に複製せず、実装時の公式資料・専用 MCP / Skill に残す。

## 変更前の評価

| シナリオ | 変更前にできたこと | 欠けていたこと |
|---|---|---|
| Quest + smartphone の身体入力 WebXR | Babylon.js を候補にし、WebGPU / WebGL fallback を考えられる | Babylon 固有の一体型スタック、実機 matrix、粒子・物理・XR の劣化順 |
| Blender の rigged character 10体を Webへ | Three.js を選び、LOD / texture / animation を一般論で述べる | scene contract、post-process、glTF Validator、fresh import、magic number を避ける予算化 |
| Unreal の3面投影 + mocap + Niagara + lighting | nDisplay / Live Link / OSC / DMX の大枠は出る | cluster sync と genlock の分離、Niagara Data Channels、Remote Control、障害別 safe state |

変更前でもモデルの事前知識や Web 検索で補えたが、Skill 自体が判断を供給していなかった。これは再現性の欠陥である。

## 一次資料から吸収したもの

### Babylon.js

- [Babylon.js Specifications](https://www.babylonjs.com/specifications/) — WebGL / WebGPU、WebXR、Havok、GPU particles、glTF、audio、node editors を一体で扱う範囲。
- [Babylon.js 9.0 announcement](https://blogs.windows.com/windowsdeveloper/2026/03/26/announcing-babylon-js-9-0/) — Frame Graph、animation retargeting、Gaussian splats 等の現行方向。
- [WebGPU documentation source](https://github.com/BabylonJS/Documentation/blob/master/content/setup/support/webGPU.md) — WebGPU と WebGL を併存させる前提。
- [Havok physics documentation source](https://github.com/BabylonJS/Documentation/blob/master/content/features/featuresDeepDive/physics/v2/usingPhysicsEngine.md) — physics v2 / Havok の公式導線。

Skill へは「Babylon.js は Three.js の単なる代替ではなく、XR / physics / audio / asset / tooling を一つの runtime に寄せたい時の第一候補」という選定軸を昇格した。特定 minor version の API は昇格しなかった。

### Blender / glTF

- [Blender compatibility / LTS](https://developer.blender.org/docs/release_notes/compatibility/) — 自動 export は Blender LTS と Python API の版を固定する。
- [Khronos glTF-Blender-IO](https://github.com/KhronosGroup/glTF-Blender-IO) — Blender 組み込み exporter の正本。
- [glTF 2.0 specification](https://github.com/KhronosGroup/glTF/blob/main/specification/2.0/Specification.adoc) / [glTF Validator](https://github.com/KhronosGroup/glTF-Validator) — format と validation の正本。
- [meshoptimizer / gltfpack](https://github.com/zeux/meshoptimizer) — geometry / animation / quantization / pruning の post-process。
- [KTX 2.0 specification](https://github.khronos.org/KTX-Specification/ktxspec.v2.html) — GPU texture container / compression の正本。

Skill へは `.blend → deterministic export → post-process → validator → fresh import` の契約を昇格した。一律の「5MB以下」「5万 polygon以下」「textureは2K」のような数字は、対象機・材質・骨・画面占有率を無視するため昇格しなかった。

### Unreal Engine

- [nDisplay overview](https://dev.epicgames.com/documentation/en-us/unreal-engine/ndisplay-overview-for-unreal-engine) / [nDisplay synchronization](https://dev.epicgames.com/documentation/en-us/unreal-engine/synchronization-in-ndisplay-in-unreal-engine) — cluster rendering と sync の範囲。
- [Live Link](https://dev.epicgames.com/documentation/en-us/unreal-engine/live-link-in-unreal-engine) — mocap / camera / animation data ingress。
- [Niagara Data Channels](https://dev.epicgames.com/documentation/en-us/unreal-engine/data-channels-in-niagara-for-unreal-engine) — game code と Niagara、Niagara system 間のデータ共有。
- [OSC plugin](https://dev.epicgames.com/documentation/en-us/unreal-engine/osc-plugin-overview-for-unreal-engine) / [Remote Control](https://dev.epicgames.com/documentation/en-us/unreal-engine/remote-control-for-unreal-engine) — scalar / event / operator control。
- [DMX quick start](https://dev.epicgames.com/documentation/en-us/unreal-engine/dmx-quick-start-in-unreal-engine) — lighting connection。
- [Pixel Streaming](https://dev.epicgames.com/documentation/en-us/unreal-engine/pixel-streaming-in-unreal-engine) — Unreal を GPU host で実行し browser へ届ける構成。

Skill へは各系統の責務分離、time source / cluster sync / physical display sync の3層、sensor・process・node・network 別の failover を昇格した。

## `designskill-main` から吸収したもの

対象:
`/Users/takao/Documents/00_Product_Develpment/00_SKILL_CREATION/somebodyelse-skill/designskill-main`

MIT license を確認した上で、次を調査した。

| 元 Skill | 吸収した判断 | 吸収しなかったもの |
|---|---|---|
| `babylonjs-engine` | WebXR、Havok、Node Material、GPU particles、glTF、thin instances、LOD、adaptive render scale、instrumentation | Babylon.js 7.x 前提の API 断片 |
| `blender-web-pipeline` | collection export、bpy batch、bake、LOD、PBR、pre/post export check | 一律の容量・polygon 上限、版依存の bpy 操作 |
| `web3d-integration-patterns` | render / UI / state loop の分離、同一 property の複数所有を避ける、cleanup | React marketing site に偏った構成 |
| `playcanvas-engine` | editor-centric team workflow という選定軸 | engine API の網羅 |
| `substance-3d-texturing` | ORM packing、sRGB / linear、normal map、KTX2 / Basis の論点 | 特定 tool 操作の手順 |
| `threejs-webgl` / `aframe-webxr` / `lightweight-3d-effects` | custom renderer、declarative XR、軽量表現の比較軸 | 既存 `software.md` と重複する API 例 |

文章やコードを大量に複製せず、判断を再構成した。現行性は公式一次資料を優先した。

## 見つかった専用 Skill / 補助ツール

| 候補 | 種類 | 向く用途 | 今回の扱い |
|---|---|---|---|
| [EpicGames/unreal-engine-skills-for-claude-code-plugin](https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin) | 公式 Unreal Skill + MCP | actor、Blueprint、material、Niagara、Sequencer 等を live editor で操作 | Companion として推奨。設計 Skill には操作手順を複製しない |
| [immersiveidea/babylon-mcp](https://github.com/immersiveidea/babylon-mcp) | Babylon docs / API / source の semantic search | 実装時の現行 API 確認 | Companion 候補。索引構築が重いため自動導入しない |
| [ifBars/blender-agent-studio](https://github.com/ifBars/blender-agent-studio) | Blender 制作 Skill 群 | modeling、animation、procedural scene、render、検証 | deterministic Python と visual evidence の考え方を吸収。大規模なため丸ごと統合しない |
| [elithril/blender-kiln](https://github.com/elithril/blender-kiln) | Blender → GLB production pipeline | export、validation、gltf-transform / gltfpack | production validation の参考。現行 repo へ依存を追加しない |
| [kevinpbuckley/unreal-engine-skills](https://github.com/kevinpbuckley/unreal-engine-skills) | Community Unreal knowledge skills | UE source と結びついた詳細調査 | 公式 plugin を優先し、補助資料としてのみ扱う |

これらは「設計判断をする Skill」ではなく「実装・操作を正確に進める Companion」が中心である。今回の Skill に全量を入れると、必要な判断が API 手順に埋もれる。そのため、有用な原則は吸収し、外部 runtime / editor を実際に操作する段階でだけ追加導入する方針とした。

## Skill へ反映済み

| 内容 | 反映先 |
|---|---|
| 発火語・条件付き routing | `interactive-experience-collective/SKILL.md` |
| Babylon / Blender / Unreal の選定と接続 | `references/realtime-3d-pipeline.md` |
| Web engine 選定表、nDisplay 同期、性能予算の修正 | `references/software.md` |
| 回帰評価3件 | `evals/evals.json` |

## 今後の更新ルール

- 製品版・API 名・browser / device 対応は回答時に公式資料で再確認する。
- Babylon / Unreal の API 例は Skill に蓄積せず、公式 docs または専用 MCP へ委譲する。
- Blender pipeline の数値は target hardware の計測結果として案件側に置き、普遍則として Skill へ戻さない。
- 新しい engine を追加する時は、既存 engine と違う判断を可能にするか、どの記述を置換するかを先に示す。
