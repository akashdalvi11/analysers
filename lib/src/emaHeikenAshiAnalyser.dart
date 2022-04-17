import 'package:technical_indicators/technical_indicators.dart';
import 'dart:io';
class EMAHeikenAshiAnalyser{
	final IndicatorDataTree indicatorDataTree;
	late int inference;
	late List<EMA> el;
    late List<HeikenAshi> hl;
	static bool approxEqual(double a,double b){
		var l = a-1;
		var h = a+1;
		return b<h && b>l;
	}
	static int _checkInference(HeikenAshi h,EMA e){
		var bound = h.o + (h.c - h.o)/4;
		if(h.c>e.value){
			if(approxEqual(h.o,h.l) && e.value<bound)
				return 1;
		}else{
            if(approxEqual(h.o,h.h) && e.value>bound)
                return -1;
        }
        return 0;		
	}
	static bool _isStateSimilar(HeikenAshi h,EMA e,int inferedState){
		return h.c * inferedState > e.value * inferedState;
	}
    EMAHeikenAshiAnalyser(this.indicatorDataTree){
		hl = indicatorDataTree.children[0].dataList.cast<HeikenAshi>();
		el = indicatorDataTree.children[0].children[0].dataList.cast<EMA>();
		var sl = indicatorDataTree.dateTimeList.length-2;
		var initialGuess = hl[sl].c > el[sl].value ? 1:-1;
		inference = _checkInferenceBackWords(initialGuess,sl);
    }
	int _checkInferenceBackWords(int inferedState,int index){
		for(int i=index;i>=0;i--){
			if(_isStateSimilar(hl[i],el[i],inferedState)){
				var inference = _checkInference(hl[i],el[i]);
			    if(inference!=0) return inference;
			}else return 0;
		}
		return 0;
	}
	
	int? update(DateTime d, double ltp){
		if(indicatorDataTree.update(Event(d,ltp))){
			int sl = indicatorDataTree.dateTimeList.length-2;
			if(inference != 0){
				if(!_isStateSimilar(hl[sl],el[sl],inference)){
					inference = _checkInference(hl[sl],el[sl]);
					return inference;
				}
			}else{
				inference = _checkInference(hl[sl],el[sl]);
				if(inference != 0) return inference;
			}
		}		
	}
}
