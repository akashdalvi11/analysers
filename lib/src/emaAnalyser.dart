import 'package:technical_indicators/technical_indicators.dart';
class EMAAnalyser{
	final IndicatorDataTree indicatorDataTree;
	late int inference;
	late List<Candle> cl;
	late List<EMA> el;
	static bool approxEqual(double a,double b){
		var l = a-1;
		var h = a+1;
		return b<h && b>l;
	}
	static int _checkInference(Candle c,EMA e){
		var bound = c.o + (c.c - c.o)/4;
		if(c.c>e.value){
			if(approxEqual(c.o,c.l) && e.value<bound)
				return 1;
		}else{
            if(approxEqual(c.o,c.h) && e.value>bound)
                return -1;
        }
        return 0;		
	}
	static bool _isStateSimilar(Candle c,EMA e,int inferedState){
		return c.c * inferedState > e.value * inferedState;
	}
    EMAAnalyser(this.indicatorDataTree){
		cl = indicatorDataTree.dataList.cast<Candle>();
		el = indicatorDataTree.children[0].dataList.cast<EMA>();
		var sl = indicatorDataTree.dateTimeList.length-2;
		var initialGuess = cl[sl].c > el[sl].value ? 1:-1;
		inference = _checkInferenceBackWords(initialGuess,sl);
    }
	int _checkInferenceBackWords(int inferedState,int index){
		for(int i=index;i>=0;i--){
			if(_isStateSimilar(cl[i],el[i],inferedState)){
				var inference = _checkInference(cl[i],el[i]);
			    if(inference!=0) return inference;
			}else return 0;
		}
		return 0;
	}
	
	int? update(DateTime d, double ltp){
		if(indicatorDataTree.update(Event(d,ltp))){
			int sl = indicatorDataTree.dateTimeList.length-2;
			if(inference != 0){
				if(!_isStateSimilar(cl[sl],el[sl],inference)){
					inference = _checkInference(cl[sl],el[sl]);
					return inference;
				}
			}else{
				inference = _checkInference(cl[sl],el[sl]);
				if(inference != 0) return inference;
			}
		}		
	}
}
