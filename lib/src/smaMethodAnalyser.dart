import 'package:technical_indicators/technical_indicators.dart';
class SMAMethodAnalyser{
  final IndicatorDataTree indicatorDataTree;
  int inference = 0;
  late List<Candle> candleList;
  late List<SMA> smaList;
  late List<SMA> kList1;
  late List<SMA> kList2;
  late List<SMA> dList1;
  late List<SMA> dList2;

  static int _checkInference(Candle c,SMA s,SMA k1, SMA k2, SMA d1, SMA d2){
    if(c.c > c.o){
      if(c.o >= s.value) if(k1.value > 50 && k2.value > 50 && d1.value > 50 && d2.value > 50) return 1;
    }else{
      if(c.o <= s.value) if(k1.value < 50 && k2.value < 50 && d1.value < 50 && d2.value < 50) return -1;
    }
    return 0;
  }
  static bool _isStateDifferent(Candle c,SMA e,int inferedState){
    if(inferedState == 1){
      return c.c < c.o ? c.o < e.value : false;
    } else return c.c > c.o ? c.o > e.value : false;
  }
  SMAMethodAnalyser(this.indicatorDataTree){
    candleList = indicatorDataTree.dataList.cast<Candle>();
    smaList = indicatorDataTree.children[0].dataList.cast<SMA>();
    kList1 = indicatorDataTree.children[1].children[0].dataList.cast<SMA>();
    dList1 = indicatorDataTree.children[1].children[0].children[0].dataList.cast<SMA>();
    kList2 = indicatorDataTree.children[2].children[0].dataList.cast<SMA>();
    dList2 = indicatorDataTree.children[1].children[0].children[0].dataList.cast<SMA>();
  }

  int? update(DateTime d, double ltp){
    if(d.hour == 15 && d.minute == 30) {
      inference = 0;
      return 0;
    }
    if(indicatorDataTree.update(Event(d,ltp))){
      if(d.hour == 9 && d.minute <= 30) return null;

      int sl = indicatorDataTree.dateTimeList.length-2;
      if(inference != 0){
          if(_isStateDifferent(candleList[sl], smaList[sl], inference)) {
            inference = 0;
            return 0;
          }
      }else{
        inference = _checkInference(candleList[sl],smaList[sl],kList1[sl],kList2[sl],dList1[sl],dList2[sl]);
        if(inference != 0) return inference;
      }
    }
    return null;
  }
}
