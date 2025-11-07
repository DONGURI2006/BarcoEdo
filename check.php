<?php
header("Content-Type: application/json; charset=utf-8");

$json_file = 'data.json';

// ↓data.jsonを読み込む関数
function load_data($json_file) {
    if (!file_exists($json_file)) return [];
    $json = file_get_contents($json_file);
    return json_decode($json, true) ?? [];
}

// ↓ barcode を取得
if (!isset($_GET['barcode']) || $_GET['barcode'] === '') {
    http_response_code(400);
    echo json_encode(["error" => "barcode parameter is required"], JSON_UNESCAPED_UNICODE);
    exit;
}

$barcode = $_GET['barcode'];
$data = load_data($json_file);

// ↓バーコードを検索
foreach ($data as $item) {
    if ($item['barcode'] === $barcode) {
        echo json_encode([
            "exists" => true,
            "product" => $item['product'],
            "comments" => $item['comment']
        ], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
        exit;
    }
}

// ↓見つからない場合
echo json_encode(["exists" => false], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
?>
