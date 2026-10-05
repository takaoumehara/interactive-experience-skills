# Claude Code 用インストールプロンプト

スキルだけを入れるなら、プロンプトは不要。Claude Code で次の2行を実行するのが最も簡単:

```text
/plugin marketplace add takaoumehara/interactive-experience-skills
/plugin install interactive-experience-skills@interactive-experience
```

保守用の4コマンドも含めて `install.sh` で入れたい場合は、以下を Claude Code にそのまま貼り付ける（プラグインと両方で入れるとスキルが二重に読み込まれるので、どちらか一方にする）。

```text
次のリポジトリに含まれる3つの Agent Skill と付属コマンドを、このユーザーの Claude Code にインストールしてください。

Repository:
https://github.com/takaoumehara/interactive-experience-skills

要件:
- 一時ディレクトリへ main ブランチを clone または pull する。
- 実行前に LICENSE、install.sh、各 SKILL.md を確認する。
- リポジトリ付属の ./install.sh を実行する。
- 上書き対象は、このリポジトリと同名の3 Skillと4コマンドだけに限定する（既存の同名ファイルは install.sh が ~/.claude/backups/ へ退避する）。
- ~/.claude/skills/ の次の3ディレクトリを確認する:
  - embodied-product-director
  - interactive-experience-collective
  - movement-learning-system-designer
- ~/.claude/commands/ の motion-idea、refresh-skills、scout-skills、skills-routine を確認する。
- interactive-experience-collective/references/realtime-3d-pipeline.md が存在することを確認する。
- SKILL.md が参照する references/*.md と assets/*.md に参照切れがないことを確認する。
- 最後に、配置先、導入した version、検証結果、新しいセッションが必要かを報告する。
```

Claude.ai ではプロンプトによるローカル配置ではなく、`dist/*.zip` を **Customize → Skills → Upload a skill** からアップロードする。
