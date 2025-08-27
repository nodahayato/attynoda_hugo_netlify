#!/bin/bash

# Obsidianファイルの移植状況をチェックして接頭辞を付けるスクリプト

echo "=== 移植済みファイルのチェック開始 ==="

# Obsidianの全mdファイルを取得
find obsidian -name "*.md" -type f | while read obsidian_file; do
    # ファイル名から拡張子を除く
    filename=$(basename "$obsidian_file" .md)
    
    # 既に接頭辞が付いている場合はスキップ
    if [[ "$filename" == "[移植済み]"* ]]; then
        echo "スキップ: $obsidian_file (既に接頭辞付き)"
        continue
    fi
    
    # postsディレクトリで同じタイトルのファイルを検索
    if grep -r "title: \"$filename\"" content/posts/ > /dev/null 2>&1; then
        echo "移植済み: $obsidian_file"
        # 接頭辞を付けてリネーム
        dir=$(dirname "$obsidian_file")
        mv "$obsidian_file" "$dir/[移植済み]$filename.md"
    else
        echo "未移植: $obsidian_file"
    fi
done

echo "=== チェック完了 ==="
