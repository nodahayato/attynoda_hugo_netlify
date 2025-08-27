#!/bin/bash

# 内容ベースで移植済みファイルをチェックするスクリプト

echo "=== 内容ベースでの移植済みファイルチェック開始 ==="

# Obsidianの全mdファイルを取得（接頭辞付きは除外）
find obsidian -name "*.md" -type f | grep -v "\[移植済み\]" | while read obsidian_file; do
    echo "チェック中: $obsidian_file"
    
    # ファイルの最初の数行を取得して特徴的な内容を抽出
    first_lines=$(head -5 "$obsidian_file" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g')
    
    # 特徴的なフレーズを抽出（最初の10文字程度）
    if [ -n "$first_lines" ]; then
        # 最初の非空行から特徴的なフレーズを取得
        key_phrase=$(echo "$first_lines" | sed 's/^[[:space:]]*//' | cut -c1-20)
        
        # postsディレクトリで同じ内容を検索
        if grep -r "$key_phrase" content/posts/ > /dev/null 2>&1; then
            echo "  ✓ 移植済み: $obsidian_file"
            # 接頭辞を付けてリネーム
            dir=$(dirname "$obsidian_file")
            filename=$(basename "$obsidian_file")
            mv "$obsidian_file" "$dir/[移植済み]$filename"
        else
            echo "  ✗ 未移植: $obsidian_file"
        fi
    fi
done

echo "=== チェック完了 ==="
