import 'dart:io';
import 'package:test/test.dart';
import 'package:dartz/dartz.dart';
import 'package:analysers/analysers.dart';
import 'package:kite_connect/kite_connect.dart' as kt;
import 'package:technical_indicators/technical_indicators.dart';
import 'consts.dart' as consts;

void main(){
    kt.KiteConnect? k;
    HistoricalData<Candle>? data;
    setUp(() async{
        var e = Platform.environment;
        var result = await kt.KiteConnect.create(e['userName']!,e['password']!,e['twoFA']!,'./test');
        result.fold((l) {
            print(l);
        },(r){
            k = r;
        });
        var res = await k!.getHistoricalData("NIFTY BANK",5,DateTime.parse('2022-04-05'),DateTime.parse('2022-04-08'));
        res.fold((l){
            print(l);
        },(r){
            print(r);
            data = HistoricalData.createOHLC(r.dateTimeList,r.ohlcList);
        });
    });
    test('analyser backtest',(){
        assert(data != null);
        var uDateTimeList = data!.dateTimeList.sublist(150);
        var uDataList = data!.dataList.sublist(150);
        var end = data!.dateTimeList.length;
        data!.dateTimeList.removeRange(150,end);
        data!.dataList.removeRange(150,end);
        var dataTree = consts.emaTree.build(data!);
        var emaAnalyser = EMAAnalyser(dataTree);
        print(emaAnalyser.inference);
        for(int i=0;i<uDataList.length;i++){
            int? inference = emaAnalyser.update(uDateTimeList[i],uDataList[i].o);
            stdout.write("${dataTree.dateTimeList[150+i-1]}: ");
            stdout.write("${dataTree.dataList[150+i-1]}: ");
            stdout.write("${dataTree.children[0].dataList[150+i-1]}: ");
            if(inference != null) stdout.write('$inference');
            stdout.write('\n');
            emaAnalyser.update(uDateTimeList[i],uDataList[i].h);
            emaAnalyser.update(uDateTimeList[i],uDataList[i].l);
            emaAnalyser.update(uDateTimeList[i],uDataList[i].c);
        }
    });
}