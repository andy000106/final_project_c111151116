import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'login_page.dart';
import 'recommend_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '今天吃什麼?',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
      ),
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.data == null || snapshot.data!.isAnonymous) { //!snapshot.hasData
          return LoginPage();
        }
        else {
          return MyHomePage(); // 你原本的主頁面
        }
      },
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex=0;

  //final tabs=[
   // Screen1(),
  //  Screen2(),
  //];

  Map<String, List<String>> meals = {
    '早餐': [],
    '午餐': [],
    '晚餐': [],
  };
  List<String> breakfast = ['吐司','饅頭','蛋餅','三明治','漢堡','鐵板麵','貝果','包子',
    '總匯','厚片','鍋貼','煎餃','水煎包','飯糰','燒餅'];
  List<String> lunch = ['便當','牛肉麵','乾麵','滷肉飯','燒肉飯','海苔飯捲','沙拉','水餃',
    '鍋貼','麵線羹','咖哩飯','麻醬麵','拉麵','炒泡麵','炒飯','碗粿','米糕','蒸餃','小籠包',
    '漢堡','春捲'];
  List<String> dinner = ['炒飯','拉麵','壽司','火鍋','披薩','炸雞','漢堡','牛肉麵','乾麵',
    '滷肉飯','燒肉飯','海苔飯捲','沙拉','水餃','鍋貼','麵線羹','咖哩飯','麻醬麵','炒泡麵',
    '碗粿','米糕','蒸餃','小籠包','春捲','牛排','鍋燒麵','便當','肉圓','土魠魚羹'];

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }
  Future<void> _loadMeals() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      meals['早餐'] = prefs.getStringList('breakfastOptions') ?? breakfast;
      meals['午餐'] = prefs.getStringList('lunchOptions') ?? lunch;
      meals['晚餐'] = prefs.getStringList('dinnerOptions') ?? dinner;
    });
  }
  Future<void> _saveMeals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('breakfastOptions', meals['早餐']!);
    await prefs.setStringList('lunchOptions', meals['午餐']!);
    await prefs.setStringList('dinnerOptions', meals['晚餐']!);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('今天吃什麼?'),
           backgroundColor: Colors.brown[100]!,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage('assets/bg5.jpg'),),
                ),
                child: Text('今天吃什麼?',style: TextStyle(fontFamily:"GenSekiGothic2-H",color: Colors.white60),),
            ),
            ListTile(
              leading: Icon(Icons.lightbulb),
              title: Text('設計理念'),
              onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ideaPage(),));
              },
            ),
            AboutListTile(
              icon: Icon(Icons.info_outline_rounded),
              applicationName:'今天吃什麼?',
              applicationVersion: 'Version1.0',
              child: Text('APP版本'),
            ),
            ListTile(
              leading: Icon(Icons.redo_sharp),
              title: Text('返回'),
              onTap: (){
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("登出"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bg6.jpg"),fit: BoxFit.cover,)
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height:10,),
              Image(image: AssetImage('assets/chef.png'),height: 200,width: 200,),
              Center(
                child: Text(
                  '歡迎使用\n「今天吃什麼?」APP',
                  style: TextStyle(fontSize: 30,fontFamily:"GenSekiGothic2-H",color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
              //SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(width: 10,),
                  IconButton(
                      iconSize: 30,
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RandomChoicePage(meals: meals),
                          ),
                        );
                      },
                      icon: Image.asset(
                        'assets/start.png',
                        height: 150,
                        width: 150,
                      )
                  ),
                  IconButton(
                      iconSize: 30,
                      onPressed: () async {
                        final updatedMeals = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditOptionsPage(meals: meals),
                          ),
                        );
                        if (updatedMeals != null) {
                          setState(() {
                            meals = updatedMeals;
                          });
                          _saveMeals();
                        }
                      },
                      icon: Image.asset(
                        'assets/edit.png',
                        height: 180,
                        width: 180,
                      )
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(width: 10,),
                  IconButton(
                      iconSize: 30,
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecommendPage(),
                          ),
                        );
                      },
                      icon: Image.asset(
                        'assets/recommend.png',
                        height: 150,
                        width: 150,
                      )
                  ),
                  IconButton(
                      iconSize: 30,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HistoryPage(),
                            ),
                        );
                      },
                      icon: Image.asset(
                        'assets/history.png',
                        height: 180,
                        width: 180,
                      )
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // bottomNavigationBar:BottomAppBar(
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //     children: [
      //       ElevatedButton(
      //           onPressed: (){
      //             Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                   builder: (context) => RandomChoicePage(meals: meals),
      //                 ),
      //             );
      //           },
      //           child: Text('開始隨機選擇'),
      //       ),
      //       ElevatedButton(
      //           onPressed: () async {
      //             final updatedMeals = await Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                 builder: (context) => EditOptionsPage(meals: meals),
      //               ),
      //             );
      //             if (updatedMeals != null) {
      //               setState(() {
      //                 meals = updatedMeals;
      //               });
      //               _saveMeals();
      //             }
      //           },
      //           child: Text('編輯選項'),
      //       ),
      //     ],
      //   ),
      // ),

    );
  }
}

class RandomChoicePage extends StatelessWidget {
  final Map<String, List<String>> meals;
  RandomChoicePage({required this.meals});

  void _showRandomResult(BuildContext context, String mealType) async{
    final options = meals[mealType]!;
    if (options.isEmpty) {
      _showDialog(context, '目前沒有選項，請新增選項');
    } else {
      final randomChoice = (options..shuffle()).first;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('meal_history')
            .doc()
            .set({
              'mealType': mealType,
              'choice': randomChoice,
              'time': Timestamp.now(),
            });
      }

      _showDialog(context, '隨機選擇的${mealType}是：$randomChoice');
    }
  }

  void _showDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('結果',style: TextStyle(fontSize: 28,fontFamily:"GenSekiGothic2-H",),),
        content: Text(message,style: TextStyle(fontSize:20,fontFamily:"GenSekiGothic2-H",),),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('確定',style: TextStyle(fontSize: 18,fontFamily:"GenSekiGothic2-H",),),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('現在要吃的是?')),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg1.jpg"),fit: BoxFit.cover,)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 200,
              width: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(image: AssetImage("assets/breakfast.jpg"),fit: BoxFit.cover),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Colors.white70.withOpacity(0.7),
                ),
                onPressed: () => _showRandomResult(context, '早餐'),
                child: Text('早餐',style: TextStyle(fontSize: 36,fontFamily:"851tegaki",color: Colors.brown[900]!),),
              ),
            ),
            SizedBox(height: 10,),
            Container(
              height: 200,
              width: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(image: AssetImage("assets/lunch.jpg"),fit: BoxFit.cover),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Colors.white60.withOpacity(0.6),
                ),
                onPressed: () => _showRandomResult(context, '午餐'),
                child: Text('午餐',style: TextStyle(fontSize: 36,fontFamily:"851tegaki",color: Colors.brown[900]!),),
              ),
            ),
            SizedBox(height: 10,),
            Container(
              height: 200,
              width: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(image: AssetImage("assets/dinner.jpg"),fit: BoxFit.cover),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Colors.white70.withOpacity(0.6),
                ),
                onPressed: () => _showRandomResult(context, '晚餐'),
                child: Text('晚餐',style: TextStyle(fontSize: 36,fontFamily:"851tegaki",color: Colors.brown[900]!),),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class EditOptionsPage extends StatefulWidget {
  final Map<String, List<String>> meals;
  EditOptionsPage({required this.meals});

  @override
  _EditOptionsPageState createState() => _EditOptionsPageState();
}

class _EditOptionsPageState extends State<EditOptionsPage> {
  late Map<String, List<String>> meals;

  @override
  void initState() {
    super.initState();
    meals = Map<String, List<String>>.from(widget.meals);
  }

  void _addOption(String mealType, String newOption) {
    setState(() {
      meals[mealType]!.add(newOption);
    });
  }

  void _removeOption(String mealType, int index) {
    setState(() {
      meals[mealType]!.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('編輯選項'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            color: Colors.green[800]!,
            onPressed: () => Navigator.pop(context, meals),
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            image: DecorationImage(
              opacity: 0.3,
              image: AssetImage("assets/sunflower.jpg"),fit: BoxFit.cover,)
        ),
        child: ListView(
          children: meals.keys.map((mealType) {
            final options = meals[mealType]!;
            final TextEditingController controller = TextEditingController();

            return ExpansionTile(
              title: Text(mealType,style: TextStyle(fontSize: 24,color: Colors.black),),
              subtitle: Text('現在有 ${meals[mealType]!.length} 個選項'),
              children: [
                ...options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  return ListTile(
                    title: Text(option),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _removeOption(mealType, index),
                    ),
                  );
                }).toList(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            labelText: '新增選項',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (controller.text.isNotEmpty) {
                            _addOption(mealType, controller.text);
                            controller.clear();
                          }
                        },
                        child: Text('新增'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class ideaPage extends StatefulWidget {
  @override
  State<ideaPage> createState() => _ideaPageState();
}

class _ideaPageState extends State<ideaPage> {
  @override
  Widget build(BuildContext context) {
    String s1 = '從大學一年級開始，到了要吃午餐的時候，'
        '因為學校周邊有很多好吃的美食，午餐的選擇很豐富，經常不知道要吃什麼而煩惱'
        '所以想要做一個手機APP，來幫助選擇困難的人決定現在要吃什麼';
    return Scaffold(
      appBar: AppBar(title: Text('設計理念',style: TextStyle(fontSize: 20),),),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bg3.jpg"),fit: BoxFit.cover,)
        ),
        child: Column(
          children: [
            SizedBox(height: 30,),
            Text(s1,style: TextStyle(fontSize: 20,),),
          ],
        ),
      ),
    );

  }
}


class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text("尚未登入")),
      );
    }
    else{
      return Scaffold(
        appBar: AppBar(title:Text("歷史紀錄")),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/bg8.png'),fit: BoxFit.cover)
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('meal_history')
                .orderBy('time', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData){
                return Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Center(child: Text("暫無任何紀錄"));
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final mealType = doc['mealType'];
                  final choice = doc['choice'];
                  final time = (doc['time'] as Timestamp).toDate();
                  final formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(time);
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.zero,
                        right: Radius.circular(30),
                      ),
                    ),
                    elevation: 10,
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      title: Text('$mealType: $choice',style: TextStyle(fontSize: 26,fontFamily:"851tegaki",color: Colors.black),),
                      subtitle: Text(formattedTime,style: TextStyle(fontSize: 16,color: Colors.black),),
                    ),
                  );
                },
              );
            },
          ),
        ),
      );
    }
  }
}

