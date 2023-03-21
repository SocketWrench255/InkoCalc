extends Node2D
# extends Node
export(PackedScene) var MemoryPict

# 画面サイズ
const SCREEN_SIZE_X = 720
const SCREEN_SIZE_Y = 1280

# キャラクタの絵リスト
enum Inko {KOZAKURA, BOTAN, KURUMASAKA, MOMOIRO, OBATAN, OKAME, OKINA, SEKISEI, SHIROHARA, TAIHAKU, YOUMU}
var CharaList = []
var InkoList = []

const CALC_LIST = ["+","-","×"]
var ResultList = []
var SuccessList = []

var Score = 0

#ゲーム開始フラグ
var GameStartFlag = false
#問題出題フラグ
var QuestionFlag = true

#ゲーム時間のカウント60秒
var GameTimeCount = 60

#スコア表示カウント
var ScoreShowCount = 0

#サーバー設定値
var userid = 0
var geturl ="http://pomepavi.sakura.ne.jp/database/inkocalc/rank/get_userid.php"

# Called when the node enters the scene tree for the first time.
func _ready():
	# HTTPリクエストを作成する
	$HTTPRequest2.request(geturl)	
	$BGM.play()
	pass # Replace with function body.

# プロセス	
func _process(_delta):
	if GameStartFlag :
		#解く問題がない
		if QuestionFlag :
			QuestionFlag = false
			#問題文の作成
			CreateQuestion()
			DisplayResultButtton()
			#print("_process(CharaList)",CharaList)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#Resultクラスの作成
#var Result = [FLAG,ERORR,ITEM,MESSAGE]
enum Result {FLAG,ERORR,ITEM,MESSAGE}

# スタートボタンを押す
func _on_StartButton_button_down():
	QuestionFlag = false
	#シード値を変更　これやらないと毎回同じ乱数になる
	randomize()
	
	# ゲーム初期状態に戻す
	GameTimeCount = 60
	Score = 0
	$sec60Label.text = str(GameTimeCount)
	$ScoreLabel.text = str(Score)
	$LastScoreLabel.text = str(Score)
	
	# 数字に各絵をランダムに割り当てる。数字はIndex使う。
	CharaList = [Inko.KOZAKURA, Inko.BOTAN, Inko.KURUMASAKA, Inko.MOMOIRO, Inko.OBATAN, Inko.OKAME, Inko.OKINA, Inko.SEKISEI, Inko.SHIROHARA, Inko.TAIHAKU, Inko.YOUMU]
	CharaList.shuffle()
	InkoList = ["KOZAKURA", "BOTAN", "KURUMASAKA", "MOMOIRO", "OBATAN", "OKAME", "OKINA", "SEKISEI", "SHIROHARA", "TAIHAKU", "YOUMU"]
	#print("StartButton:CharaList",CharaList)
	#print("StartButton:InkoList",InkoList)
	
	# 記憶画像の表示
	DisplayMemoryPict()
	
	# ゲーム画面にカメラを移動する
	$Position2D.position.x += SCREEN_SIZE_X
	
	#ゲーム開始
	QuestionFlag = true
	GameStartFlag = true
	$QuestionTimer.start()
	
	pass # Replace with function body.

# 記憶画像を表示する
func DisplayMemoryPict():
	$MemoryPict0/Sprite/AnimatedSprite.frame = CharaList[0]
	$MemoryPict1/Sprite/AnimatedSprite.frame = CharaList[1]
	$MemoryPict2/Sprite/AnimatedSprite.frame = CharaList[2]
	$MemoryPict3/Sprite/AnimatedSprite.frame = CharaList[3]
	$MemoryPict4/Sprite/AnimatedSprite.frame = CharaList[4]
	$MemoryPict5/Sprite/AnimatedSprite.frame = CharaList[5]
	$MemoryPict6/Sprite/AnimatedSprite.frame = CharaList[6]
	$MemoryPict7/Sprite/AnimatedSprite.frame = CharaList[7]
	$MemoryPict8/Sprite/AnimatedSprite.frame = CharaList[8]
	$MemoryPict9/Sprite/AnimatedSprite.frame = CharaList[9]
	$MemoryPict10/Sprite/AnimatedSprite.frame = CharaList[10]
	pass # Replace with function body.

# 問題文を作成する
func CreateQuestion():
	#print("CreateQuestion:CharaList",CharaList)
	# 乱数の初期化
	randomize()
	# 計算式の作成
	var Calc = randi() % CALC_LIST.size()
	var i = randi() % CharaList.size()
	while i == 10 :
		i = randi() % CharaList.size()
	#print("i",i)
	randomize()
	var k = randi() % CharaList.size()
	while k == 10 :
		k = randi() % CharaList.size()
	#print("k",k)
	#print("CreateQuestion（計算式1）",i,CALC_LIST[Calc],k)
	#print("CreateQuestion（計算式2）",InkoList[CharaList[i]],CALC_LIST[Calc],InkoList[CharaList[k]])
	
	# 計算する
	Result.FLAG = true
	var result = CalcResult(i,k,Calc)
	#print("CreateQuestion（Result）")
	Result.ITEM = result
	
	# 問題文を表示する Calc i k
	DisplayQuestion(CharaList[i],CharaList[k],CALC_LIST[Calc])
	
	return(Result)
	pass # Replace with function body.

# 問題文を表示する
func DisplayQuestion(i,k,string):
	$CalcPict/Sprite/AnimatedSprite.frame = i
	$CalcPict/CalcLabel.text = str(string)
	$CalcPict/Sprite2/AnimatedSprite2.frame = k
	pass # Replace with function body.

# 回答ボタン表示する
func DisplayResultButtton():
	#print("DisplayResultButtton",CharaList)
	# 文字列化する
	var strResult = str(Result.ITEM)
	# 正解リストに入れる
	SuccessList = strResult
	# ランダムな数字を5文字追加
	randomize()
	for _x in range(5):
		var random = randi() % 10
		strResult += str(random)
		#print("strResult",strResult)
	# 5文字にする 1文字に分割
	ResultList = [strResult[0],strResult[1],strResult[2],strResult[3],strResult[4]]
	#print("回答パネル配列",ResultList)
	# シャッフル
	randomize()
	ResultList.shuffle()
	#print(ResultList)
	# 数字にする # 画像に割り当て
	# マイナスを10にする　配列化
	for y in range (ResultList.size()):
		if ResultList[y] == "-" :
			ResultList[y] = "10"
	#print ("DisplayResultButtton",ResultList)
	$ResultButton/AnimatedSprite.frame = CharaList[ResultList[0].to_int()]
	$ResultButton2/AnimatedSprite.frame = CharaList[ResultList[1].to_int()]
	$ResultButton3/AnimatedSprite.frame = CharaList[ResultList[2].to_int()]
	$ResultButton4/AnimatedSprite.frame = CharaList[ResultList[3].to_int()]
	$ResultButton5/AnimatedSprite.frame = CharaList[ResultList[4].to_int()]
	
	pass # Replace with function body.

# 計算する関数の作成
func CalcResult(i,k,Calc):
	var result = 0
	if Calc == 0 :
		result = AddCalc(i,k)
	if Calc == 1 :
		result = SubtractCalc(i,k)
	if Calc == 2 :
		result = MultiplyCalc(i,k)
#	if Calc == 3 :
#		DivideCalc(i,k)
	# print ("CalcResult（計算の答え）",result)
	return (result)
	pass # Replace with function body.

# 足し算
func AddCalc(i,k):
	var result = i + k
	# print ("AddCalc(足し算の答え)",result)
	return (result)
	pass # Replace with function body.

# 引き算
func SubtractCalc(i,k):
	var result = i - k
	# print ("SubtractCalc(引き算の答え)",result)
	return (result)
	pass # Replace with function body.

# 掛け算
func MultiplyCalc(i,k):
	var result = i * k
	# print ("MultiplyCalc(掛け算の答え)",result)
	return (result)
	pass # Replace with function body.

# 割り算
#func DivideCalc(i,k):
#	var result = i / k
#	print(result)
#	pass # Replace with function body.

# ゲームカウント
func _on_QuestionTimer_timeout():
	#ゲーム時間を作成する
	GameTimeCount = GameTimeCount-1
	$sec60Label.text = str(GameTimeCount)
	
	# print(GameTimeCount)
	# 60秒経過後
	if GameTimeCount <= 0 :
		EndGame()
		
	pass # Replace with function body.

# ゲーム終了したとき
func EndGame():
	$StartButton.disabled = true
	GameStartFlag = false
	$QuestionTimer.stop()
	#画面の移動
	$Position2D.position.x -= SCREEN_SIZE_X
	var username = $UserName.text
	var send = str(Score)
	# HTTPリクエストを送信するためのデータを定義する
	var url ="http://pomepavi.sakura.ne.jp/database/inkocalc/rank/index.php"
	var data_to_send = {"userid":userid,"username":username,"score":send}
	var query = JSON.print(data_to_send)
	print("query",query)
	var headers = ["Content-Type: application/json"]
	# HTTPリクエストを作成する
	$HTTPRequest.request(url, headers, true, HTTPClient.METHOD_POST, query)
	#var data = {"username": "pomepavi", "password": "Pome65535"}

	#スコアを送信する
	#JavaScript.eval("window.RPGAtsumaru.scoreboards.setRecord(1, " + send + ")")
	ScoreShowCount = 0
	$ScoreShowTimer.start()
		
	pass # Replace with function body.

# 回答ボタン１を押したとき
func _on_ResultButton_button_up():
	#print("回答ボタン１押下",ResultList[0],"回答",SuccessList)
	answerVerification(ResultList[0],"ResultButton")
	pass # Replace with function body.

func _on_ResultButton2_button_up():
	#print("回答ボタン2押下",ResultList[1],"回答",SuccessList)
	answerVerification(ResultList[1],"ResultButton2")
	pass # Replace with function body.

func _on_ResultButton3_button_up():
	#print("回答ボタン3押下",ResultList[2],"回答",SuccessList)
	answerVerification(ResultList[2],"ResultButton3")
	pass # Replace with function body.

func _on_ResultButton4_button_up():
	#print("回答ボタン4押下",ResultList[3],"回答",SuccessList)
	answerVerification(ResultList[3],"ResultButton4")
	pass # Replace with function body.

func _on_ResultButton5_button_up():
	#print("回答ボタン5押下",ResultList[4],"回答",SuccessList)
	answerVerification(ResultList[4],"ResultButton5")
	pass # Replace with function body.

# 正解を照合する
func answerVerification(answer,ButtonName):
	#print("answerVerification:ResultList",ResultList)
	# 10をマイナスに戻す
	var strAnswer = str(answer)
	#print("answerVerification:answer",strAnswer)
	if answer == "10" :
		strAnswer = "-"
	#print("answerVerification:ResultList2",ResultList)
	#print("answerVerification:SuccessList[0]",SuccessList[0])
	#print("answerVerification:answer",strAnswer)
	# 正解か不正解か確認する
	if SuccessList[0] == strAnswer :
		#print("SuccessList",SuccessList,"len(SuccessList)",len(SuccessList))
		if len(SuccessList) >= 2 :
			SuccessList = SuccessList.substr(1,-1)
			#print("SuccessList",SuccessList)
			RightAnswer(0,ButtonName)
		else :
			RightAnswer(0,ButtonName)
			# 問題フラグ
			QuestionFlag = true
	else :
		RightAnswer(1,ButtonName)
		QuestionFlag = true
		#print("不正解")
	pass # Replace with function body.

# 答えの表示を消すタイマー
func _on_AnswerTimer_timeout():
	$AnswerMark.visible = false
	$AnswerTimer.stop()
	pass # Replace with function body.
	
# 正解の時の処理
func RightAnswer(answer,ButtonName):
	# 正解を表示する場所を探す
	var name = get_node(ButtonName)
	#print(name)
	$AnswerMark.position = name.rect_position + (name.rect_size / 2)
	# 正解を表示する
	if answer == 0:
		GameTimeCount += 2
		Score += 100
		$sec60Label.text = str(GameTimeCount)
		$ScoreLabel.text = str(Score)
		$LastScoreLabel.text = str(Score)
		#print("正解")
	else:
		GameTimeCount -= 10
		Score -= 50
		$sec60Label.text = str(GameTimeCount)
		$ScoreLabel.text = str(Score)
		$LastScoreLabel.text = str(Score)
		#print("不正解")
	$AnswerMark.frame = answer
	$AnswerMark.visible = true
	$AnswerTimer.start()
	pass # Replace with function body.

func _on_ScoreShowTimer_timeout():
	JavaScript.eval("window.RPGAtsumaru.scoreboards.display(1)")
	$StartButton.disabled = false
	$ScoreShowTimer.stop()
	pass # Replace with function body.


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	print("【HTTP1:result】",result)
	print("【HTTP1:response_code】",response_code)
	if headers: pass
	if response_code: pass
	if result: pass
	var json = JSON.parse(body.get_string_from_utf8())
	print("【HTTP1:json.result】",json.result)
	print("【HTTP1:result】",result)
	pass # Replace with function body.


func _on_HTTPRequest2_request_completed(result, response_code, headers, body):
	print("【HTTP0:result】",result)
	print("【HTTP0:response_code】",response_code)
	if headers: pass
	if response_code: pass
	if result: pass
	var json = JSON.parse(body.get_string_from_utf8())
	print("【HTTP0:json.result】",json.result)
	print("【HTTP0:result】",result)
	if !json.result == null:
		print("【server:userid】",userid)
		userid= int(json.result)
	pass
	userid = userid+1
	print("【userid】",userid)
	pass # Replace with function body.
