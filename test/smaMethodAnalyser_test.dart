import 'dart:io';
import 'package:hive/hive.dart';
import 'package:test/test.dart';
import 'package:analysers/analysers.dart';
import 'package:kite_connect/kite_connect.dart' as kt;
import 'package:technical_indicators/technical_indicators.dart';
import 'consts.dart' as consts;

void main(){
  kt.KiteConnect? k;
  final DateTime from = DateTime.parse('2023-03-01');
  final DateTime to = DateTime.parse('2023-03-22');
  const interval = 3;
  const instrument = "NIFTY BANK";
  late final List<DateTime> dateTimes;
  late final List<List<double>> ohlcs;
  setUp(() async{
    Hive.init('./test');
    String boxName = '$instrument$from$to$interval';
    if(!(await Hive.boxExists(boxName))) {
      var e = Platform.environment;
      var result = await kt.KiteConnect.create(
          e['userName']!, e['password']!, e['twoFA']!, './test');
      result.fold((l) {
        print(l);
      }, (r) {
        k = r;
      });
      var res = await k!.getHistoricalData(
          instrument,interval,from,
          to);
      res.fold((l) {
        print(l);
      }, (r)  async{
        dateTimes = r.dateTimeList;
        ohlcs = r.ohlcList;
      });
      var storedData = await Hive.openBox(boxName);
      await storedData.put('dateTimes', dateTimes);
      await storedData.put('ohlcs',ohlcs);
    }else{
      var storedData = await Hive.openBox(boxName);
      dateTimes = (storedData.get('dateTimes') as List<dynamic>).cast();
      ohlcs = (storedData.get('ohlcs') as List<dynamic>).cast();
    }
  });
  test('smaAnalyser backtest',(){
    var data = HistoricalData.createOHLC(dateTimes, ohlcs);
    var uDateTimeList = data.dateTimeList.sublist(20);
    var uDataList = data.dataList.sublist(20);
    var end = data.dateTimeList.length;
    data.dateTimeList.removeRange(20,end);
    data.dataList.removeRange(20,end);
    var dataTree = consts.smaTree.build(data);
    var smaAnalyser = SMAMethodAnalyser(dataTree);
    print(smaAnalyser.inference);
    for(int i=0;i<uDataList.length;i++){
      int? inference = smaAnalyser.update(uDateTimeList[i],uDataList[i].o);
      stdout.write("${uDateTimeList[i]}: ");
      stdout.write("${uDataList[i]}: ");
      if(inference != null) stdout.write('$inference');
      stdout.write('\n');
      smaAnalyser.update(uDateTimeList[i],uDataList[i].h);
      smaAnalyser.update(uDateTimeList[i],uDataList[i].l);
      smaAnalyser.update(uDateTimeList[i],uDataList[i].c);
      if(uDateTimeList[i].hour == 15 && uDateTimeList[i].minute == 27){
        var d = uDateTimeList[i];
        var endD = DateTime(d.year,d.month,d.day,15,30);
        int? inferenceEnd = smaAnalyser.update(endD,uDataList[i].c);
        stdout.write("${endD}: ");
        stdout.write("${uDataList[i]}: ");
        if(inferenceEnd != null) stdout.write('$inferenceEnd');
        else stdout.write('end inference null');
        stdout.write('\n');
      }
    }
  });
}