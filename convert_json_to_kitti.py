#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
ご自身のJSONラベル形式を、TAO PointPillarsが要求する
KITTI形式の .txt ラベルファイルに変換するスクリプトです。

根本原因であったクラス名の不一致 (例: "person" -> "Pedestrian") を
マッピングする機能が含まれています。
"""

import json
from pathlib import Path
import os
import time

# --- 1. 設定：ご自身の環境に合わせて★の3項目を編集してください ---

# ★ (A) ご自身のJSONラベルが保存されているディレクトリのパス
# (例: /home/demulab-kohei/tao_project/my_dataset_json/train)
JSON_DIR = Path("/workspace/data/follow_me/val/label")

# ★ (B) 変換後の.txtファイルを保存するディレクトリのパス
# (TAOが探す '.../training/label' の場所を指定します)
OUTPUT_DIR = Path("/workspace/data/follow_me/val/txt")

# ★ (C) クラス名のマッピング (ご自身のJSON -> TAOの期待する名前)
# これが RecursionError を解決する鍵となります。
CLASS_MAPPING = {
    "person": "Pedestrian",  # "person" を "Pedestrian" に変換
    # "car": "Car",          # (例) もし "car" というカテゴリがあれば
    # "bicycle": "Cyclist"   # (例)
}
# ---------------------------------------------------------

def convert_json_to_kitti_txt(json_path, output_path, class_mapping):
    """
    単一のJSONファイルを読み込み、KITTI形式の.txtファイルとして書き出す
    """
    try:
        with open(json_path, 'r') as f:
            data = json.load(f)
    except Exception as e:
        print(f"  [エラー] {json_path.name} の読み込みに失敗: {e}")
        return False

    output_lines = []
    
    # JSON内の各ラベルを処理
    for label in data.get("labels", []):
        
        # --- 1. カテゴリの抽出とマッピング ---
        original_category = label.get("category", "DontCare")
        # マッピング辞書を使ってカテゴリ名を変換
        # もしマッピングになければ、元の名前をそのまま使う
        mapped_category = class_mapping.get(original_category, original_category)

        # --- 2. 3Dボックス情報の抽出 ---
        box3d = label.get("box3d", {})
        
        # 寸法 (h, w, l)
        dim = box3d.get("dimension", {})
        h = dim.get("height", 0.0)
        w = dim.get("width", 0.0)
        l = dim.get("length", 0.0)
        
        # 位置 (x, y, z)
        loc = box3d.get("location", {})
        x = loc.get("x", 0.0)
        y = loc.get("y", 0.0)
        z = loc.get("z", 0.0)
        
        # 回転 (Yaw)
        orientation = box3d.get("orientation", {})
        ry = orientation.get("rotationYaw", 0.0)
        
        # --- 3. KITTI形式の16カラムを作成 ---
        # JSONに存在しない値は、KITTIの標準的なデフォルト値で埋めます
        
        line_data = [
            mapped_category,  # 1. type (★マッピング適用済み)
            0.0,              # 2. truncated (不明なため0)
            0,                # 3. occluded (不明なため0)
            -10.0,            # 4. alpha (観測角, 不明なため-10)
            0.0, 0.0, 0.0, 0.0, # 5-8. bbox (2D BBox, 不明なため0)
            h,                # 9. dim_h
            w,                # 10. dim_w
            l,                # 11. dim_l
            x,                # 12. loc_x
            y,                # 13. loc_y
            z,                # 14. loc_z
            ry,               # 15. rotation_y
            1.0               # 16. score (Ground Truthなので1.0)
        ]
        
        # すべての値を文字列に変換してスペースで連結
        output_lines.append(" ".join(map(str, line_data)))

    # 変換した内容を.txtファイルに書き込み
    try:
        with open(output_path, 'w') as f:
            f.write("\n".join(output_lines))
        return True
    except Exception as e:
        print(f"  [エラー] {output_path.name} の書き込みに失敗: {e}")
        return False

# --- メインの実行処理 ---
if __name__ == "__main__":
    # 出力ディレクトリが存在しない場合は作成
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    print(f"TAO PointPillars KITTI形式 変換スクリプト")
    print("-" * 40)
    print(f"入力 (JSON) : {JSON_DIR}")
    print(f"出力 (.txt)  : {OUTPUT_DIR}")
    print(f"マッピング   : {CLASS_MAPPING}")
    print("-" * 40)

    start_time = time.time()
    
    json_files = list(JSON_DIR.glob("*.json"))
    
    if not json_files:
        print(f"エラー: {JSON_DIR} に .json ファイルが見つかりません。")
        print("スクリプト上部の `JSON_DIR` のパスを確認してください。")
        exit()
        
    print(f"{len(json_files)} 件の .json ファイルを変換します...")
    
    success_count = 0
    for i, json_file_path in enumerate(json_files):
        # 出力ファイル名 (例: 000314.json -> 000314.txt)
        output_file_path = OUTPUT_DIR / json_file_path.with_suffix(".txt").name
        
        # 変換関数を呼び出し
        if convert_json_to_kitti_txt(json_file_path, output_file_path, CLASS_MAPPING):
            success_count += 1
        
        # 50ファイルごと、または最後だけ進捗を表示
        if (i + 1) % 50 == 0 or (i + 1) == len(json_files):
            print(f"  ... {i + 1}/{len(json_files)} 件処理完了")

    end_time = time.time()
    print("-" * 40)
    print(f"変換完了！ (成功: {success_count} / {len(json_files)} 件)")
    print(f"所要時間: {end_time - start_time:.2f} 秒")
