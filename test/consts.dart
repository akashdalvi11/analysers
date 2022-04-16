import 'package:technical_indicators/technical_indicators.dart';
var emaTree = IndicatorSpecTree<Candle>(
    5,[
        IndicatorSpecNode<EMA>({'period':10},[])
    ]
);