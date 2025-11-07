<?php
header("Content-Type: application/json; charset=utf-8");

$json_file = 'data.json';

// ↓data.jsonを読み込む関数
function load_data($json_file) {
    if (!file_exists($json_file)) return [];
    $json = file_get_contents($json_file);
    return json_decode($json, true) ?? [];
}

// ↓data.jsonを書き込む関数
function save_data($json_file, $data) {
    file_put_contents($json_file, json_encode($data, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT));
}

// ↓POSTデータ(json)を取得
$input = json_decode(file_get_contents('php://input'), true);
if (!$input) {
    http_response_code(400);
    echo json_encode(["error" => "invalid JSON"], JSON_UNESCAPED_UNICODE);
    exit;
}

$barcode = $input['barcode'];
$product = $input['product'];
$comment_text = $input['comment'];
$rating = $input['rating'];
$latitude = $input['latitude'];
$longitude = $input['longitude'];

$json_data = load_data($json_file);

// ↓既存バーコードを探す
foreach ($json_data as &$item) {
    if ($item['barcode'] === $barcode) {
        $item['comment'][] = [
            "comment" => $comment_text,
            "rating" => $rating,
            "latitude" => $latitude,
            "longitude" => $longitude
        ];
        save_data($json_file, $json_data);
        echo json_encode(["message" => "コメント＋座標を追加"], JSON_UNESCAPED_UNICODE);
        exit;
    }
}

// ↓新規作成
$new_barcode = [
    "barcode" => $barcode,
    "product" => $product,
    "comment" => [[
        "comment" => $comment_text,
        "rating" => $rating,
        "latitude" => $latitude,
        "longitude" => $longitude
    ]]
];

$json_data[] = $new_barcode;
save_data($json_file, $json_data);

echo json_encode(["message" => "新しいバーコードを登録,コメント＋座標を保存"], JSON_UNESCAPED_UNICODE);
?>
