class FaultState extends EnumClass{

  
    static const inHand = FaultState._(15, '处理中');
  
    static const end = FaultState._(40, '已完结');
  


  static const List<FaultState> values = <FaultState>[
    
      inHand,
    
      end,
    
  ];

  static FaultState? fromValue(int? val){
    if (val != null) {
      List<FaultState> list = values.where((element) => element.value == val).toList();
      if(list.isNotEmpty){
        return list.first;
      }
    }
    return null;
  }

  const FaultState._(int value, String name) : super(value, name);
}