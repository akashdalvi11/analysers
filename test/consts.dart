import 'package:technical_indicators/technical_indicators.dart';
var emaTree = IndicatorSpecTree<Candle>(
    5,[
        IndicatorSpecNode<EMA>({'period':10},[])
    ]
);
var emaHeikenAshiTree = IndicatorSpecTree<Candle>(
    5,[
        IndicatorSpecNode<HeikenAshi>({},[
            IndicatorSpecNode<EMA>({'period':10},[])
        ])
    ]
);
var smaTree = IndicatorSpecTree<Candle>(
    3,[
  IndicatorSpecNode<SMA>({'period':9},[]),
  IndicatorSpecNode<Stochastic>({'period':15},[
    IndicatorSpecNode<SMA>({'period':3}, [
      IndicatorSpecNode<SMA>({'period':3}, [])
    ])
  ]),
  IndicatorSpecNode<Stochastic>({'period':12},[
    IndicatorSpecNode<SMA>({'period':3}, [
      IndicatorSpecNode<SMA>({'period':3}, [])
    ])
  ])
]
);