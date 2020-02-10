abstract class IFlavorConfig{
   String get appDisplayName;
}

class FlavorProd extends IFlavorConfig{
  @override
  String get appDisplayName => "Production App"; 
}

class FlavorDev extends IFlavorConfig{
    @override
  String get appDisplayName => "Dev App";
}