enum MaterialV { soil, cancer, waste }

extension MaterialVName on MaterialV {
  String display() {
    String name = '';
    switch (this) {
      case MaterialV.soil:
        name = '토사';
        break;
      case MaterialV.cancer:
        name = '암';
        break;

      case MaterialV.waste:
      default:
        name = '폐기물';
        break;
    }
    return name;
  }
}
