enum MaterialV { soil, cancer, poorsoil, weatheredrock, waste }

extension MaterialVName on MaterialV {
  String display() {
    var name = '';
    switch (this) {
      case MaterialV.soil:
        name = '토사';
      case MaterialV.cancer:
        name = '암';
      case MaterialV.poorsoil:
        name = '불량토';
      case MaterialV.weatheredrock:
        name = '풍화암';

      case MaterialV.waste:
      default:
        name = '폐기물';
    }
    return name;
  }
}
