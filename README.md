[このゲーム、先手が有利？後手が有利？](http://qiita.com/h_hiro_/items/eaa640c89f001ead9f50)というのがあったので、
ちょっとやってみました。

## ゲームのルール

* 2人対戦
* 1～5のカードが3枚ずつ15枚のカードでプレイする
* 各プレイヤーに7枚ずつランダムに配り、1枚は伏せておく
* いずれかのプレイヤーから順番に1枚ずつ場に出していく
* いずれかの数字の3枚目を出したプレイヤーに即座に1点  
* 1枚欠けのカードは、2枚目のカードを切ったプレイヤーに1点  
  ただし、この点数は互いの手札がなくなって決着がつかなかった場合に得られるものとする
* 3点を先取したプレイヤーの勝利

## AIの仕様

要約：先読みはせず自分の手札と場の捨て札のみで判断する単細胞AI

自分の手札と場の捨て札を見て、以下の順に優先してカードを切る。

* 全体で3枚見えているカード
* 手札に2枚あるうちの1枚目
* 手札に1枚しかなく、場にまだ出ていないカード
* 手札に2枚あったうちの2枚目
* 手札に1枚あり、かつ相手の捨て札に1枚切れているカード

## プログラムの仕様

* AIとAIの対戦を任意の回数（デフォルト100回）行わせ、その結果（勝利数の累計）を最後に表示する
