import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RecommendPage extends StatefulWidget {
  const RecommendPage({super.key});

  @override
  State<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  final List<String> taiwan_cities = [
    '臺北市', '新北市', '基隆市', '桃園市', '新竹市', '新竹縣',
    '苗栗縣', '臺中市', '彰化縣', '南投縣', '宜蘭縣', '花蓮縣',
    '臺東縣', '雲林縣', '嘉義市', '嘉義縣', '臺南市', '高雄市',
    '屏東縣', '澎湖縣', '金門縣', '連江縣'
  ];

  final List<String> warming_meal = [
    '麻辣鍋', '壽喜燒', '羊肉爐', '麻油雞', '烤地瓜', '薑母鴨',
    '廣東粥', '熱湯麵', '麵線羹', '砂鍋魚頭'
  ];

  final List<String> normal_meal =[
    '鯖魚定食', '親子丼', '雞腿便當', '排骨飯', '義大利麵',
    '雞絲飯', '魯肉飯', '潤餅捲'
  ];

  final List<String> cooldown_meal =[
    '剉冰' ,  '豆花' , '仙草凍', '愛玉' ,'涼拌菜',
    '水果沙拉', '涼麵', '韓式冷麵', '生魚片'
  ];

  final List<String> seafood_allergens = [
    '海鮮', '魚', '蝦', '蟹', '蛤蜊', '貝', '牡蠣'
  ];

  String? selectedCity;
  String temperature = '';
  String weather = '';
  bool isLoading = false;
  String feel = '?';
  String today_recommend = '?';
  bool seafood_allergy = false;

  Future<void> CheckWeather(String cityName) async {
    setState(() {
      isLoading = true;
    });

    // 中央氣象局api key-中央氣象局的氣象開放資料平台會員授權碼
    final apiKey = "CWA-CD851DB2-8369-472C-BCA7-74E6D5901037";
    final url = 'https://opendata.cwa.gov.tw/api/v1/rest/datastore/O-A0003-001?Authorization=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final stations = jsonData['records']['Station'];
        final station = stations.firstWhere(
              (s) => s['GeoInfo']['CountyName'] == cityName,
          orElse: () => null,
        );

        if (station != null) {
          final airTemp = station['WeatherElement']['AirTemperature'];
          final wx = station['WeatherElement']['Weather'];
          setState(() {
            temperature = (airTemp != '-99')?'$airTemp':'暫無資料';
            weather = (wx != '-99' && wx != null)?wx:'暫無資料';
            isLoading = false;
          });
        }
        else {
          setState(() {
            temperature = '測站資料無法查詢';
            weather = '測站資料無法查詢';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        temperature = '連線失敗';
        weather = '連線失敗';
        isLoading = false;
      });
    }
  }
  void recommend(){
    List<String> recommend_list = [];
    String random_recommend = '';
    String feels = '';

    if (temperature != '暫無資料' && temperature != '測站資料無法查詢' && temperature != '連線失敗'){
      final temp = double.tryParse(temperature);
      if(temp! < 15){
        recommend_list = warming_meal;
        feels = '冷';
      }
      else if(temp > 16 && temp < 27){
        recommend_list = normal_meal;
        feels = '適中';
      }
      else{
        recommend_list = cooldown_meal;
        feels = '熱';
      }

      if(seafood_allergy){
        recommend_list = recommend_list.where((meal){
          return !seafood_allergens.any((allergen) => meal.contains(allergen));
        }).toList();
      }

      random_recommend = (recommend_list..shuffle()).first;
    }
    else{
      random_recommend = '缺少資料，無法推薦';
      feels = '缺少資料，無法判別';
    }

    setState(() {
      today_recommend = random_recommend;
      feel = feels;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('今日推薦')),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/bg9.png'),fit: BoxFit.cover)
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                child: DropdownButton<String>(
                  dropdownColor: Colors.white70,
                  isExpanded: true,
                  style: TextStyle(fontSize: 20,color: Colors.black),
                  hint: Text('選擇縣市'),
                  value: selectedCity,
                  items: taiwan_cities.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value;
                      today_recommend = '?';
                    });
                    if (value != null){
                      CheckWeather(value);
                    }
                  },
                ),
              ),

              selectedCity != null?
                  Row(
                      children: [
                        Text('有海鮮過敏?',style: TextStyle(fontSize: 24,color: Colors.black),),
                        Switch(
                          value: seafood_allergy,
                          onChanged: (value) {
                            setState(() {
                              seafood_allergy = !seafood_allergy;
                            });
                          }
                         ),
                         SizedBox(height: 10,),
                         Text(seafood_allergy?'是':'否',style: TextStyle(fontSize: 22,color: Colors.black),),
                      ],
                  ):
                  Text(''),

              selectedCity == null?
                Text('請先選擇縣市',style: TextStyle(fontSize: 24,fontFamily:"GenSekiGothic2-H",color: Colors.black),):
                isLoading?
                  Center(child:CircularProgressIndicator(),):
                  Column(
                    children: [
                      SizedBox(height: 32),
                      Text('縣市:$selectedCity', style: TextStyle(fontSize: 30)),
                      SizedBox(height: 10),
                      Text('現在氣溫:$temperature 度', style: TextStyle(fontSize: 20)),
                      Text('現在天氣狀況:$weather', style: TextStyle(fontSize: 20)),
                      SizedBox(height: 20,),
                      ElevatedButton(
                          onPressed: recommend,
                          child: Text(today_recommend =='?'?'開始餐點推薦':'重新推薦餐點',style: TextStyle(fontSize: 24,fontFamily:"851tegaki",color: Colors.black),),
                      ),
                      SizedBox(height: 32),
                      today_recommend != '?'?Text('現在氣溫感受是:$feel 的', style: TextStyle(fontSize: 20)):Text(''),
                      SizedBox(height: 10,),
                      Text('根據氣溫推薦的餐點是:$today_recommend', style: TextStyle(fontSize: 20)),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
